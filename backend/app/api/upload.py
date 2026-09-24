from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.upload_service import save_project
from app.utils.file_tree import generate_tree
import os

router = APIRouter()

UPLOAD_DIR = "uploads"


@router.post("/upload")
async def upload_project(file: UploadFile = File(...)):
    if not file.filename.endswith(".zip"):
        raise HTTPException(status_code=400, detail="Only ZIP files are allowed.")

    result = save_project(file)

    return {
        "message": "Project uploaded successfully",
        **result
    }


@router.get("/project/{project_id}")
def get_project(project_id: str):

    project_path = os.path.join(UPLOAD_DIR, project_id)

    if not os.path.exists(project_path):
        raise HTTPException(status_code=404, detail="Project not found")

    return generate_tree(project_path)