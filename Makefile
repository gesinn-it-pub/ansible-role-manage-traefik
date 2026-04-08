ANSIBLE_LINT_IMAGE := ghcr.io/ansible/community-ansible-dev-tools:26.4.0

docker-run := docker run --rm \
	-v "$(CURDIR):/workspace:ro" \
	-w /workspace \
	$(ANSIBLE_LINT_IMAGE)

.PHONY: lint ci

lint:
	$(docker-run) bash -c "ansible-galaxy collection install -r requirements.yml && ansible-lint"

ci: lint
