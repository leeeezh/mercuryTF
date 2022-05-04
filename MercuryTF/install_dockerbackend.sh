#!/bin/bash
sudo yum install docker -y
sudo systemctl start docker
sudo docker run -e spring.datasource.url=jdbc:postgresql://mercuryrds.cbltqbfhbmvt.us-east-2.rds.amazonaws.com:5432/smartbankdb -e spring.datasource.password=postgres -p 8080:8080 -d abhay1813/apicontainer