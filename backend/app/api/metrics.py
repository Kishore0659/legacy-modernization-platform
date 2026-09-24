import os
import re
from fastapi import APIRouter, HTTPException

try:
    from app.metrics.metrics_service import calculate_file_metrics
except ImportError:
    calculate_file_metrics = None

router = APIRouter(
    prefix="/metrics",
    tags=["Software Metrics"]
)

LANGUAGE_EXTENSIONS = {
    ".java": "java",
    ".py": "python",
    ".js": "javascript",
    ".ts": "typescript",
    ".cs": "csharp",
    ".php": "php",
    ".cpp": "cpp",
    ".c": "c",
    ".go": "go",
    ".rb": "ruby"
}


def calculate_polyglot_metrics(file_path: str, lang: str) -> dict:
    try:
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            content = f.read()
    except Exception:
        return {"file": os.path.basename(file_path), "loc": 0, "classes": 0, "methods": 0, "complexity": 0}

    lines = content.split("\n")
    loc = len(lines)

    # Universal class extraction
    if lang in ["java", "csharp", "php"]:
        classes = len(re.findall(r"(?:class|interface)\s+([A-Za-z0-9_]+)", content))
    elif lang == "python":
        classes = len(re.findall(r"class\s+([A-Za-z0-9_]+)", content))
    elif lang in ["javascript", "typescript"]:
        classes = len(re.findall(r"class\s+([A-Za-z0-9_]+)", content))
    elif lang == "go":
        classes = len(re.findall(r"type\s+([A-Za-z0-9_]+)\s+struct", content))
    elif lang in ["c", "cpp"]:
        classes = len(re.findall(r"(?:class|struct)\s+([A-Za-z0-9_]+)", content))
    else:
        classes = len(re.findall(r"class\s+([A-Za-z0-9_]+)", content))

    # Universal method extraction
    if lang in ["java", "csharp"]:
        methods = len(re.findall(r"(?:public|protected|private|static)\s+[\w<>\[\]]+\s+([A-Za-z0-9_]+)\s*\(", content))
    elif lang == "python":
        methods = len(re.findall(r"def\s+([A-Za-z0-9_]+)\s*\(", content))
    elif lang in ["javascript", "typescript"]:
        matches = re.findall(r"(?:function\s+([A-Za-z0-9_]+)|([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>)", content)
        methods = len([m[0] or m[1] for m in matches if (m[0] or m[1])])
    elif lang == "php":
        methods = len(re.findall(r"function\s+([A-Za-z0-9_]+)\s*\(", content))
    elif lang == "go":
        methods = len(re.findall(r"func\s+(?:\([^)]+\)\s+)?([A-Za-z0-9_]+)\s*\(", content))
    else:
        methods = len(re.findall(r"(?:def|func|function)\s+([A-Za-z0-9_]+)\s*\(", content))

    # Universal Cyclomatic Complexity branch count (if, elif, for, while, catch/except, case)
    complexity = len(re.findall(r"\b(if|elif|else\s+if|for|while|catch|except|case)\b", content))

    return {
        "file": os.path.basename(file_path),
        "language": lang,
        "loc": loc,
        "classes": classes,
        "methods": methods,
        "cyclomatic_complexity": complexity
    }


@router.get("/{project_id}")
def get_metrics(project_id: str):
    project_path = os.path.join("uploads", project_id)

    if not os.path.exists(project_path):
        raise HTTPException(
            status_code=404,
            detail="Project not found"
        )

    file_results = []
    total_loc = 0
    total_classes = 0
    total_methods = 0
    total_complexity = 0

    for root, dirs, files in os.walk(project_path):
        for file in files:
            ext = os.path.splitext(file.lower())[1]
            if ext in LANGUAGE_EXTENSIONS:
                file_path = os.path.join(root, file)
                lang = LANGUAGE_EXTENSIONS[ext]

                # Use original calculate_file_metrics for Java if available, otherwise polyglot parser
                metrics = None
                if ext == ".java" and calculate_file_metrics:
                    try:
                        metrics = calculate_file_metrics(file_path)
                    except Exception:
                        metrics = None

                if not metrics or not isinstance(metrics, dict):
                    metrics = calculate_polyglot_metrics(file_path, lang)

                file_results.append(metrics)

                # Accumulate project-wide totals
                total_loc += metrics.get("loc", metrics.get("lines_of_code", 0))
                total_classes += metrics.get("classes", metrics.get("class_count", 0))
                total_methods += metrics.get("methods", metrics.get("method_count", 0))
                total_complexity += metrics.get("cyclomatic_complexity", metrics.get("complexity", 0))

    debt_level = "HIGH" if (total_complexity > 15 or total_loc > 300) else "MEDIUM"

    return {
        "project_id": project_id,
        "loc": total_loc,
        "classes": total_classes or len(file_results),
        "methods": total_methods,
        "cyclomatic_complexity": total_complexity,
        "technical_debt_priority": debt_level,
        "files": file_results
    }