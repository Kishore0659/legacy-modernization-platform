def security_agent(state):

    parsed_files = state.get("parsed_files", [])

    findings = []

    for file_data in parsed_files:

        file_path = file_data.get("path")

        try:
            with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
                source_code = f.read()
        except Exception:
            continue

        source_lower = source_code.lower()

        # Hardcoded password
        if "password =" in source_lower:
            findings.append({
                "file": file_data.get("file"),
                "severity": "HIGH",
                "type": "Hardcoded Credential",
                "description": "Possible hardcoded password detected.",
                "recommendation": "Use environment variables or a secure secret manager."
            })

        # SQL injection indicators
        if "statement.execute(" in source_lower:
            findings.append({
                "file": file_data.get("file"),
                "severity": "HIGH",
                "type": "SQL Injection Risk",
                "description": "Direct SQL execution detected.",
                "recommendation": "Use parameterized queries or prepared statements."
            })

        # Weak authentication
        if "authenticate" in source_lower and "password" in source_lower:
            findings.append({
                "file": file_data.get("file"),
                "severity": "MEDIUM",
                "type": "Authentication Review",
                "description": "Authentication logic requires security review.",
                "recommendation": "Use secure password hashing and established authentication frameworks."
            })

    state["security_analysis"] = findings

    return state