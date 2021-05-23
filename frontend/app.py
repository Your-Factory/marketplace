import logging
import requests

from flask import Flask, render_template
from os import getenv
from urllib.parse import urljoin

app = Flask(__name__)
back_url = getenv('BACK_URL')


@app.route('/')
def main_page():
    # Service interop example
    url = urljoin(back_url, '/models')
    model_ids = requests.get(url)

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
