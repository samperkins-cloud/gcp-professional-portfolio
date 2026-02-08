import os
import functions_framework
from markupsafe import escape

# Read the secret API key from the environment variable.
# The value is securely injected by the CI/CD pipeline.
# The default "NO_KEY_FOUND" is for local testing or if the secret isn't set.
API_KEY = os.environ.get("API_KEY", "NO_KEY_FOUND")

@functions_framework.http
def hello_etl(request):
    """HTTP Cloud Function that securely uses a secret."""
    request_json = request.get_json(silent=True)
    request_args = request.args

    if request_json and 'name' in request_json:
        name = request_json['name']
    elif request_args and 'name' in request_args:
        name = request_args['name']
    else:
        name = 'World'
    
    return f"Hello, {escape(name)}! This is an ETL function deployed by CI/CD."