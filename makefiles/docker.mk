
# Override in app Makefile to control docker file path.
DOCKERFILE_PATH ?= Dockerfile

# Override in app Makefile to control docker build context.
DOCKERBUILD_CONTEXT ?= .

# Override in app Makefile to control docker image tag.
DOCKER_IMAGE_TAG ?= latest

# Override in app Makefile to control docker image github token in case the docker required it into build.
DOCKER_GITHUB_TOKEN ?= ""

# Override in app Makefile to control docker docker-compose.yml path.
DOCKER_COMPOSE_PATH ?= docker-compose.yml

# Override in app Makefile to control docker docker-compose.yml project name.
DOCKER_COMPOSE_PROJECT_NAME ?= $(PACKAGE_NAME)

# Override in app Makefile to control docker docker-compose.yml profile name.
DOCKER_COMPOSE_PROFILE ?= ""

# Override in app Makefile to control docker docker-compose.yml build using secret instead of args.
DOCKER_SECRET ?= false

docker-cli:
	@bash $(EXTEND_DEVGO_SCRIPTS)/docker-cli.sh

docker-compose-cli:
	@bash $(EXTEND_DEVGO_SCRIPTS)/docker-compose-cli.sh

## Build docker image
##
## In case the build require a secret, DOCKER_GITHUB_TOKEN must be provided.
## To use secrets in docker build, DOCKER_SECRET must be true, otherwise docker build uses args.
## 	- To get the secret into a container
## 	RUN --mount=type=secret,id=GH_ACCESS_TOKEN GITHUB_TOKEN=$(cat /run/secrets/GH_ACCESS_TOKEN)
## 	- To get the token into a container
## 	ARG GH_ACCESS_TOKEN
build-image: docker-cli
	@DOCKER_IMAGE_TAG=$(DOCKER_IMAGE_TAG) \
	DOCKERFILE_PATH=$(DOCKERFILE_PATH) \
	DOCKERBUILD_CONTEXT=$(DOCKERBUILD_CONTEXT) \
	DOCKER_GITHUB_TOKEN=$(DOCKER_GITHUB_TOKEN) \
	DOCKER_SECRET=$(DOCKER_SECRET) \
	PACKAGE_NAME=$(PACKAGE_NAME) \
	bash $(EXTEND_DEVGO_SCRIPTS)/docker-build.sh

## Run docker-compose up from file DOCKER_COMPOSE_PATH with project name DOCKER_COMPOSE_PROJECT_NAME and profile DOCKER_COMPOSE_PROFILE.
## Usage: "make dc-up PROFILE=<profile>, if PROFILE is not provide, start only default services"
dc-up: docker-compose-cli
	@docker compose -f $(DOCKER_COMPOSE_PATH) -p $(DOCKER_COMPOSE_PROJECT_NAME) $(if $(PROFILE),--profile $(PROFILE),$(if $(DOCKER_COMPOSE_PROFILE),--profile $(DOCKER_COMPOSE_PROFILE))) up -d --remove-orphans

## Run docker-compose down from file DOCKER_COMPOSE_PATH with project name DOCKER_COMPOSE_PROJECT_NAME
dc-down: docker-compose-cli
	@docker compose -f $(DOCKER_COMPOSE_PATH) -p $(DOCKER_COMPOSE_PROJECT_NAME) down -v

## Run docker-compose logs from file DOCKER_COMPOSE_PATH with project name DOCKER_COMPOSE_PROJECT_NAME. Usage: "make dc-logs APP=<docker-composer-service-name>"
dc-logs: docker-compose-cli
	@docker compose -f $(DOCKER_COMPOSE_PATH) -p $(DOCKER_COMPOSE_PROJECT_NAME) logs $(APP)


.PHONY: docker-cli docker-compose-cli build-image dc-up dc-down dc-logs