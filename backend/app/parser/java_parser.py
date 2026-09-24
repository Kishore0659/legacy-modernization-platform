from tree_sitter import Language, Parser
import tree_sitter_java


# ============================================================
# Java Tree-sitter Language
# ============================================================

JAVA_LANGUAGE = Language(tree_sitter_java.language())


# ============================================================
# Parser
# ============================================================

def create_parser():
    parser = Parser()
    parser.language = JAVA_LANGUAGE
    return parser


# ============================================================
# Utility
# ============================================================

def get_node_text(node, source_code):
    if node is None:
        return None

    return source_code[
        node.start_byte:node.end_byte
    ].decode(
        "utf-8",
        errors="ignore"
    )


# ============================================================
# Parameters
# ============================================================

def extract_parameters(parameters_node, source_code):

    parameters = []

    if not parameters_node:
        return parameters

    for child in parameters_node.named_children:

        # Normal parameter
        if child.type == "formal_parameter":

            type_node = child.child_by_field_name("type")
            name_node = child.child_by_field_name("name")

            parameters.append({
                "name": (
                    get_node_text(name_node, source_code)
                    if name_node
                    else None
                ),

                "type": (
                    get_node_text(type_node, source_code)
                    if type_node
                    else None
                )
            })

        # Varargs parameter
        elif child.type == "spread_parameter":

            type_node = child.child_by_field_name("type")
            name_node = child.child_by_field_name("name")

            parameters.append({
                "name": (
                    get_node_text(name_node, source_code)
                    if name_node
                    else None
                ),

                "type": (
                    get_node_text(type_node, source_code)
                    if type_node
                    else None
                )
            })

    return parameters


# ============================================================
# Method Calls
# ============================================================

def extract_method_calls(node, source_code):

    calls = []

    def walk(current_node):

        if current_node.type == "method_invocation":

            name_node = current_node.child_by_field_name("name")

            if name_node:

                calls.append(
                    get_node_text(
                        name_node,
                        source_code
                    )
                )

        for child in current_node.named_children:
            walk(child)

    walk(node)

    # Remove duplicates while preserving order
    return list(dict.fromkeys(calls))


# ============================================================
# Fields
# ============================================================

def extract_fields(body_node, source_code):

    fields = []

    if not body_node:
        return fields

    for child in body_node.named_children:

        if child.type != "field_declaration":
            continue

        type_node = child.child_by_field_name("type")

        field_type = (
            get_node_text(
                type_node,
                source_code
            )
            if type_node
            else None
        )

        for declarator in child.named_children:

            if declarator.type != "variable_declarator":
                continue

            name_node = declarator.child_by_field_name("name")

            if name_node:

                fields.append({
                    "name": get_node_text(
                        name_node,
                        source_code
                    ),

                    "type": field_type
                })

    return fields


# ============================================================
# Constructor
# ============================================================

def extract_constructor(
    constructor_node,
    source_code
):

    name_node = constructor_node.child_by_field_name(
        "name"
    )

    parameters_node = constructor_node.child_by_field_name(
        "parameters"
    )

    return {
        "name": (
            get_node_text(
                name_node,
                source_code
            )
            if name_node
            else None
        ),

        "parameters": extract_parameters(
            parameters_node,
            source_code
        )
    }


# ============================================================
# Method
# ============================================================

def extract_method(
    method_node,
    source_code
):

    name_node = method_node.child_by_field_name(
        "name"
    )

    return_type_node = method_node.child_by_field_name(
        "type"
    )

    parameters_node = method_node.child_by_field_name(
        "parameters"
    )

    return {
        "name": (
            get_node_text(
                name_node,
                source_code
            )
            if name_node
            else None
        ),

        "return_type": (
            get_node_text(
                return_type_node,
                source_code
            )
            if return_type_node
            else None
        ),

        "parameters": extract_parameters(
            parameters_node,
            source_code
        ),

        "calls": extract_method_calls(
            method_node,
            source_code
        )
    }


# ============================================================
# Class
# ============================================================

def extract_class(
    class_node,
    source_code
):

    class_name_node = class_node.child_by_field_name(
        "name"
    )

    class_info = {

        "name": (
            get_node_text(
                class_name_node,
                source_code
            )
            if class_name_node
            else None
        ),

        "extends": None,

        "implements": [],

        "fields": [],

        "constructors": [],

        "methods": []
    }

    # --------------------------------------------------------
    # Superclass
    # --------------------------------------------------------

    superclass_node = class_node.child_by_field_name(
        "superclass"
    )

    if superclass_node:

        superclass_text = get_node_text(
            superclass_node,
            source_code
        )

        class_info["extends"] = (
            superclass_text
            .replace("extends ", "")
            .strip()
        )

    # --------------------------------------------------------
    # Interfaces
    # --------------------------------------------------------

    interfaces_node = class_node.child_by_field_name(
        "interfaces"
    )

    if interfaces_node:

        for child in interfaces_node.named_children:

            text = get_node_text(
                child,
                source_code
            ).strip()

            if text:
                class_info["implements"].append(
                    text
                )

    # --------------------------------------------------------
    # Class Body
    # --------------------------------------------------------

    body_node = class_node.child_by_field_name(
        "body"
    )

    if not body_node:
        return class_info

    # --------------------------------------------------------
    # Fields
    # --------------------------------------------------------

    class_info["fields"] = extract_fields(
        body_node,
        source_code
    )

    # --------------------------------------------------------
    # Methods and Constructors
    # --------------------------------------------------------

    for child in body_node.named_children:

        if child.type == "method_declaration":

            class_info["methods"].append(
                extract_method(
                    child,
                    source_code
                )
            )

        elif child.type == "constructor_declaration":

            class_info["constructors"].append(
                extract_constructor(
                    child,
                    source_code
                )
            )

    return class_info


# ============================================================
# Java File Parser
# ============================================================

def parse_java_file(file_path):

    with open(
        file_path,
        "rb"
    ) as file:

        source_code = file.read()

    parser = create_parser()

    tree = parser.parse(
        source_code
    )

    root = tree.root_node

    result = {

        "language": "java",

        "package": None,

        "imports": [],

        "classes": []
    }

    # ========================================================
    # Top-level declarations
    # ========================================================

    for node in root.named_children:

        # ----------------------------------------------------
        # Package
        # ----------------------------------------------------

        if node.type == "package_declaration":

            name_node = node.child_by_field_name(
                "name"
            )

            if name_node:

                result["package"] = get_node_text(
                    name_node,
                    source_code
                )

        # ----------------------------------------------------
        # Import
        # ----------------------------------------------------

        elif node.type == "import_declaration":

            import_text = get_node_text(
                node,
                source_code
            )

            import_text = (
                import_text
                .replace("import ", "")
                .replace(";", "")
                .strip()
            )

            result["imports"].append(
                import_text
            )

        # ----------------------------------------------------
        # Class
        # ----------------------------------------------------

        elif node.type == "class_declaration":

            result["classes"].append(
                extract_class(
                    node,
                    source_code
                )
            )

    return result

