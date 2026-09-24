import os
import re


def count_lines(file_path):
    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
        lines = f.readlines()

    total_lines = len(lines)

    code_lines = 0
    comment_lines = 0
    blank_lines = 0

    for line in lines:
        stripped = line.strip()

        if not stripped:
            blank_lines += 1

        elif stripped.startswith("//"):
            comment_lines += 1

        else:
            code_lines += 1

    return {
        "total_lines": total_lines,
        "code_lines": code_lines,
        "comment_lines": comment_lines,
        "blank_lines": blank_lines
    }


def calculate_cyclomatic_complexity(source_code):
    complexity = 1

    patterns = [
        r"\bif\b",
        r"\bfor\b",
        r"\bwhile\b",
        r"\bcase\b",
        r"\bcatch\b",
        r"\?",
        r"&&",
        r"\|\|"
    ]

    for pattern in patterns:
        complexity += len(
            re.findall(pattern, source_code)
        )

    return complexity


def calculate_file_metrics(file_path):

    with open(
        file_path,
        "r",
        encoding="utf-8",
        errors="ignore"
    ) as f:

        source_code = f.read()

    line_metrics = count_lines(file_path)

    classes = len(
        re.findall(
            r"\bclass\s+\w+",
            source_code
        )
    )

    methods = len(
        re.findall(
            r"\b(?:public|private|protected)?\s*"
            r"(?:static\s+)?"
            r"\w+(?:<[^>]+>)?\s+\w+\s*"
            r"\([^)]*\)\s*\{",
            source_code
        )
    )

    fields = len(
        re.findall(
            r"\b(?:private|public|protected)?\s*"
            r"(?:static\s+)?"
            r"\w+(?:<[^>]+>)?\s+\w+\s*(?:=|;)",
            source_code
        )
    )

    imports = len(
        re.findall(
            r"^\s*import\s+",
            source_code,
            re.MULTILINE
        )
    )

    complexity = calculate_cyclomatic_complexity(
        source_code
    )

    return {
        "file": os.path.basename(file_path),
        "lines": line_metrics,
        "classes": classes,
        "methods": methods,
        "fields": fields,
        "imports": imports,
        "cyclomatic_complexity": complexity
    }