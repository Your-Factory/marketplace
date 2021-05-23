# TODO: specify db interaction API

def get_models():
    """
    Return
    :return: list of models present in the database
    """
    return "Bleep blop nothing here atm :("


def get_model_data(mid):
    """
    Get model data:

    - model description,
    - model price,
    - available materials
    - model blob

    :param mid: model id
    :return: dict with model data
    """
    pass


def create_model():
    """
    Add a new model.

    Request body must contain:

    - description,
    - price,
    - available materials,
    - Optional[model blob]

    :return: model id
    """
    pass


def change_model(mid):
    """
    Update model params:

    - description,
    - price,
    - available materials,
    - model blob

    Any unspecified parameter is left unchanged.

    :param mid: model id to change
    :return: status code
    """
    pass
