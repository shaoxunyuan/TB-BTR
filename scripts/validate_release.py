"""Validate the public inventory and fixed-case links without modifying inputs."""

import csv
from collections import Counter
from pathlib import Path

from openpyxl import load_workbook


ROOT = Path(__file__).resolve().parents[1]


def normalize_dataset(value):
    return str(value).replace("E-MTAB-", "EMTAB", 1)


def require(condition, message):
    if not condition:
        raise ValueError(message)


def read_tsv(path):
    with path.open(encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle, delimiter="\t"))


def main():
    tables = ROOT / "data/tables"
    workbook = load_workbook(tables / "TableS1.xlsx", read_only=True, data_only=True)
    require(workbook.sheetnames == ["S1A", "S1B", "S1C", "S1D", "S1E"], "Unexpected Table S1 worksheets")
    samples = list(workbook["S1E"].values)[1:]
    sample_map = {(normalize_dataset(row[0]), str(row[1])): row for row in samples}
    require(len(sample_map) == len(samples), "Duplicate dataset/sample identifiers")
    counts = Counter(key[0] for key in sample_map)
    datasets = [row for row in list(workbook["S1B"].values)[1:] if normalize_dataset(row[0]) in counts]
    require(len(datasets) == len(counts), "Dataset inventory does not match sample annotations")
    for row in datasets:
        require(counts[normalize_dataset(row[0])] == row[6], f"Sample-count mismatch: {row[0]}")
    default_count = sum(row[14] == "Yes" for row in samples)
    require(default_count == sum(row[20] for row in datasets), "Default-scope count mismatch")

    provenance = read_tsv(ROOT / "data/metadata/time_provenance.tsv")
    require(len(provenance) == len(samples), "Time-provenance coverage mismatch")
    require(len({(row['dataset_id'], row['sample_id']) for row in provenance}) == len(provenance), "Duplicate provenance records")
    for row in provenance:
        record = sample_map.get((normalize_dataset(row["dataset_id"]), row["sample_id"]))
        require(record is not None, "Time provenance references an unknown record")
        require(record[4] == row["final_interval"] and record[5] == row["final_leaf"], "Final interval mismatch")

    case = ROOT / "reproducibility/fixed_case"
    manifest = read_tsv(case / "sample_manifest.tsv")
    require(len({row["participant"] for row in manifest}) == len(manifest), "Duplicate selected participant keys")
    for row in manifest:
        require(row["participant"].startswith("SRC-"), "Unexpected participant-key format")
        record = sample_map.get((normalize_dataset(row["dataset"]), row["sample"]))
        require(record is not None, "Selected record absent from Table S1")
        require(record[2] == row["group"], "Selected phenotype mismatch")
        require(record[6] == "Whole Blood" and record[11] == "Negative" and record[14] == "Yes", "Selected record fails case restrictions")

    meta = load_workbook(tables / "TableS2.xlsx", read_only=True, data_only=True)
    selected = list(meta["S2C_Selected_Records"].values)[1:]
    require(len(selected) == len(manifest), "Table S2 selected-record count differs from the manifest")
    require({(normalize_dataset(row[0]), str(row[1])) for row in selected} == {(normalize_dataset(row["dataset"]), row["sample"]) for row in manifest}, "Table S2 selection differs from the analysis manifest")
    for signature in {row["signature"] for row in read_tsv(case / "cell_estimability.tsv")}:
        rows = [row for row in read_tsv(case / "cell_estimability.tsv") if row["signature"] == signature]
        require(len(rows) == int(rows[0]["planned_test_family"]), "Estimability family incomplete")
    workbook.close()
    meta.close()
    print(f"Validated {len(counts)} datasets, {len(samples)} records, {default_count} default-scope records and {len(manifest)} selected records.")


if __name__ == "__main__":
    main()
