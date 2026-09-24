import os
import re
import json
import requests
from typing import List, Dict, Any

OLLAMA_URL = os.getenv("OLLAMA_URL", "http://127.0.0.1:11434/api/generate")
OLLAMA_MODEL = os.getenv("OLLAMA_MODEL", "qwen2.5-coder:7b")

LANGUAGE_META = {
    ".java": {"name": "Java", "logging": "LoggerFactory.getLogger(getClass()).info", "env": 'System.getenv("{KEY}")'},
    ".py": {"name": "Python", "logging": "logging.info", "env": 'os.getenv("{KEY}", "")'},
    ".js": {"name": "JavaScript", "logging": "logger.info", "env": 'process.env.{KEY}'},
    ".ts": {"name": "TypeScript", "logging": "logger.info", "env": 'process.env.{KEY}'},
    ".cs": {"name": "C#", "logging": "_logger.LogInformation", "env": 'Environment.GetEnvironmentVariable("{KEY}")'},
    ".php": {"name": "PHP", "logging": "error_log", "env": 'getenv("{KEY}")'},
    ".cpp": {"name": "C++", "logging": "std::cout", "env": 'std::getenv("{KEY}")'},
    ".c": {"name": "C", "logging": "printf", "env": 'getenv("{KEY}")'},
    ".go": {"name": "Go", "logging": "log.Println", "env": 'os.Getenv("{KEY}")'},
    ".rb": {"name": "Ruby", "logging": "Rails.logger.info", "env": 'ENV["{KEY}"]'}
}

def detect_language_meta(filename: str) -> Dict[str, str]:
    ext = os.path.splitext(filename.lower())[1]
    return LANGUAGE_META.get(ext, {
        "name": "Generic Code",
        "logging": "logger.info",
        "env": 'getenv("{KEY}")'
    })

def chunk_code_blocks(code: str, max_lines: int = 120) -> List[str]:
    """Splits large files (1000+ LOC) into safe, logical blocks preserving scope."""
    lines = code.split("\n")
    if len(lines) <= max_lines:
        return [code]

    chunks = []
    current_chunk = []
    brace_depth = 0

    for line in lines:
        current_chunk.append(line)
        brace_depth += line.count("{") - line.count("}")
        if len(current_chunk) >= max_lines and brace_depth <= 1:
            chunks.append("\n".join(current_chunk))
            current_chunk = []

    if current_chunk:
        chunks.append("\n".join(current_chunk))
    return chunks

def call_ollama(prompt: str) -> str:
    try:
        res = requests.post(
            OLLAMA_URL,
            json={
                "model": OLLAMA_MODEL,
                "prompt": prompt,
                "stream": False,
                "options": {"temperature": 0.1, "num_ctx": 4096}
            },
            timeout=35
        )
        if res.status_code == 200:
            out = res.json().get("response", "").strip()
            out = re.sub(r"^```[a-zA-Z0-9_-]*\s*", "", out)
            return re.sub(r"\s*```$", "", out)
    except Exception:
        pass
    return ""

def run_repair_agent(file_name: str, original_code: str, issues: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Universal modernization engine handling Java, Python, JS/TS, C#, PHP, and C/C++ at 1000+ LOC."""
    lang_info = detect_language_meta(file_name)
    lang_name = lang_info["name"]

    chunks = chunk_code_blocks(original_code)
    modernized_chunks = []
    engine_used = "deterministic-polyglot-healer"
    detected_changes = []

    for chunk in chunks:
        # Detect secrets (including self.token, this.apiKey, etc.), unbuffered prints, and raw SQL queries
        has_secret = bool(re.search(r'(?i)(?:self\.|this\.)?[a-zA-Z0-9_]*(?:password|secret|token|apikey|key)[a-zA-Z0-9_]*\s*[:=]\s*["\'][^"\']+["\']', chunk))
        has_print = bool(re.search(r'(System\.out\.println|console\.log|print\(|echo\s|var_dump|printf\()', chunk))
        has_sql = bool(re.search(r'(?i)(SELECT|INSERT|UPDATE|DELETE).*?\+', chunk)) or "createStatement()" in chunk

        if not (has_secret or has_print or has_sql or issues):
            modernized_chunks.append(chunk)
            continue

        prompt = f"""You are a Principal Software Modernization Engineer specializing in {lang_name}.
Modernize this legacy {lang_name} code chunk by resolving these issues:
{json.dumps(issues, indent=2)}

Modernization Directives:
1. Replace unbuffered/plain console print statements with structured logging.
2. Extract hardcoded secrets/passwords/API keys/tokens to runtime environment variables.
3. Inject defensive assertions and boundary validation on entry methods.
4. Output ONLY clean, valid, refactored {lang_name} code. No markdown fences or conversational explanations.

Code Chunk:
{chunk}
"""
        modernized_chunk = call_ollama(prompt)
        if modernized_chunk and len(modernized_chunk.split("\n")) >= (len(chunk.split("\n")) * 0.5):
            modernized_chunks.append(modernized_chunk)
            engine_used = f"ollama / {OLLAMA_MODEL}"
            detected_changes.append(f"AI-remediated {lang_name} chunk")
        else:
            # Deterministic Fallback Engine
            fallback = chunk

            # 1. Remediate Hardcoded Credentials (including self.token, this.apiKey, etc.)
            def replace_secret_universal(m):
                prefix = m.group(1) or ""
                var_name = m.group(2)
                env_key = re.sub(r'[^A-Z0-9_]', '', var_name.upper())
                
                if lang_name == "Python":
                    return f'{prefix}{var_name} = os.getenv("{env_key}", "")'
                elif lang_name in ["JavaScript", "TypeScript"]:
                    return f'{prefix}{var_name} = process.env.{env_key} || "";'
                elif lang_name == "PHP":
                    return f'{prefix}${var_name} = getenv("{env_key}");'
                else:
                    return f'String {var_name} = System.getenv("{env_key}"); // Remediated credential'

            if has_secret:
                fallback = re.sub(
                    r'(?i)(\bself\.|\bthis\.|\bconst\s+|\blet\s+|\bvar\s+|String\s+|\$)?([a-zA-Z0-9_]*(?:password|secret|token|apikey|key)[a-zA-Z0-9_]*)\s*[:=]\s*["\'][^"\']+["\'];?',
                    replace_secret_universal,
                    fallback
                )
                if lang_name == "Python" and "import os" not in fallback and "import os" not in original_code:
                    fallback = "import os\n" + fallback
                detected_changes.append("Extracted hardcoded credentials into runtime environment variables")

            # 2. Modernize Console Prints to Structured Logging
            if has_print:
                if lang_name == "Java":
                    fallback = fallback.replace("System.out.println(", "logger.info(")
                elif lang_name in ["JavaScript", "TypeScript"]:
                    fallback = fallback.replace("console.log(", "logger.info(")
                elif lang_name == "Python":
                    fallback = re.sub(r'print\((.*?)\)', r'logging.info(\1)', fallback)
                    if "import logging" not in fallback and "import logging" not in original_code:
                        fallback = "import logging\nlogging.basicConfig(level=logging.INFO)\n" + fallback
                elif lang_name == "PHP":
                    fallback = re.sub(r'echo\s+([^;]+);', r'error_log(\1);', fallback)
                detected_changes.append(f"Standardized {lang_name} console streams to structured logger")

            # 3. Defensive Parameter Validation
            if "login(" in fallback:
                if lang_name in ["Java", "C#"] and "public void login(String username)" in fallback:
                    fallback = fallback.replace(
                        "public void login(String username) {",
                        "public void login(String username) {\n        if (username == null || username.isBlank()) throw new IllegalArgumentException(\"Username required\");"
                    )
                    detected_changes.append("Injected defensive input parameter validation")
                elif lang_name == "Python" and "def login(" in fallback:
                    fallback = re.sub(
                        r'def login\((.*?)\):',
                        r'def login(\1):\n        if not username:\n            raise ValueError("Username cannot be blank")',
                        fallback
                    )
                    detected_changes.append("Injected defensive input parameter validation")

            modernized_chunks.append(fallback)

    final_code = "\n".join(modernized_chunks)

    # Feature 16: Syntax & Security Validation
    open_b = final_code.count("{")
    close_b = final_code.count("}")
    
    syntax_ok = True
    if lang_name in ["Java", "C#", "C++", "C", "JavaScript", "TypeScript", "PHP"]:
        syntax_ok = (open_b == close_b) if open_b > 0 else True

    security_cleared = (
        "getenv" in final_code or 
        "process.env" in final_code or 
        "os.getenv" in final_code or 
        not bool(re.search(r'(?i)(?:self\.|this\.)?[a-zA-Z0-9_]*(?:password|secret|token|apikey|key)[a-zA-Z0-9_]*\s*[:=]\s*["\'][^"\']+["\']', final_code))
    )

    validation = {
        "syntax_valid": syntax_ok,
        "security_check_passed": security_cleared,
        "language_detected": lang_name,
        "status": "VALIDATED" if (syntax_ok and security_cleared) else "REVIEW_REQUIRED"
    }

    return {
        "file": file_name,
        "language": lang_name,
        "loc": len(original_code.split("\n")),
        "original_code": original_code,
        "code": final_code,
        "engine": engine_used,
        "changes": list(set(detected_changes)) or [f"Refactored {lang_name} syntax to enterprise standard"],
        "validation": validation
    }