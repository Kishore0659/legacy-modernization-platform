def build_class_index(parsed_files):
    class_index = {}

    for file_data in parsed_files:
        analysis = file_data.get("analysis", {})

        for class_data in analysis.get("classes", []):
            class_name = class_data.get("name")

            if class_name:
                class_index[class_name] = {
                    "file": file_data.get("path"),
                    "package": analysis.get("package")
                }

    return class_index


def extract_dependencies(parsed_files):

    class_index = build_class_index(parsed_files)

    dependencies = []

    for file_data in parsed_files:

        analysis = file_data.get("analysis", {})
        source_file = file_data.get("path")

        for class_data in analysis.get("classes", []):

            source_class = class_data.get("name")

            if not source_class:
                continue

            # -----------------------------
            # EXTENDS
            # -----------------------------

            parent = class_data.get("extends")

            if parent:

                dependencies.append({
                    "source": source_class,
                    "target": parent,
                    "type": "EXTENDS",
                    "internal": parent in class_index,
                    "source_file": source_file
                })

            # -----------------------------
            # IMPLEMENTS
            # -----------------------------

            for interface in class_data.get(
                "implements",
                []
            ):

                dependencies.append({
                    "source": source_class,
                    "target": interface,
                    "type": "IMPLEMENTS",
                    "internal": interface in class_index,
                    "source_file": source_file
                })

            # -----------------------------
            # IMPORTS
            # -----------------------------

            for imported_class in analysis.get(
                "imports",
                []
            ):

                dependencies.append({
                    "source": source_class,
                    "target": imported_class,
                    "type": "IMPORTS",
                    "internal": False,
                    "source_file": source_file
                })

            # -----------------------------
            # METHOD CALLS
            # -----------------------------

            for method in class_data.get(
                "methods",
                []
            ):

                for call in method.get(
                    "calls",
                    []
                ):

                    dependencies.append({
                        "source": source_class,
                        "target": call,
                        "type": "CALLS",
                        "method": method.get("name"),
                        "internal": False,
                        "source_file": source_file
                    })

    return dependencies