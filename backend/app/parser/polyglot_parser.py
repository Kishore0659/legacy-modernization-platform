import os
import re
from typing import Dict, Any, List

LANGUAGE_EXTENSIONS = {
    ".java": "java",
    ".py": "python",
    ".js": "javascript",
    ".ts": "typescript",
    ".cs": "csharp",
    ".cpp": "cpp",
    ".c": "c",
    ".php": "php",
    ".go": "go",
    ".rb": "ruby"
}

def detect_language(filename: str) -> str:
    _, ext = os.path.splitext(filename.lower())
    return LANGUAGE_EXTENSIONS.get(ext, "generic")

def parse_polyglot_file(filename: str, content: str) -> Dict[str, Any]:
    lang = detect_language(filename)
    classes = []
    methods = []
    dependencies = []
    security_findings = []

    lines = content.split("\n")
    loc = len(lines)

    # 1. Classes & Structures
    if lang in ["java", "csharp", "php"]:
        classes = re.findall(r"(?:class|interface|enum)\s+([A-Za-z0-9_]+)", content)
    elif lang == "python":
        classes = re.findall(r"class\s+([A-Za-z0-9_]+)", content)
    elif lang in ["javascript", "typescript"]:
        classes = re.findall(r"class\s+([A-Za-z0-9_]+)", content)
    elif lang in ["c", "cpp"]:
        classes = re.findall(r"(?:class|struct)\s+([A-Za-z0-9_]+)", content)
    elif lang == "go":
        classes = re.findall(r"type\s+([A-Za-z0-9_]+)\s+struct", content)

    # 2. Functions / Methods
    if lang in ["java", "csharp"]:
        methods = re.findall(r"(?:public|protected|private|static|\s)+\s+[\w<>\[\]]+\s+([A-Za-z0-9_]+)\s*\(", content)
    elif lang == "python":
        methods = re.findall(r"def\s+([A-Za-z0-9_]+)\s*\(", content)
    elif lang in ["javascript", "typescript"]:
        methods = re.findall(r"(?:function\s+([A-Za-z0-9_]+)|([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>)", content)
        methods = [m[0] or m[1] for m in methods if (m[0] or m[1])]
    elif lang == "php":
        methods = re.findall(r"function\s+([A-Za-z0-9_]+)\s*\(", content)
    elif lang == "go":
        methods = re.findall(r"func\s+(?:\([^)]+\)\s+)?([A-Za-z0-9_]+)\s*\(", content)
    elif lang in ["c", "cpp"]:
        methods = re.findall(r"[\w*&]+\s+([A-Za-z0-9_]+)\s*\([^)]*\)\s*\{", content)

    # 3. Imports & Dependencies
    if lang in ["java", "csharp"]:
        dependencies = re.findall(r"(?:import|using)\s+([A-Za-z0-9_.]+);?", content)
    elif lang == "python":
        dependencies = re.findall(r"(?:from\s+([A-Za-z0-9_.]+)\s+import|import\s+([A-Za-z0-9_.]+))", content)
        dependencies = [d[0] or d[1] for d in dependencies if (d[0] or d[1])]
    elif lang in ["javascript", "typescript"]:
        dependencies = re.findall(r"(?:import.*?from\s+['\"](.*?)['\"]|require\(['\"](.*?)['\"]\))", content)
        dependencies = [d[0] or d[1] for d in dependencies if (d[0] or d[1])]
    elif lang == "php":
        dependencies = re.findall(r"(?:use|require|include)(?:_once)?\s+['\"]?([A-Za-z0-9_./\\]+)['\"]?;?", content)
    elif lang in ["c", "cpp"]:
        dependencies = re.findall(r"#include\s+[<\"]([^>\"]+)[>\"]", content)
    elif lang == "go":
        dependencies = re.findall(r"import\s+(?:\(\s*([^)]+)\s*\)|['\"](.*?)['\"])", content)

    # 4. Universal & Language-Specific Security Checks
    # Passwords/Secrets
    if re.search(r'(?i)(password|secret|apikey|access_token|private_key)\s*[:=]\s*["\'][^"\']+["\']', content):
        security_findings.append({
            "file": filename,
            "language": lang,
            "severity": "HIGH",
            "issue": f"Hardcoded secret/credential exposed in {filename}"
        })

    # Unbuffered prints / direct logging
    if (lang == "java" and "System.out.println" in content) or \
       (lang == "python" and re.search(r'\bprint\(', content)) or \
       (lang in ["javascript", "typescript"] and "console.log" in content) or \
       (lang == "php" and re.search(r'\b(echo|var_dump|print_r)\b', content)) or \
       (lang in ["c", "cpp"] and "printf" in content):
        security_findings.append({
            "file": filename,
            "language": lang,
            "severity": "LOW",
            "issue": f"Legacy unbuffered console logging identified in {filename}"
        })

    # SQL Injection Risks
    if re.search(r'(?i)(SELECT|INSERT|UPDATE|DELETE).*?\+.*?(req|request|param|user|input)', content) or \
       "createStatement()" in content or "rawQuery" in content:
        security_findings.append({
            "file": filename,
            "language": lang,
            "severity": "HIGH",
            "issue": f"Potential unparameterized SQL Injection vulnerability in {filename}"
        })

    return {
        "filename": filename,
        "language": lang,
        "content": content,
        "loc": loc,
        "classes": list(set(classes)),
        "methods": list(set(methods)),
        "dependencies": list(set(dependencies))[:15],
        "security_findings": security_findings
    }