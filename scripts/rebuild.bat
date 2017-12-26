SET GIT_REPOSITORY_PATH=/c/Users/tobia/Desktop/CLOUDCONFIG
cd ..
cd config-server
call mvn clean install
cd ..
cd config-client
call mvn clean install
cd ..
copy config-server\target\config-server-1.0-SNAPSHOT.jar docker\files\config-server.jar
copy config-client\target\config-client-1.0-SNAPSHOT.jar docker\files\config-client.jar
cd docker
docker-compose up --build