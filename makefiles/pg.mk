## Check/install pg_isready tool
pg_isready-cli:
	@bash $(SCRIPTS_PATH)/pg_isready-cli.sh

## Check postgres service and database is up and running
pg-ready: pg_isready-cli
	@POSTGRES_TEST_HOST=$(POSTGRES_TEST_HOST) \
	POSTGRES_TEST_PORT=$(POSTGRES_TEST_PORT) \
	POSTGRES_TEST_USER=$(POSTGRES_TEST_USER) \
	POSTGRES_TEST_PASSWORD=$(POSTGRES_TEST_PASSWORD) \
	POSTGRES_TEST_DATABASE=$(POSTGRES_TEST_DATABASE) \
	DOCKER_POSTGRES_TAG=$(DOCKER_POSTGRES_TAG) \
	bash $(SCRIPTS_PATH)/pg_isready.sh

.PHONY: pg_isready-cli pg-isready