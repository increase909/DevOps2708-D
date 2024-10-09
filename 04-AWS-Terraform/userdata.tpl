#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y
echo "Hello World" > /usr/share/nginx/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
