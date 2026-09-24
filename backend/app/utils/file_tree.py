import os

def generate_tree(path):
    """
    Recursively generates a folder/file tree.
    """

    node = {
        "name": os.path.basename(path),
        "type": "folder" if os.path.isdir(path) else "file"
    }

    if os.path.isdir(path):
        node["children"] = []

        for item in sorted(os.listdir(path)):
            item_path = os.path.join(path, item)
            node["children"].append(generate_tree(item_path))

    return node