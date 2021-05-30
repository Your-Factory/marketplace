import psycopg2
import json
import logging
import hashlib
import datetime
from base64 import b64encode


class YourFactoryDB:
    def __init__(self, host=None, database_url=None, database=None, user=None,
                 password=None, port=5432):
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
                self.conn = psycopg2.connect(
                    host=self.host, database=self.db,
                    user=self.user, password=self.password,
                    port=self.port
                )
            else:
                self.conn = psycopg2.connect(
                    self.database_url,
                    sslmode='require'
                )
            return True
        except psycopg2.DatabaseError as connection_error:
            logging.warning(connection_error)
            return False

    def create_user(self, login, email, password):
        """
        Add new user to database.
        :param login: users login
        :param email: users email
        :param password: users password
        :return: True if user was added, else False
        """
        salt = str(datetime.datetime.utcnow())
        password_hash = hashlib.sha256(
            (password + salt).encode('utf-8')).hexdigest()
        curr = self.conn.cursor()
        error = False
        try:
            curr.execute("CALL add_user(%s, %s, %s, %s);",
                         (login, email, salt, password_hash))
            self.conn.commit()
        except psycopg2.DatabaseError as add_user_error:
            logging.warning(add_user_error)
            error = True
            self.conn.rollback()
        finally:
            if curr is not None:
                curr.close()
        return not error

    def check_user(self, login, email, password):
        """
        :param login: users login
        :param email: users email
        :param password: users password
        :return: Id if user exists, else None
        """
        curr = self.conn.cursor()
        try:
            curr.execute("SELECT * FROM get_user_salt(%s);", (login,))
            salt = curr.fetchone()[0]
            if salt is None:
                return None
            password_hash = hashlib.sha256(
                (password + salt).encode('utf-8')).hexdigest()
            curr.execute("SELECT * FROM check_user_authentication(%s, %s)",
                         (login, password_hash))
            user_id = curr.fetchone()[0]
            return user_id
        except psycopg2.DatabaseError as error:
            logging.error(error)
            self.conn.rollback()
        finally:
            curr.close()
        return None

    def get_previews(self):
        curr = self.conn.cursor()
        previews = []

        try:
            curr.execute("SELECT * FROM get_model_previews();")
            previews.extend(curr.fetchall())
        except psycopg2.DatabaseError as error:
            logging.error(error)
            self.conn.rollback()
        finally:
            curr.close()

        def unpack(x):
            i, name, img, fmt = x
            return i, name, b64encode(bytes(img)).decode('ascii'), fmt

        return map(unpack, previews)

    def get_model(self, model_id):
        curr = self.conn.cursor()
        data = None

        try:
            curr.execute("SELECT * FROM get_model(%s);", (model_id,))
            data = curr.fetchone()
        except psycopg2.DatabaseError as error:
            logging.error(error)
            self.conn.rollback()
        finally:
            curr.close()

        name, desc, model, m_type, imgs, fmts = data
        model = json.dumps(bytes(model).decode())
        imgs = list(zip([b64encode(bytes(img)).decode('ascii') for img in imgs],
                        fmts))

        return name, desc, model, m_type, imgs

    def add_model(self, name, description, model_file, author_id, model_format,
                  images, images_formats):
        """
        Add new model to database
        :param name: string
        :param description: string
        :param model_file: raw bytes of model file
        :param author_id: int
        :param model_format: string
        :param images: list of raw images
        :param images_formats: list of strings
        :return: True if model was added, else False
        """
        curr = self.conn.cursor()
        try:
            curr.execute("CALL add_model(%s, %s, %s, %s, %s, %s, %s);",
                         (
                             name, description, model_file, author_id,
                             model_format,
                             images, images_formats))
            self.conn.commit()
        except psycopg2.DatabaseError as error:
            logging.error(error)
            self.conn.rollback()
        finally:
            curr.close()
