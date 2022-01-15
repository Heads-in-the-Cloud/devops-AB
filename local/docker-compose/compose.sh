#!/bin/sh
export API_GATEWAY_REGISTRY_URI=austinbaugh/utopia-api-gateway
export FLIGHTS_REGISTRY_URI=austinbaugh/utopia-flights-microservice
export USERS_REGISTRY_URI=austinbaugh/utopia-users-microservice
export BOOKINGS_REGISTRY_URI=austinbaugh/utopia-bookings-microservice

export API_GATEWAY_TAG=0.0.1
export FLIGHTS_TAG=0.0.4-SNAPSHOT
export USERS_TAG=0.0.4-SNAPSHOT
export BOOKINGS_TAG=0.0.4-SNAPSHOT

export DB_URL=$(cat ../secrets/mysql_url.txt)
export DB_USERNAME=$(cat ../secrets/mysql_username.txt)
export DB_PASSWORD=$(cat ../secrets/mysql_password.txt)
export JWT_SECRET=$(cat ../secrets/jwt_secret.txt)

docker-compose $@
