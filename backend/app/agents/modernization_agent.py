def modernization_agent(state):

    code_analysis = state.get("code_analysis", [])
    security_analysis = state.get("security_analysis", [])
    tests = state.get("tests", [])

    recommendations = []

    for file_data in code_analysis:

        file_name = file_data.get("file")

        for cls in file_data.get("classes", []):

            class_name = cls.get("name")
            methods = cls.get("methods", [])
            fields = cls.get("fields", [])

            # Large class
            if len(methods) >= 10:
                recommendations.append({
                    "file": file_name,
                    "class": class_name,
                    "priority": "HIGH",
                    "category": "Architecture",
                    "issue": "Class contains a large number of methods.",
                    "recommendation": (
                        "Consider splitting the class into smaller "
                        "single-responsibility components."
                    )
                })

            # Multiple responsibilities
            if len(methods) >= 5 and len(fields) >= 2:
                recommendations.append({
                    "file": file_name,
                    "class": class_name,
                    "priority": "MEDIUM",
                    "category": "Maintainability",
                    "issue": "Class may contain multiple responsibilities.",
                    "recommendation": (
                        "Review the class for separation of responsibilities "
                        "and consider applying the Single Responsibility Principle."
                    )
                })

            # Inheritance
            if cls.get("extends"):
                recommendations.append({
                    "file": file_name,
                    "class": class_name,
                    "priority": "LOW",
                    "category": "Architecture",
                    "issue": f"Class inherits from {cls.get('extends')}.",
                    "recommendation": (
                        "Review whether inheritance is necessary and "
                        "whether composition would provide better flexibility."
                    )
                })

            # Methods with many calls
            for method in methods:

                calls = method.get("calls", [])

                if len(calls) >= 4:
                    recommendations.append({
                        "file": file_name,
                        "class": class_name,
                        "method": method.get("name"),
                        "priority": "MEDIUM",
                        "category": "Complexity",
                        "issue": "Method has a high number of method calls.",
                        "recommendation": (
                            "Review the method and consider extracting "
                            "independent operations into separate methods."
                        )
                    })

    # Security findings
    for finding in security_analysis:

        recommendations.append({
            "file": finding.get("file"),
            "priority": finding.get("severity", "MEDIUM"),
            "category": "Security",
            "issue": finding.get("description"),
            "recommendation": finding.get("recommendation")
        })

    # Testing coverage suggestions
    if tests:

        recommendations.append({
            "priority": "MEDIUM",
            "category": "Testing",
            "issue": f"{len(tests)} methods have suggested unit tests.",
            "recommendation": (
                "Implement automated unit tests before modernization "
                "or major refactoring."
            )
        })

    state["modernization"] = recommendations

    return state