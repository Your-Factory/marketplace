import requests

from db import get_models
from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def main_page():
    model_ids = get_models()

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


@app.route('/model3d')
def model3d_page():
    return render_template('model3d_page.html')


@app.route('/download_model')
def download_page():
    return render_template('download_page.html')

