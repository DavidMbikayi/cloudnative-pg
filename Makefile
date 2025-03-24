PG_MAJOR ?= 17
PG_MINOR ?= 4
BASE_IMAGE_DISTRO ?= bookworm
DOCKERFILE=$(BASE_IMAGE_DISTRO)/Dockerfile
POSTGRES_BASE_IMAGE=postgres:$(PG_CONTAINER_VERSION)-$(BASE_IMAGE_DISTRO)
PG_CONTAINER_VERSION = $(PG_MAJOR).$(PG_MINOR)
TAG=cloudnative-pg:$(PG_CONTAINER_VERSION)-$(BASE_IMAGE_DISTRO)
CITUS_VERSION=13.0.3
PG_SEARCH_VERSION=0.15.10
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
				--build-arg CITUS_VERSION=$(CITUS_VERSION) \
				--build-arg PG_SEARCH_VERSION=$(PG_SEARCH_VERSION) \
				--build-arg BASE_IMAGE_DISTRO=$(BASE_IMAGE_DISTRO) \
				--build-arg PG_MAJOR=$(PG_MAJOR) \
				--build-arg PG_MINOR=$(PG_MINOR) \
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