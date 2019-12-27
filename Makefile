-include env_make

PYTHON_VER ?= 3.6.5

REPO = charlessoft/python
NAME = python-$(PYTHON_VER)

ifneq ($(STABILITY_TAG),)
    ifneq ($(TAG),latest)
        override TAG := $(TAG)-$(STABILITY_TAG)
    endif
endif

ifeq ($(TAG),)
    ifneq ($(PYTHON_DEV),)
    	TAG ?= $(PYTHON_VER)-dev
    else
        TAG ?= $(PYTHON_VER)
    endif
endif

ifneq ($(PYTHON_DEV),)
    NAME := $(NAME)-dev
endif

.PHONY: build test push shell run start stop logs clean release

default: build

build:
	docker build -t $(REPO):$(TAG) \
		--build-arg PYTHON_VER=$(PYTHON_VER) \
		--build-arg PYTHON_DEV=$(PYTHON_DEV) \
		./

test:
	IMAGE=$(REPO):$(TAG) ./test.sh

push:
	docker push $(REPO):$(TAG)

shell:
	docker run --rm --name $(NAME) -i -t $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) /bin/bash

run:
	docker run --rm --name $(NAME) -e DEBUG=1 $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG) $(CMD)

start:
	docker run -d --name $(NAME) $(PORTS) $(VOLUMES) $(ENV) $(REPO):$(TAG)

stop:
	docker stop $(NAME)

logs:
	docker logs $(NAME)

clean:
	-docker rm -f $(NAME)

release: build push
