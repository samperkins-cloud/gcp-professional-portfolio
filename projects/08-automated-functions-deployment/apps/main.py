 # Testing 
import os
import functions_framework
from markupsafe import escape

# This line reads the secret from the environment
API_KEY = os.environ.get("API_KEY", "NO_KEY_FOUND")

@functions_framework.http
def hello_etl(request):
    """HTTP Cloud Function that securely uses a secret."""
    # ... (your existing logic for 'name') ...
    name = 'World'
    
    # This line displays the secret
    return f"Hello, {escape(name)}! This was deployed by a Reusable GitHub Action! The key is: {API_KEY[:5]}"