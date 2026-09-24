import os
import re
from fastapi import APIRouter

router = APIRouter()
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

IGNORE_TYPES = {
    "String", "Integer", "Long", "Double", "Float", "Boolean",
    "List", "Map", "Set", "ArrayList", "HashMap", "HashSet",
    "int", "long", "double", "float", "boolean", "char", "void",
    "Object", "Exception", "var", "let", "const"
}


@router.get("/graph/{project_id}")
def get_graph_data(project_id: str):
    p_dir = os.path.join(UPLOAD_DIR, project_id)
    nodes = []
    edges = []
    seen_nodes = set()

    if os.path.exists(p_dir):
        for root, _, files in os.walk(p_dir):
            for file in files:
                ext = os.path.splitext(file.lower())[1]
                if ext not in LANGUAGE_EXTENSIONS:
                    continue

                lang = LANGUAGE_EXTENSIONS[ext]
                fpath = os.path.join(root, file)
                try:
                    with open(fpath, "r", encoding="utf-8", errors="ignore") as f:
                        code = f.read()
                except Exception:
                    continue

                file_base = os.path.splitext(file)[0]
                primary_entity = file_base

                # --- 1. JAVA, C#, PHP ---
                if lang in ["java", "csharp", "php"]:
                    classes = re.findall(
                        r"(?:public\s+|abstract\s+)?class\s+(\w+)(?:\s+extends\s+(\w+))?(?:\s+implements\s+([\w\s,]+))?",
                        code
                    )
                    for cls_match in classes:
                        cls_name, base_cls, interfaces = cls_match[0], cls_match[1], cls_match[2]
                        primary_entity = cls_name

                        if cls_name and cls_name not in seen_nodes:
                            nodes.append({"id": cls_name, "label": cls_name, "type": "Class"})
                            seen_nodes.add(cls_name)

                        if base_cls:
                            if base_cls not in seen_nodes:
                                nodes.append({"id": base_cls, "label": base_cls, "type": "SuperClass"})
                                seen_nodes.add(base_cls)
                            edges.append({"source": cls_name, "target": base_cls, "label": "EXTENDS"})

                        if interfaces:
                            for iface in interfaces.split(","):
                                iface = iface.strip()
                                if iface and iface not in seen_nodes:
                                    nodes.append({"id": iface, "label": iface, "type": "Interface"})
                                    seen_nodes.add(iface)
                                if iface:
                                    edges.append({"source": cls_name, "target": iface, "label": "IMPLEMENTS"})

                    # Fields & Dependencies
                    fields = re.findall(r"(?:private|protected|public)\s+([A-Z]\w+)\s+\w+;", code)
                    for dep in fields:
                        if dep not in IGNORE_TYPES:
                            if dep not in seen_nodes:
                                nodes.append({"id": dep, "label": dep, "type": "Dependency"})
                                seen_nodes.add(dep)
                            if primary_entity:
                                edges.append({"source": primary_entity, "target": dep, "label": "DEPENDS_ON"})

                # --- 2. PYTHON ---
                elif lang == "python":
                    py_classes = re.findall(r"class\s+([A-Za-z0-9_]+)(?:\(([^)]+)\))?:", code)
                    if py_classes:
                        for cls_name, bases in py_classes:
                            primary_entity = cls_name
                            if cls_name not in seen_nodes:
                                nodes.append({"id": cls_name, "label": cls_name, "type": "Class"})
                                seen_nodes.add(cls_name)

                            if bases:
                                for base in bases.split(","):
                                    base = base.strip()
                                    if base and base != "object":
                                        if base not in seen_nodes:
                                            nodes.append({"id": base, "label": base, "type": "SuperClass"})
                                            seen_nodes.add(base)
                                        edges.append({"source": cls_name, "target": base, "label": "INHERITS"})
                    else:
                        if file_base not in seen_nodes:
                            nodes.append({"id": file_base, "label": file_base, "type": "Module"})
                            seen_nodes.add(file_base)

                    # Python Imports
                    imports = re.findall(r"(?:from\s+([A-Za-z0-9_]+)\s+import|import\s+([A-Za-z0-9_]+))", code)
                    for imp_from, imp_dir in imports:
                        dep = imp_from or imp_dir
                        if dep and dep not in ["os", "sys", "re", "json", "typing"]:
                            if dep not in seen_nodes:
                                nodes.append({"id": dep, "label": dep, "type": "Module"})
                                seen_nodes.add(dep)
                            edges.append({"source": primary_entity, "target": dep, "label": "IMPORTS"})

                # --- 3. JAVASCRIPT & TYPESCRIPT ---
                elif lang in ["javascript", "typescript"]:
                    js_classes = re.findall(r"class\s+([A-Za-z0-9_]+)(?:\s+extends\s+([A-Za-z0-9_]+))?", code)
                    if js_classes:
                        for cls_name, base_cls in js_classes:
                            primary_entity = cls_name
                            if cls_name not in seen_nodes:
                                nodes.append({"id": cls_name, "label": cls_name, "type": "Class"})
                                seen_nodes.add(cls_name)

                            if base_cls:
                                if base_cls not in seen_nodes:
                                    nodes.append({"id": base_cls, "label": base_cls, "type": "SuperClass"})
                                    seen_nodes.add(base_cls)
                                edges.append({"source": cls_name, "target": base_cls, "label": "EXTENDS"})
                    else:
                        if file_base not in seen_nodes:
                            nodes.append({"id": file_base, "label": file_base, "type": "Module"})
                            seen_nodes.add(file_base)

                    # JS/TS Imports
                    imports = re.findall(r"(?:import.*?from\s+['\"](?:[./]*)([\w-]+)['\"]|require\(['\"](?:[./]*)([\w-]+)['\"]\))", code)
                    for imp1, imp2 in imports:
                        dep = imp1 or imp2
                        if dep:
                            if dep not in seen_nodes:
                                nodes.append({"id": dep, "label": dep, "type": "Package"})
                                seen_nodes.add(dep)
                            edges.append({"source": primary_entity, "target": dep, "label": "IMPORTS"})

                # --- 4. C, C++, GO & OTHER COMPILED LANGUAGES ---
                elif lang in ["c", "cpp", "go"]:
                    if lang == "go":
                        structs = re.findall(r"type\s+([A-Za-z0-9_]+)\s+struct", code)
                    else:
                        structs = re.findall(r"(?:class|struct)\s+([A-Za-z0-9_]+)", code)

                    if structs:
                        for s in structs:
                            if s not in seen_nodes:
                                nodes.append({"id": s, "label": s, "type": "Struct/Class"})
                                seen_nodes.add(s)
                    else:
                        if file_base not in seen_nodes:
                            nodes.append({"id": file_base, "label": file_base, "type": "SourceFile"})
                            seen_nodes.add(file_base)

    if not nodes:
        nodes = [{"id": "ProjectRoot", "label": "ProjectRoot", "type": "MonolithicApplication"}]

    return {"project_id": project_id, "nodes": nodes, "edges": edges}