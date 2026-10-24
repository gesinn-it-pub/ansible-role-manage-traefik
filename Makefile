ROLE_NAME                     := ansible-role-manage-traefik
# Latest leg: runs the ansible-core bundled in this image (Python 3.14).
ANSIBLE_DEV_TOOLS_IMAGE       ?= ghcr.io/ansible/community-ansible-dev-tools:26.7.2
# Floor leg: molecule refuses ansible-core < 2.20 on Python 3.14, so a pinned
# ANSIBLE_CORE uses this older image (Python 3.13). Drop it once the floor
# line runs on the Python of the image above.
ANSIBLE_DEV_TOOLS_IMAGE_PY313 ?= ghcr.io/ansible/community-ansible-dev-tools:26.4.0

# Empty: use the ansible-core bundled in the image. Set to a release line
# (e.g. 2.19) to install that line into the container first — this is how a
# CI matrix leg is reproduced locally.
ANSIBLE_CORE ?=
# Empty: run every scenario.
SCENARIO     ?=

TRAEFIK_VERSION ?= 3.3

core-pin := $(if $(ANSIBLE_CORE),pip install -q --no-warn-script-location --user ansible-core~=$(ANSIBLE_CORE).0 && export PATH=\$$HOME/.local/bin:\$$PATH &&,)
galaxy   := if [ -f requirements.yml ]; then ansible-galaxy collection install -r requirements.yml; fi
mol-args := $(if $(SCENARIO),-s $(SCENARIO),--all)
core-image := $(if $(ANSIBLE_CORE),$(ANSIBLE_DEV_TOOLS_IMAGE_PY313),$(ANSIBLE_DEV_TOOLS_IMAGE))

docker-run := docker run --rm \
	-v "$(CURDIR):/workspace:ro" \
	-w /workspace \
	$(ANSIBLE_DEV_TOOLS_IMAGE)

# molecule needs write access (scenario cache, tmp files)
docker-run-rw := docker run --rm \
	-v "$(CURDIR):/workspace" \
	-w /workspace \
	-e TRAEFIK_VERSION=$(TRAEFIK_VERSION) \
	$(core-image)

.PHONY: lint molecule ci

lint:
	$(docker-run) bash -c "$(galaxy) && ansible-lint"

molecule:
	$(docker-run-rw) bash -c "$(core-pin) ansible --version | head -n 1 \
		 && $(galaxy) \
		 && mkdir -p /tmp/roles \
		 && ln -s /workspace /tmp/roles/$(ROLE_NAME) \
		 && ANSIBLE_ROLES_PATH=/tmp/roles molecule test $(mol-args)"

ci: lint molecule
