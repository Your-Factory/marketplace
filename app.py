import logging

import requests
import hashlib
from db import YourFactoryDB
from flask import Flask, render_template, redirect, url_for, request
from utils.env_helper import get_heroku_params


app = Flask(__name__)
db_connection_params = get_heroku_params()
database = YourFactoryDB(**db_connection_params)
database.connect()


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
def signup_post():

    email = request.form.get('email')
    password = request.form.get('password')
    if database.create_user(email, email, password):
        return redirect("/")
    return redirect("/login")
