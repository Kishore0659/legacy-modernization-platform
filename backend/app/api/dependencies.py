from fastapi import APIRouter, HTTPException
import os

from app.parser.parser_service import scan_project
from app.analyzer.dependency_analyzer import extract_dependencies


router = APIRouter()


@router.get("/dependencies/{project_id}")
def get_dependencies(project_id: str):

    project_path = os.path.join(
        "uploads",
        project_id
    )

    if not os.path.exists(project_path):
        raise HTTPException(
            status_code=404,
            detail="Project not found"
        )

    # Parse the uploaded project
    parsed_files = scan_project(project_path)

    # Extract dependencies
    dependencies = extract_dependencies(
        parsed_files
    )

    return dependencies