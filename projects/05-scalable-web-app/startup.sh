#!/bin/bash
sudo apt-get update
sudo apt-get install -y nginx
echo "<h1>Hello from $(hostname)!</h1>" | sudo tee /var/www/html/index.html