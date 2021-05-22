from flask import Flask, request

app = Flask(__name__)


@app.route('/models')
def get_models():
    """
    GET: available model ids
    :return: list of models present in the database
    """
    return "Bleep blop nothing here atm :("


@app.route('/model/<mid>')
def get_model_data(mid):
    """
    GET model data:

    - model description,
    - model price,
    - available materials
    - model blob

    :param mid: model id
    :return: model data in JSON
    """
    pass


@app.route('/model/create', methods=["POST"])
def create_model():
    """
    POST new model.

    Request body must contain:

    - description,
    - price,
    - available materials,
    - Optional[model blob]

    :return: model id
    """
    data = request.json
    # pass data to database proxy, return generated id


@app.route('/model/<mid>/modify', methods=["PUT"])
def change_model(mid):
    """
    PUT updated model params:

    - description,
    - price,
    - available materials,
    - model blob

    Any unspecified parameter is left unchanged.

    :param mid: model id to change
    :return: status code
    """
