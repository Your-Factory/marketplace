import logging

import requests
import hashlib
from db.connect import YourFactoryDB
from db.user import User
from flask import Flask, render_template, redirect, url_for, request
from utils.env_helper import get_heroku_params
from flask_login import UserMixin, LoginManager, login_user


app = Flask(__name__)
db_connection_params = get_heroku_params()
database = YourFactoryDB(**db_connection_params)
database.connect()

login_manager = LoginManager()
login_manager.login_view = 'auth.login'
login_manager.init_app(app)


@login_manager.user_loader
def load_user(user_id):
    return User(user_id)


@app.route('/')
def main_page():
    model_ids = "None"

    # Do something with the data
    return render_template('store_front.html', data=model_ids)


@app.route('/login')
def login_page():
    return render_template('login.html')


@app.route('/checkout')
def checkout_page():
    return render_template('checkout.html')


@app.route('/model')
def model_page():
    return render_template('model_page.html')


@app.route('/about')
def about_page():
    return render_template('about.html')


@app.route('/registration', methods=['POST'])
def registration_post():
    email = request.form.get('email')
    password = request.form.get('password')
    if database.create_user(email, email, password):
        return redirect("/")
    return redirect("/login")


@app.route('/signin', methods=['GET', 'POST'])
def sign_in_post():
    email = request.form.get('email')
    password = request.form.get('password')
    remember = request.form.get('remember')
    user_id = database.check_user(email, email, password)
    if user_id is not None:
        login_user(User(id, email, email), remember=remember)
        return redirect("/")
    return redirect("/login")

