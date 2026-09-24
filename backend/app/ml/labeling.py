def calculate_priority(row):

    score = 0

    # Lines of code
    if row["loc"] > 500:
        score += 2
    elif row["loc"] > 200:
        score += 1

    # Number of methods
    if row["methods"] > 40:
        score += 2
    elif row["methods"] > 20:
        score += 1

    # Complexity
    if row["cyclomatic_complexity"] > 15:
        score += 3
    elif row["cyclomatic_complexity"] > 8:
        score += 2
    elif row["cyclomatic_complexity"] > 4:
        score += 1

    # Dependencies
    if row["dependencies"] > 30:
        score += 2
    elif row["dependencies"] > 15:
        score += 1

    if score >= 5:
        return "HIGH"

    if score >= 2:
        return "MEDIUM"

    return "LOW"