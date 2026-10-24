#!/bin/sh
# Workaround while Galaxy is down: install the collections of requirements.yml from their GitHub repositories
# (latest release tag) into the collections cache, so that lint and Molecule find them without contacting Galaxy.
# Dependencies are skipped on purpose: they would be fetched from Galaxy, and the one of community.docker is only used
# by its inventory plugins.
# Remove together with the seed-collections target once Galaxy is reliable again.
set -eu

list_names='import yaml
r = yaml.safe_load(open("requirements.yml")) or {}
print(*[c["name"] for c in r.get("collections", [])])'
names=$(python3 -c "$list_names")
for name in $names; do
	repo="https://github.com/ansible-collections/$name.git"
	tag=$(git ls-remote --tags --sort=-v:refname "$repo" | sed 's#.*refs/tags/##' \
		| grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1)
	[ -n "$tag" ] || { echo "no release tag found for $name" >&2; exit 1; }
	echo "Installing $name $tag from $repo"
	ansible-galaxy collection install --force --no-deps "git+$repo,$tag"
done
