import logging
import psycopg2
from flask_login import UserMixin


class User(UserMixin):
    def __init__(self, id, database):
        self.id = id
        curr = database.conn.cursor()
        try:
            curr.execute("SELECT login, email FROM users WHERE id = %s;", (id,))
            query_result = curr.fetchone()
            logging.warning(query_result)
            if query_result is None:
                self.id = self.login = self.email = None
                return
            self.login, self.email = query_result
        except psycopg2.DatabaseError as error:
            logging.error(error)
        finally:
            curr.close()
