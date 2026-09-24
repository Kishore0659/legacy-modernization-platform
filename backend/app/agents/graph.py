from langgraph.graph import StateGraph, END
from app.agents.state import AgentState
from app.agents.repair_agent import run_repair_agent

# Safe imports with fallback functions in case agent function names differ
try:
    from app.agents.code_agent import run_code_agent as code_node
except ImportError:
    try:
        from app.agents.code_agent import code_agent as code_node
    except ImportError:
        def code_node(state): return state

try:
    from app.agents.security_agent import run_security_agent as security_node
except ImportError:
    try:
        from app.agents.security_agent import security_agent as security_node
    except ImportError:
        def security_node(state): return state

try:
    from app.agents.documentation_agent import run_documentation_agent as doc_node
except ImportError:
    try:
        from app.agents.documentation_agent import documentation_agent as doc_node
    except ImportError:
        def doc_node(state): return state

try:
    from app.agents.testing_agent import run_testing_agent as test_node
except ImportError:
    try:
        from app.agents.testing_agent import testing_agent as test_node
    except ImportError:
        def test_node(state): return state

try:
    from app.agents.modernization_agent import run_modernization_agent as mod_node
except ImportError:
    try:
        from app.agents.modernization_agent import modernization_agent as mod_node
    except ImportError:
        def mod_node(state): return state

def repair_node(state: AgentState) -> AgentState:
    repairs = []
    issues_by_file = {}

    for item in state.get("modernization", []):
        fn = item.get("file", "General")
        issues_by_file.setdefault(fn, []).append(item)

    for item in state.get("security_analysis", []):
        fn = item.get("file", "General")
        issues_by_file.setdefault(fn, []).append(item)

    for f in state.get("parsed_files", []):
        filename = f.get("filename")
        code = f.get("content", "")
        issues = issues_by_file.get(filename, [])
        if issues or "password" in code.lower() or "System.out.println" in code:
            res = run_repair_agent(filename, code, issues)
            repairs.append(res)

    state["repairs"] = repairs
    return state

def build_agent_graph():
    workflow = StateGraph(AgentState)

    workflow.add_node("code_agent", code_node)
    workflow.add_node("security_agent", security_node)
    workflow.add_node("documentation_agent", doc_node)
    workflow.add_node("testing_agent", test_node)
    workflow.add_node("modernization_agent", mod_node)
    workflow.add_node("repair_agent", repair_node)

    workflow.set_entry_point("code_agent")
    workflow.add_edge("code_agent", "security_agent")
    workflow.add_edge("security_agent", "documentation_agent")
    workflow.add_edge("documentation_agent", "testing_agent")
    workflow.add_edge("testing_agent", "modernization_agent")
    workflow.add_edge("modernization_agent", "repair_agent")
    workflow.add_edge("repair_agent", END)

    return workflow.compile()

app_graph = build_agent_graph()