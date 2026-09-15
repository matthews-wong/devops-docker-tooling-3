.PHONY: test validate build up down dev

test:
	npm test

validate:
	./scripts/validate.sh

build:
	docker build -t healthcheck-api .

up:
	docker compose up --build

down:
	docker compose down

dev:
	docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build
