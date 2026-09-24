from typing import Dict, Any

def run_code_agent(state: Dict[str, Any]) -> Dict[str, Any]:
    findings = []
    parsed_files = state.get("parsed_files", [])

    for file_info in parsed_files:
        filename = file_info.get("filename", "Unknown")
        classes = file_info.get("classes", [])
        methods = file_info.get("methods", [])
        
        findings.append({
            "file": filename,
            "classes_count": len(classes),
            "methods_count": len(methods),
            "status": "analyzed",
            "summary": f"Identified {len(classes)} classes and {len(methods)} methods."
        })

    state["code_analysis"] = findings
    return state

# Alias for compatibility
code_agent = run_code_agent