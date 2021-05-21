from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def main_page():
    return render_template('store_front.html')


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
