import os


def get_heroku_params():
    url = os.getenv("DATABASE_URL")
    if url is None:
        password = os.getenv("DB_PASSWORD")
        user = os.getenv("DB_USER")
        host = os.getenv("DB_HOST")
        name = os.getenv("DB_NAME")
        port = os.getenv("DB_PORT")

        return {"password": password, "user": user, "host": host,
                "database": name, "port": port}
    return {"database_url": url}
