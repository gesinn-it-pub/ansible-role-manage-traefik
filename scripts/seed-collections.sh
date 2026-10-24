#!/bin/sh
# Workaround while Galaxy is down: install the collections of requirements.yml from their GitHub repositories
# into the collections cache, so that lint and Molecule find them without contacting Galaxy. An exact version in
# requirements.yml is installed as that release, anything else as the latest release.
# Dependencies are skipped on purpose: they would be fetched from Galaxy, and the one of community.docker is only used
# by its inventory plugins.
# Remove together with the seed-collections target once Galaxy is reliable again.
set -eu

latest_tag() {
	git ls-remote --tags --sort=-v:refname "$1" | sed 's#.*refs/tags/##' \
		| grep -E '^[0-9]+\.[0-9]+\.[0-9]+$' | head -n 1
}

list_collections='import yaml
r = yaml.safe_load(open("requirements.yml")) or {}
for c in r.get("collections", []):
    print(c["name"], c.get("version", ""))'

python3 -c "$list_collections" | while read -r name version; do
	repo="https://github.com/ansible-collections/$name.git"
	case "$version" in
		[0-9]*.[0-9]*.[0-9]*) tag=$version ;;
		*) tag=$(latest_tag "$repo") ;;
	esac
	[ -n "$tag" ] || { echo "no release tag found for $name" >&2; exit 1; }
	echo "Installing $name $tag from $repo"
	ansible-galaxy collection install --force --no-deps "git+$repo,$tag"
done
