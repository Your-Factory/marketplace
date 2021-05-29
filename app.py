import logging
import os

from db.connect import YourFactoryDB
from db.user import User
from flask import Flask, render_template, redirect, request
from utils import get_heroku_params
from flask_login import LoginManager, login_user, login_required, current_user

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY")
app.config.update(
    SESSION_COOKIE_SAMESITE='Lax'
)
db_connection_params = get_heroku_params()
database = YourFactoryDB(**db_connection_params)
database.connect()

login_manager = LoginManager()
login_manager.login_view = 'login_page'
login_manager.init_app(app)


@app.before_request
def before_request():
    scheme = request.headers.get('X-Forwarded-Proto')
    if scheme and scheme == 'http' and request.url.startswith('http://'):
        url = request.url.replace('http://', 'https://', 1)
        code = 301
        return redirect(url, code=code)


@login_manager.user_loader
def load_user(user_id):
    return User(user_id, database)


@app.route('/')
def main_page():
    model_ids = "None"
    return render_template('store_front.html', data=model_ids,
                           user=check_if_logged_in())


@app.route('/login')
def login_page():
    if current_user.is_authenticated:
        return redirect('/')
    return render_template('login.html')


@app.route('/checkout')
@login_required
def checkout_page():
    return render_template('checkout.html', user=check_if_logged_in())


@app.route('/model')
def model_page():
    return render_template('model_page.html', user=check_if_logged_in())


@app.route('/about')
def about_page():
    return render_template('about.html', user=check_if_logged_in())


@app.route('/registration', methods=['POST'])
def registration_post():
    email = request.form.get('email').strip()
    password = request.form.get('password').strip()
    if email != "" and password != "" and database.create_user(email, email,
                                                               password):
        remember = request.form.get('remember') is not None
        user_id = database.check_user(email, email, password)
        login_user(User(user_id, database), remember=remember)
        return redirect("/")
    return redirect("/login")


@app.route('/signin', methods=['POST'])
def sign_in_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember') is not None
    user_id = database.check_user(email, email, password)
    if user_id is not None:
        login_user(User(user_id, database), remember=remember)
        return redirect("/")
    return redirect("/login")


@app.route('/model3d')
def model3d_page():
    return render_template('model3d_page.html')


@app.route('/upload_model')
@login_required
def upload_page():
    return render_template('upload_page.html', user=check_if_logged_in())


@app.route('/upload_model_action"', methods=['POST'])
@login_required
def upload_model():
    model_name = request.form.get('modelName')
    model_description = request.form.get('modelDescription')
    logging.warning(model_name, model_description)
    return redirect("/")


def check_if_logged_in():
    if current_user.is_authenticated:
        return current_user
    return None
