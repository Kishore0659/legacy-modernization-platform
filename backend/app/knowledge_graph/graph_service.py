from app.knowledge_graph.neo4j_client import driver


def create_project_graph(project_id, dependencies):
    with driver.session() as session:

        # Create Project node
        session.run(
            """
            MERGE (p:Project {id: $project_id})
            """,
            project_id=project_id
        )

        for dependency in dependencies:

            source = dependency.get("source")
            target = dependency.get("target")
            relationship_type = dependency.get("type")
            method = dependency.get("method")

            if not source or not target or not relationship_type:
                continue

            query = """
            MATCH (p:Project {id: $project_id})

            MERGE (source:CodeEntity {name: $source})
            MERGE (target:CodeEntity {name: $target})

            MERGE (p)-[:CONTAINS]->(source)

            WITH source, target
            """

            if relationship_type == "EXTENDS":

                query += """
                MERGE (source)-[:EXTENDS]->(target)
                """

            elif relationship_type == "IMPLEMENTS":

                query += """
                MERGE (source)-[:IMPLEMENTS]->(target)
                """

            elif relationship_type == "IMPORTS":

                query += """
                MERGE (source)-[:IMPORTS]->(target)
                """

            elif relationship_type == "CALLS":

                query += """
                MERGE (source)-[r:CALLS]->(target)
                """

                if method:
                    query += """
                    SET r.method = $method
                    """

            else:

                query += """
                MERGE (source)-[r:DEPENDS_ON]->(target)
                SET r.type = $relationship_type
                """

            session.run(
                query,
                project_id=project_id,
                source=source,
                target=target,
                method=method,
                relationship_type=relationship_type
            )

    return {
        "message": "Knowledge graph created successfully",
        "project_id": project_id,
        "relationships_created": len(dependencies)
    }