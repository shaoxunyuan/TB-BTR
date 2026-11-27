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


MATRIX_COLUMNS = {
    "gene": 23,
    "BTM": 24,
    "BloodGen3": 25,
    "LM22": 26,
    "ImmunoStates": 27,
}

# Gene and module matrices hold features in rows and samples in columns;
# cell matrices hold samples in rows and cell categories in columns.
SAMPLE_AXIS_COLUMNS = {"gene", "BTM", "BloodGen3"}


def parse_dimensions(value, label, dataset):
    """Return (rows, columns) from a stored 'rows / columns' cell."""
    text = "" if value is None else str(value).strip()
    if text in ("Unavailable", "NA", ""):
        require(label != "gene", f"Gene matrix marked unavailable: {dataset}")
        return None
    parts = [part.strip() for part in text.split("/")]
    require(len(parts) == 2 and all(part.isdigit() for part in parts),
            f"Malformed {label} matrix dimensions ({text!r}): {dataset}")
    rows, columns = int(parts[0]), int(parts[1])
    require(rows > 0 and columns > 0, f"Non-positive {label} matrix dimensions ({text!r}): {dataset}")
    return rows, columns


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

    dimensions = {}
    for row in datasets:
        dataset = normalize_dataset(row[0])
        records = int(row[6])
        dimensions[dataset] = {}
        for label, index in MATRIX_COLUMNS.items():
            parsed = parse_dimensions(row[index], label, dataset)
            dimensions[dataset][label] = parsed
            if parsed is None:
                continue
            stored_axis = parsed[1] if label in SAMPLE_AXIS_COLUMNS else parsed[0]
            require(stored_axis == records,
                    f"{label} matrix sample axis ({stored_axis}) disagrees with the {records} stored records: {dataset}")
        require(dimensions[dataset]["gene"] is not None, f"Gene matrix dimensions missing: {dataset}")

    inventory = {normalize_dataset(row["dataset_id"]): row for row in read_tsv(ROOT / "data/metadata/matrix_inventory.tsv")}
    require(set(inventory) == set(dimensions), "Matrix inventory does not cover the same datasets as Table S1")
    for dataset, stored in inventory.items():
        for label, prefix in (("gene", "gene"), ("BTM", "btm"), ("BloodGen3", "bloodgen3"), ("LM22", "lm22"), ("ImmunoStates", "immunostates")):
            expected = dimensions[dataset][label]
            if expected is None:
                continue
            recorded = (int(stored[f"{prefix}_data_rows"]), int(stored[f"{prefix}_data_columns"]))
            require(recorded == expected,
                    f"Inventory {prefix} dimensions {recorded} disagree with Table S1 {expected}: {dataset}")

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
