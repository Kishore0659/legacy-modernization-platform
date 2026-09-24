from fastapi import APIRouter, HTTPException
from app.parser.parser_service import scan_project
import os

router = APIRouter()

UPLOAD_DIR = "uploads"


@router.get("/parse/{project_id}")
def parse_project(project_id: str):

    project_path = os.path.join(UPLOAD_DIR, project_id)

    if not os.path.exists(project_path):
        raise HTTPException(status_code=404, detail="Project not found")

    return scan_project(project_path)