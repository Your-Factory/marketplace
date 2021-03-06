import os
import flask
from db import YourFactoryDB, User
from flask import Flask, render_template, redirect, request
from flask_login import (LoginManager, login_user, login_required, current_user,
                         logout_user)
from utils import get_heroku_params

app = Flask(__name__)
app.config['SECRET_KEY'] = os.getenv("SECRET_KEY")
app.config.update(
    SESSION_COOKIE_SAMESITE='Lax',
    MAX_CONTENT_LENGTH=10 * 1000 * 1000  # 10 MB
)
db_connection_params = get_heroku_params()
database = YourFactoryDB(**db_connection_params)
database.connect()

login_manager = LoginManager()
login_manager.login_message = u'Войдите в систему для доступа'
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
    models = database.get_previews()
    return render_template('store_front.html', models=models,
                           user=check_if_logged_in())


@app.route('/login')
def login_page():
    if current_user.is_authenticated:
        return redirect('/logout')
    return render_template('login.html')


@app.route('/logout')
def logout():
    logout_user()
    return redirect('/')


@app.route('/checkout/<model_id>')
@login_required
def checkout_page(model_id):
    data = database.get_model(model_id)
    return render_template('checkout.html', user=check_if_logged_in(),
                           model_name=data[0], model_desc=data[1])


@app.route('/model/<model_id>')
def model_page(model_id):
    data = database.get_model(model_id)
    return render_template('model_page.html', data=data,
                           user=check_if_logged_in(), model_id=model_id)


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

    flask.flash('Не удалось создать учётную запись. '
                'Возможно, Вы уже зарегистрированы?')
    return redirect("/login")


@app.route('/signin', methods=['POST'])
def sign_in_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember') is not None
    user_id = database.check_user(email, email, password)

    if user_id is not None:
        login_user(User(user_id, database), remember=remember)
        return redirect(request.args.get("next") or "/")

    flask.flash('Не удалось выполнить вход. Проверьте введённые данные.')
    return redirect("/login")


@app.route('/upload_model')
@login_required
def upload_page():
    return render_template('upload_page.html', user=check_if_logged_in())


@app.route('/uploading', methods=['GET', 'POST'])
@login_required
def upload_image():
    name = request.form.get("modelName")
    description = request.form.get("modelDescription")
    if request.method == "POST":
        if request.files:
            files = request.files
            images_storage = files.getlist("modelImages")

            images_names = [x.filename for x in images_storage]
            images_formats = [os.path.splitext(x)[1] for x in images_names]
            images_bytes = [x.read() for x in images_storage]

            model_storage = files.getlist("modelFile")[0]
            _, model_format = os.path.splitext(model_storage.filename)
            model_file = model_storage.read()
            author_id = current_user.id
            database.add_model(name, description, model_file, author_id,
                               model_format, images_bytes, images_formats)
    return redirect("/")


@app.errorhandler(413)
def entity_too_large(_):
    flask.flash('Слишком большой файл!')
    return redirect('/upload_model')


def check_if_logged_in():
    if current_user.is_authenticated:
        return current_user
    return None
