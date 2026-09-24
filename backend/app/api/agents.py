import os
import re
from fastapi import APIRouter, HTTPException
from app.agents.graph import build_agent_graph
from app.agents.repair_agent import run_repair_agent
from app.agents.testing_agent import run_testing_agent

router = APIRouter(prefix="/ai", tags=["Agents"])

UPLOAD_DIR = os.path.join(os.getcwd(), "uploads")

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

def extract_code_metadata(filename: str, code: str):
    ext = os.path.splitext(filename.lower())[1]
    lang = LANGUAGE_EXTENSIONS.get(ext, "generic")
    
    classes = []
    methods = []
    
    if lang in ["java", "csharp", "php"]:
        classes = re.findall(r"(?:class|interface)\s+([A-Za-z0-9_]+)", code)
        methods = re.findall(r"(?:public|protected|private|static)\s+[\w<>\[\]]+\s+([A-Za-z0-9_]+)\s*\(", code)
    elif lang == "python":
        classes = re.findall(r"class\s+([A-Za-z0-9_]+)", code)
        methods = re.findall(r"def\s+([A-Za-z0-9_]+)\s*\(", code)
    elif lang in ["javascript", "typescript"]:
        classes = re.findall(r"class\s+([A-Za-z0-9_]+)", code)
        matches = re.findall(r"(?:function\s+([A-Za-z0-9_]+)|([A-Za-z0-9_]+)\s*=\s*(?:async\s*)?\([^)]*\)\s*=>)", code)
        methods = [m[0] or m[1] for m in matches if (m[0] or m[1])]
    elif lang in ["c", "cpp"]:
        classes = re.findall(r"(?:class|struct)\s+([A-Za-z0-9_]+)", code)
        methods = re.findall(r"[\w*&]+\s+([A-Za-z0-9_]+)\s*\([^)]*\)\s*\{", code)
    elif lang == "go":
        classes = re.findall(r"type\s+([A-Za-z0-9_]+)\s+struct", code)
        methods = re.findall(r"func\s+(?:\([^)]+\)\s+)?([A-Za-z0-9_]+)\s*\(", code)
    else:
        classes = re.findall(r"class\s+([A-Za-z0-9_]+)", code)
        methods = re.findall(r"(?:def|func|function|\w+)\s+([A-Za-z0-9_]+)\s*\(", code)

    return {
        "filename": filename,
        "language": lang,
        "content": code,
        "classes": list(set(classes)),
        "methods": list(set(methods)),
        "loc": len(code.split("\n"))
    }


@router.get("/analyze/{project_id}")
def analyze_project(project_id: str):
    p_dir = os.path.join(UPLOAD_DIR, project_id)
    if not os.path.exists(p_dir):
        raise HTTPException(status_code=404, detail="Project ID not found")

    parsed_files = []

    # 1. Scan across all supported programming languages dynamically
    for root, _, files in os.walk(p_dir):
        for file in files:
            ext = os.path.splitext(file.lower())[1]
            if ext in LANGUAGE_EXTENSIONS:
                file_path = os.path.join(root, file)
                try:
                    with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                        code = f.read()
                    metadata = extract_code_metadata(file, code)
                    parsed_files.append(metadata)
                except Exception as e:
                    print(f"Error reading {file}: {e}")

    if not parsed_files:
        raise HTTPException(
            status_code=400, 
            detail="No supported source code files (Java, Python, JS/TS, C#, PHP, C/C++, Go) found in project"
        )

    # 2. Dynamic Polyglot Security Detection
    security_findings = []
    for item in parsed_files:
        code = item["content"]
        fn = item["filename"]
        lang = item["language"]

        # Hardcoded Credentials across all syntax variations (including self.token, this.apiKey)
        if re.search(r'(?i)(?:\bself\.|\bthis\.|\bconst\s+|\blet\s+|\bvar\s+|String\s+|\$)?([a-zA-Z0-9_]*(?:password|secret|token|apikey|key)[a-zA-Z0-9_]*)\s*[:=]\s*["\'][^"\']+["\']', code):
            security_findings.append({
                "file": fn,
                "language": lang,
                "severity": "HIGH",
                "issue": f"Hardcoded credential/secret token exposed in {fn}"
            })

        # SQL Injection & Raw Query Executions
        if re.search(r'(?i)(SELECT|INSERT|UPDATE|DELETE).*?\+', code) or \
           re.search(r'createStatement\s*\(\)', code) or "executeQuery" in code or "rawQuery" in code:
            security_findings.append({
                "file": fn,
                "language": lang,
                "severity": "HIGH",
                "issue": f"Potential SQL Injection: Unparameterized query execution in {fn}"
            })

        # Unbuffered Print / Console Logging
        has_print = (
            (lang == "java" and "System.out.println" in code) or
            (lang == "python" and re.search(r'\bprint\(', code)) or
            (lang in ["javascript", "typescript"] and "console.log" in code) or
            (lang == "php" and re.search(r'\b(echo|var_dump|print_r)\b', code)) or
            (lang in ["c", "cpp"] and "printf" in code)
        )
        if has_print:
            security_findings.append({
                "file": fn,
                "language": lang,
                "severity": "LOW",
                "issue": f"Legacy unbuffered console output detected in {fn}"
            })

    # 3. Agent State Initialization
    initial_state = {
        "project_id": project_id,
        "parsed_files": parsed_files,
        "code_analysis": [],
        "security_analysis": security_findings,
        "documentation": [],
        "tests": [],
        "modernization": [],
        "repairs": []
    }

    # 4. Invoke LangGraph Orchestrator with Deterministic Fallbacks
    try:
        agent_app = build_agent_graph()
        result_state = agent_app.invoke(initial_state)
    except Exception as e:
        print(f"LangGraph flow bypass triggered: {e}")
        result_state = initial_state

    # 5. Guarantee Validated Polyglot Repairs
    if not result_state.get("repairs"):
        repairs = []
        for pf in parsed_files:
            file_issues = [s for s in security_findings if s.get("file") == pf["filename"]]
            rep = run_repair_agent(pf["filename"], pf["content"], file_issues)
            repairs.append(rep)
        result_state["repairs"] = repairs

    # 6. Guarantee Validated Polyglot Test Suites
    if not result_state.get("tests") or not any(t.get("code") for t in result_state.get("tests", [])):
        test_state = run_testing_agent({"parsed_files": parsed_files, "code_analysis": result_state.get("code_analysis", [])})
        result_state["tests"] = test_state.get("tests", [])

    # Ensure security findings are explicitly attached to final payload
    if not result_state.get("security_analysis"):
        result_state["security_analysis"] = security_findings

    return result_state