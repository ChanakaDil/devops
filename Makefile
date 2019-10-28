SERVICE_TAG=4.0.2.RELEASE
WEB_TAG=4.1.10
ENV=prod
REG=020724283767.dkr.ecr.us-west-2.amazonaws.com

.PHONY: clean clone build

default: build

clean:
	-rm -rf src

clone_service:
	-mkdir src
	cd ../cal-portal-backend && git fetch --tags --all && git pull
	cd ../cal-portal-backend && git archive --format=tar --prefix=../cal-devops/src/cal-portal-backend/ $(SERVICE_TAG) | tar Pxf -

build_service: clean clone_service
	echo building service $(SERVICE_TAG).
	cd src/cal-portal-backend && $(MAKE) TAG=$(SERVICE_TAG)
	docker tag cal-portal-backend:$(SERVICE_TAG) $(REG)/cal-portal-backend:$(SERVICE_TAG)
	docker tag cal-portal-backend:$(SERVICE_TAG) $(REG)/cal-portal-backend:latest

push_service: docker_login
	docker push $(REG)/cal-portal-backend:$(SERVICE_TAG)
	docker push $(REG)/cal-portal-backend:latest

docker_login:
	aws ecr get-login --no-include-email --region us-west-2 | bash

deploy_service: docker_login
	docker-compose pull
	docker-compose up

bnp: build_service push_service
	
