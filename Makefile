
CODENAME := $(shell basename $(shell pwd))
IMAGE_NAME := crosstalkio/$(CODENAME)
REPO_NAME ?= crosstalkio/$(CODENAME)
VERSION ?= $(subst v,,$(shell git describe --tags --exact-match 2>/dev/null || echo ""))

# Build docker image.
#
# Usage:
#	make docker/build [no-cache=(no|yes)]

docker/build:
	docker build --network=host --force-rm \
		$(if $(call eq,$(no-cache),yes),--no-cache --pull,) \
		-t $(IMAGE_NAME) \
		-f Dockerfile \
		.

# Run docker image.
#
# Usage:
#	make docker/run

docker/run:
	docker run -it --rm \
		--name=$(CODENAME) \
		--network=host \
		$(IMAGE_NAME)

# Tag docker images.
#
# Usage:
#	make docker/tag [VERSION=<image-version>]

docker/tag:
	docker tag $(IMAGE_NAME) $(REPO_NAME):latest
ifneq ($(VERSION),)
	docker tag $(IMAGE_NAME) $(REPO_NAME):$(VERSION)
endif

# Push docker images.
#
# Usage:
#	make docker/push

docker/push:
	docker push $(REPO_NAME):latest
ifneq ($(VERSION),)
	docker push $(REPO_NAME):$(VERSION)
endif

docker: docker/build docker/tag docker/push

.PHONY: docker/build docker/run docker/tag docker/push docker
