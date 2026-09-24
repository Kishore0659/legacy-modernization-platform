import os
import uuid
import zipfile
import shutil

UPLOAD_DIR = "uploads"


def save_project(file):
    # Create uploads folder if it doesn't exist
    os.makedirs(UPLOAD_DIR, exist_ok=True)

    # Generate unique project ID
    project_id = str(uuid.uuid4())

    # Create project folder
    project_folder = os.path.join(UPLOAD_DIR, project_id)
    os.makedirs(project_folder, exist_ok=True)

    # Save uploaded ZIP
    zip_path = os.path.join(project_folder, file.filename)

    with open(zip_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    # Extract ZIP
    with zipfile.ZipFile(zip_path, "r") as zip_ref:
        zip_ref.extractall(project_folder)

    # Delete ZIP after extraction
    os.remove(zip_path)

    return {
        "project_id": project_id,
        "project_name": file.filename.replace(".zip", ""),
        "location": project_folder
    }