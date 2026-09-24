class DebtPredictor:
    def predict(self, loc: int, methods: int, complexity: int, dependencies: int) -> str:
        score = 0
        if loc > 250: score += 2
        if methods > 15: score += 2
        if complexity > 10: score += 2
        if dependencies > 8: score += 1

        if score >= 5: return "HIGH"
        if score >= 2: return "MEDIUM"
        return "LOW"

predictor = DebtPredictor()