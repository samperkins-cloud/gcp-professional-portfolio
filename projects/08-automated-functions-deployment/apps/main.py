 # Test of the multi-workspace platform
import os
import functions_framework
from markupsafe import escape


API_KEY = os.environ.get("API_KEY", "NO_KEY_FOUND")

@functions_framework.http
def hello_etl(request):
    """HTTP Cloud Function that securely uses a secret."""
    name = 'World'
    
    return f"Hello, {escape(name)}! Testing PR Preview URLv3!!! The key is: {API_KEY[:5]}"