def documentation_agent(state):

    code_analysis = state.get("code_analysis", [])

    documentation = []

    for file_data in code_analysis:

        file_doc = {
            "file": file_data.get("file"),
            "classes": []
        }

        for cls in file_data.get("classes", []):

            class_doc = {
                "class_name": cls.get("name"),
                "description": (
                    f"Class {cls.get('name')} "
                    f"contains {cls.get('method_count', 0)} methods."
                ),
                "extends": cls.get("extends"),
                "implements": cls.get("implements", []),
                "methods": []
            }

            for method in cls.get("methods", []):

                class_doc["methods"].append({
                    "name": method.get("name"),
                    "description": (
                        f"Method {method.get('name')} "
                        f"returns {method.get('return_type')}."
                    ),
                    "parameters": method.get("parameters", []),
                    "calls": method.get("calls", [])
                })

            file_doc["classes"].append(class_doc)

        documentation.append(file_doc)

    state["documentation"] = documentation

    return state