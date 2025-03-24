PG_CONTAINER_VERSION ?= 17.4
BASE_IMAGE_DISTRO ?= bookworm
DOCKERFILE=$(BASE_IMAGE_DISTRO)/Dockerfile
POSTGRES_BASE_IMAGE=postgres:$(PG_CONTAINER_VERSION)-$(BASE_IMAGE_DISTRO)
TAG=postgres-plv8:$(PG_CONTAINER_VERSION)-$(BASE_IMAGE_DISTRO)


deploy: deps buildAndPush clean
local: deps build clean

# Dependencies for the project such as Docker Node Alpine image
deps: env-PG_CONTAINER_VERSION env-BASE_IMAGE_DISTRO
	$(info Pull latest version of $(POSTGRES_BASE_IMAGE))
	$(info dockerfile $(DOCKERFILE))
	docker pull $(POSTGRES_BASE_IMAGE)


build: deps
	docker  build \
		--build-arg PG_CONTAINER_VERSION=$(PG_CONTAINER_VERSION) \
		--file  $(DOCKERFILE)  \
		-t $(TAG) .


buildAndPush: env-PG_CONTAINER_VERSION env-BASE_IMAGE_DISTRO
	@echo "$(DOCKER_ACCESS_TOKEN)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin docker.io
	docker  build \
    		--build-arg PG_CONTAINER_VERSION=$(PG_CONTAINER_VERSION) \
    		--file  $(DOCKERFILE)  \
			--push \
			-t $(TAG) .
	docker logout



push: env-DOCKER_USERNAME env-DOCKER_ACCESS_TOKEN
	@echo "$(DOCKER_ACCESS_TOKEN)" | docker login --username "$(DOCKER_USERNAME)" --password-stdin docker.io
	docker push $(TAG)
	docker logout

pull:
	docker pull $(POSTGRES_BASE_IMAGE)

shell:
	docker run --rm -it  $(TAG) bash

clean:
	docker rmi -f $(TAG)

env-%:
	@echo "Checking if $* environment variable is set..."
	@test -n "$($*)" || (echo "Error: $* environment variable is unset or empty" && exit 1)