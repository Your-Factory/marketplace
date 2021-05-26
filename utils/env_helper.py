import os


def get_heroku_params():
    url = os.getenv("DATABASE_URL")
    if url is None:
        password = os.getenv("POSTGRES_PASSWORD")
        user = os.getenv("DB_USER")
        host = os.getenv("DB_HOST")
        name = os.getenv("DB_NAME")
        return password, user, host, name
    return url
