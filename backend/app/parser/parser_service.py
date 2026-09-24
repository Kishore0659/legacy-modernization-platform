import os

from app.parser.java_parser import parse_java_file


def scan_project(project_path):

    parsed_files = []

    for root, dirs, files in os.walk(project_path):

        for file in files:

            if file.endswith(".java"):

                full_path = os.path.join(root, file)

                parsed_data = parse_java_file(full_path)

                parsed_files.append({
                    "file": file,
                    "path": full_path,
                    "analysis": parsed_data
                })

    return parsed_files