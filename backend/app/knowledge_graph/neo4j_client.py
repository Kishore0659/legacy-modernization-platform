from neo4j import GraphDatabase


NEO4J_URI = "bolt://127.0.0.1:7687"
NEO4J_USERNAME = "neo4j"
NEO4J_PASSWORD = "Kishore@0119"


driver = GraphDatabase.driver(
    NEO4J_URI,
    auth=(NEO4J_USERNAME, NEO4J_PASSWORD)
)


def close_driver():
    driver.close()


def test_connection():
    with driver.session() as session:
        result = session.run(
            "RETURN 'Neo4j Connected' AS status"
        )

        return result.single()["status"]