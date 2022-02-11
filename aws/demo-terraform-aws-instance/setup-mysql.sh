#! /bin/bash
apt-get update && apt-get install docker -y

systemctl restart docker

systemctl enable docker

docker pull mysql

docker run --name mysql -e MYSQL_ROOT_PASSWORD=root \
-e MYSQL_DATABASE=appdb -p 3306:3306 -d mysql:5.7 