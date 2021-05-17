from flask import Flask, render_template

app = Flask(__name__)


@app.route('/')
def main_page():
    return render_template('store_front.html')


@app.route('/login')
def login_page():
    return render_template('login.html')
