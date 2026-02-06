# Initial deployment of the ETL function via CI/CD. v3
import functions_framework
from flask import escape

# Register an HTTP function that can be triggered by a URL
@functions_framework.http
def hello_etl(request):
    """
    HTTP Cloud Function.
    Args:
        request (flask.Request): The request object.
    Returns:
        The response text, or any set of values that can be turned into a
        Response object using `make_response`.
    """
    # Try to get a 'name' from the request's JSON body or query string
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
    
    return f"Hello, {escape(name)}! This is an ETL function deployed by CI/CD."