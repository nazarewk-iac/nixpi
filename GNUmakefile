SHELL := $(shell which bash)
.SHELLFLAGS := -xeEuo pipefail -c
.ONESHELL:

NIXOS_VERSION = 20.09

BUILDER_DIR = nixos-docker-sd-image-builder
CONFIGURED_FLAG = $(BUILDER_DIR)/.configured
TARGET_IMAGE = $(BUILDER_DIR)/nixos-sd-image-$(NIXOS_VERSION)pre-git-aarch64-linux.img
NIXPKGS_BRANCH = release-$(NIXOS_VERSION)

MAKEFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MAKEFILE_DIR := $(dir $(MAKEFILE_PATH))
export PATH := ${MAKEFILE_PATH}/.venv/bin:${PATH}

.PHONY: mount umount
.PHONY: debug-* deploy clean bake image image-configure

all: debug-remote

debug-local:
	.venv/bin/ansible-playbook -v -l local ansible/debug.yml

debug-remote:
	.venv/bin/ansible-playbook -v -l nixpis ansible/debug.yml

deploy:
	.venv/bin/ansible-playbook -v ansible/deploy.yml

clean:
	pushd "$(BUILDER_DIR)"
	./run.sh rm --force
	docker image rm docker_build-nixos || true
	popd
	rm -rf "$(BUILDER_DIR)"

bake:
	[[ -f "$(TARGET_IMAGE)" ]] || exit 1
	[[ -b "/dev/mmcblk0" ]] || exit 1
	sudo dd if="$(TARGET_IMAGE)" of=/dev/mmcblk0 bs=4K status=progress

image: "$(TARGET_IMAGE)"
image-configure: "$(CONFIGURED_FLAG)"

"$(TARGET_IMAGE)": "$(CONFIGURED_FLAG)"
	pushd "$(BUILDER_DIR)"
	./run.sh up --build
	popd
	sudo chown $(shell id -u):$(shell id -g) "$(TARGET_IMAGE)"

"$(CONFIGURED_FLAG)": .venv/bin/ansible-playbook
	.venv/bin/ansible-playbook ansible/image-configure.yml -e nixpkgs_branch="$(NIXPKGS_BRANCH)"
	touch "$(CONFIGURED_FLAG)"

.venv:
	rm -rf .venv
	python3 -m venv .venv

.venv/bin/ansible-playbook: .venv
	. .venv/bin/activate
	pip install -U -r requirements.txt

mount: $(TARGET_IMAGE)
	mkdir -p ./mnt-new
	./bin/img mount $(TARGET_IMAGE) ./mnt-new

umount:
	./bin/img umount $(TARGET_IMAGE)
