import os
import json
import pandas as pd


FEATURES = [
    "loc",
    "methods",
    "fields",
    "imports",
    "cyclomatic_complexity",
    "dependencies"
]


def collect_metrics(metrics_directory: str):
    """
    Read metric JSON files and convert them into
    a pandas DataFrame suitable for ML training.
    """

    records = []

    if not os.path.exists(metrics_directory):
        return pd.DataFrame(columns=FEATURES)

    for filename in os.listdir(metrics_directory):

        if not filename.endswith(".json"):
            continue

        file_path = os.path.join(
            metrics_directory,
            filename
        )

        try:
            with open(
                file_path,
                "r",
                encoding="utf-8"
            ) as file:

                data = json.load(file)

            for item in data:

                lines = item.get("lines", {})

                records.append({
                    "loc": lines.get("code_lines", 0),
                    "methods": item.get("methods", 0),
                    "fields": item.get("fields", 0),
                    "imports": item.get("imports", 0),
                    "cyclomatic_complexity":
                        item.get(
                            "cyclomatic_complexity",
                            0
                        ),
                    "dependencies":
                        item.get(
                            "dependencies",
                            0
                        )
                })

        except Exception as e:
            print(
                f"Could not process {filename}: {e}"
            )

    return pd.DataFrame(records)