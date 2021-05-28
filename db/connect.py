import psycopg2
import logging
import hashlib
import datetime


class YourFactoryDB:
    def __init__(self, host=None, database_url=None, database=None, user=None, password=None, port=5432):
        self.host = host
        self.database_url = database_url
        self.db = database
        self.user = user
        self.password = password
        self.port = port
        self.conn = None

    def connect(self):
        try:
            if self.database_url is None:
                self.conn = psycopg2.connect(host=self.host, database=self.db, user=self.user,
                                             password=self.password, port=self.port)
            else:
                self.conn = psycopg2.connect(self.database_url, sslmode='require')
            return True
        except psycopg2.DatabaseError as connection_error:
            logging.warning(connection_error)
            return False

    def create_user(self, login, email, password):
        """
        Add new user to database.
        :param login - users login:
        :param email - users email:
        :param password - users password:
        :return: True if user was added, else False
        """
        salt = str(datetime.datetime.utcnow())
        password_hash = hashlib.sha256((password + salt).encode('utf-8')).hexdigest()
        curr = self.conn.cursor()
        error = False
        try:
            curr.execute("CALL add_user(%s, %s, %s, %s);", (login, email, salt, password_hash))
            self.conn.commit()
            curr.close()
        except psycopg2.DatabaseError as add_user_error:
            logging.warning(add_user_error)
            error = True
        finally:
            if curr is not None:
                curr.close()
        return not error


'''
def get_models():
    """
    Return
    :return: list of models present in the database
    """
    return "Bleep blop nothing here atm :("


def get_model_data(mid):
    """
    Get model data:

    - model description,
    - model price,
    - available materials
    - model blob

    :param mid: model id
    :return: dict with model data
    """
    pass


def create_model():
    """
    Add a new model.

    Request body must contain:

    - description,
    - price,
    - available materials,
    - Optional[model blob]

    :return: model id
    """
    pass


def change_model(mid):
    """
    Update model params:

    - description,
    - price,
    - available materials,
    - model blob

    Any unspecified parameter is left unchanged.

    :param mid: model id to change
    :return: status code
    """
    pass
'''