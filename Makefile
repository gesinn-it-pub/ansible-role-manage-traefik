ANSIBLE_LINT_IMAGE := ghcr.io/ansible/community-ansible-dev-tools:26.4.0
TRAEFIK_VERSION    ?= 3.3

docker-run := docker run --rm \
	-v "$(CURDIR):/workspace:ro" \
	-w /workspace \
	$(ANSIBLE_LINT_IMAGE)

# molecule needs write access (scenario cache, tmp files)
docker-run-rw := docker run --rm \
	-v "$(CURDIR):/workspace" \
	-w /workspace \
	$(ANSIBLE_LINT_IMAGE)

.PHONY: lint molecule ci

lint:
	$(docker-run) bash -c "ansible-galaxy collection install -r requirements.yml && ansible-lint"

molecule:
	docker run --rm \
		-v "$(CURDIR):/workspace" \
		-w /workspace \
		-e TRAEFIK_VERSION=$(TRAEFIK_VERSION) \
		$(ANSIBLE_LINT_IMAGE) \
		bash -c "mkdir -p /tmp/roles \
		         && ln -s /workspace /tmp/roles/ansible-role-manage-traefik \
		         && ansible-galaxy collection install -r requirements.yml \
		         && ANSIBLE_ROLES_PATH=/tmp/roles molecule test -s without-ofelia \
		         && ANSIBLE_ROLES_PATH=/tmp/roles molecule test -s with-ofelia"

ci: lint molecule
