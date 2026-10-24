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

core-pin := $(if $(ANSIBLE_CORE),pip install -q --no-warn-script-location --user ansible-core~=$(ANSIBLE_CORE).0 && export PATH=\$$HOME/.local/bin:\$$PATH &&,)
# Galaxy answers with transient 500s now and then (and once for hours): retry with a growing pause, and keep the
# installed collections between runs so that Galaxy is only contacted when requirements.yml asks for something that
# is not installed yet. Empty COLLECTIONS_CACHE disables the cache.
GALAXY_RETRY_PAUSE ?= 20
COLLECTIONS_CACHE  ?= $(HOME)/.cache/ansible-role-collections

retry       = for attempt in 1 2 3 4 5; do $(1) && break; [ \$$attempt -lt 5 ] && sleep \$$((attempt * $(GALAXY_RETRY_PAUSE))) || exit 1; done
cache-mount := $(if $(COLLECTIONS_CACHE),-v "$(COLLECTIONS_CACHE):/root/.ansible/collections",)
cache-dir   := $(if $(COLLECTIONS_CACHE),mkdir -p "$(COLLECTIONS_CACHE)",:)
galaxy      := if [ -f requirements.yml ]; then $(call retry,ansible-galaxy collection install -r requirements.yml); fi
mol-args := $(if $(SCENARIO),-s $(SCENARIO),--all)
core-image := $(if $(ANSIBLE_CORE),$(ANSIBLE_DEV_TOOLS_IMAGE_PY313),$(ANSIBLE_DEV_TOOLS_IMAGE))

docker-run := docker run --rm \
	$(cache-mount) \
	-v "$(CURDIR):/workspace:ro" \
	-w /workspace \
	$(ANSIBLE_DEV_TOOLS_IMAGE)

# molecule needs write access (scenario cache, tmp files)
docker-run-rw := docker run --rm \
	$(cache-mount) \
	-v "$(CURDIR):/workspace" \
	-w /workspace \
	$(core-image)

.PHONY: lint molecule ci

lint:
	@$(cache-dir)
	$(docker-run) bash -c "$(galaxy) && ansible-lint"

molecule:
	@$(cache-dir)
	$(docker-run-rw) bash -c "$(core-pin) ansible --version | head -n 1 \
		 && $(galaxy) \
		 && mkdir -p /tmp/roles \
		 && ln -s /workspace /tmp/roles/$(ROLE_NAME) \
		 && ANSIBLE_ROLES_PATH=/tmp/roles molecule test $(mol-args)"

ci: lint molecule
