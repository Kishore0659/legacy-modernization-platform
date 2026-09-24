import os
import joblib
import pandas as pd

from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report

from app.ml.dataset import collect_metrics
from app.ml.labeling import calculate_priority


METRICS_DIRECTORY = "metrics_data"

MODEL_DIRECTORY = "models"

MODEL_PATH = os.path.join(
    MODEL_DIRECTORY,
    "technical_debt_model.pkl"
)


def train_model():

    df = collect_metrics(
        METRICS_DIRECTORY
    )

    if df.empty:
        raise ValueError(
            "No metric data found"
        )

    # Generate training labels
    df["modernization_priority"] = (
        df.apply(
            calculate_priority,
            axis=1
        )
    )

    X = df[
        [
            "loc",
            "methods",
            "fields",
            "imports",
            "cyclomatic_complexity",
            "dependencies"
        ]
    ]

    y = df[
        "modernization_priority"
    ]

    # For very small datasets
    # train directly.
    if len(df) < 10:

        model = RandomForestClassifier(
            n_estimators=100,
            random_state=42
        )

        model.fit(X, y)

    else:

        X_train, X_test, y_train, y_test = (
            train_test_split(
                X,
                y,
                test_size=0.2,
                random_state=42,
                stratify=y
            )
        )

        model = RandomForestClassifier(
            n_estimators=200,
            random_state=42
        )

        model.fit(
            X_train,
            y_train
        )

        predictions = model.predict(
            X_test
        )

        print(
            classification_report(
                y_test,
                predictions
            )
        )

    os.makedirs(
        MODEL_DIRECTORY,
        exist_ok=True
    )

    joblib.dump(
        model,
        MODEL_PATH
    )

    return MODEL_PATH


if __name__ == "__main__":

    path = train_model()

    print(
        f"Model saved to: {path}"
    )