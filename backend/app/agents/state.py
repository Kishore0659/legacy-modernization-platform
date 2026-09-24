from typing import TypedDict, List, Dict, Any

class AgentState(TypedDict):
    project_id: str
    parsed_files: List[Dict[str, Any]]
    code_analysis: List[Dict[str, Any]]
    security_analysis: List[Dict[str, Any]]
    documentation: List[Dict[str, Any]]
    tests: List[Dict[str, Any]]
    modernization: List[Dict[str, Any]]
    repairs: List[Dict[str, Any]]