#!/bin/bash
sudo yum install docker -y
sudo systemctl start docker
sudo docker run -d -e REACT_APP_API_URL=http://abhayapiserver80-1-405d3bbb1bf6486f.elb.us-east-2.amazonaws.com:8080/ -p 80:3000 abhay1813/finalfrontend