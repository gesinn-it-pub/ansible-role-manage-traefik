<!-- THIS FILE IS AUTO-GENERATED. Edit AGENTS-source.adoc instead. -->

# Coding Conventions

**Coding Conventions — General**

All source files regardless of language must follow these baseline
rules.

- Encoding: UTF-8 without BOM

- Line endings: Unix-style LF (not CR+LF)

- Maximum line length: 120 characters

- No trailing whitespace

- Newline at end of file

**Coding Conventions — YAML**

The YAML specification forbids tab characters for indentation — these
rules take precedence over the general indentation rule for all `.yml`
and `.yaml` files.

- Indentation: 2 spaces (never tabs)

- Strings: use double quotes for values containing special characters;
  omit quotes where unambiguous

- Booleans: `true`/`false` (unquoted) — never `yes`/`no` or `on`/`off`

- Explicit `null` over empty values where the intent matters

- Multi-line strings: `|` (literal block) for human-readable text, `>`
  (folded) for long single-line values

- Always add a blank line between top-level keys for readability

**Coding Conventions — Ansible**

Tooling: [ansible-lint](https://ansible-lint.readthedocs.io/).

**Role structure**

Follows the [Ansible Galaxy standard
layout](https://galaxy.ansible.com/docs/contributing/creating_role.html):

    defaults/main.yml    # user-overridable variables (low precedence)
    vars/main.yml        # role-internal constants
    tasks/main.yml       # main task entry point
    handlers/main.yml
    templates/           # Jinja2 templates (.j2)
    files/               # static files
    meta/main.yml        # role metadata + version comment

**Version tracking in meta/main.yml**

`galaxy_info.version` is not a valid schema field and causes
`ansible-lint` violations. Track the version as a comment at the top of
`meta/main.yml`:

``` yaml
---
# version: 1.0.0
dependencies: []

galaxy_info:
  role_name: my_role
  author: gesinn-it
```

**Variable naming**

- All role variables prefixed with the role name: `manage_traefik_port`,
  not `port`

- `defaults/main.yml`: user-overridable settings

- `vars/main.yml`: role-internal constants not intended for override

**Task conventions**

- Every task must have a descriptive `name:` (written as a sentence)

- Use FQCN for all modules: `ansible.builtin.copy`, not `copy`

- Tasks must be idempotent; add `changed_when: false` for read-only
  tasks

- Split related tasks into separate files, included via
  `ansible.builtin.include_tasks`

**Handlers**

- Handler names must match their `notify:` string exactly

- Handlers only restart or reload services — configuration logic belongs
  in tasks

**Dependencies (requirements.yml)**

- List role dependencies without version pins — consumer projects are
  the single source of truth for versions

**Security**

- No plaintext secrets in variable files or templates — use Ansible
  Vault or environment injection

- Use `become: true` at task level, not play level, to minimise
  privilege escalation scope

**Coding Conventions — Molecule**

Tooling: [Molecule](https://ansible.readthedocs.io/projects/molecule/)
via `ghcr.io/ansible/community-ansible-dev-tools`.

**Scenario structure**

Each scenario lives in `molecule/<scenario-name>/` and contains:

    molecule/<scenario-name>/
      molecule.yml    # driver + platforms + verifier configuration
      converge.yml    # playbook that applies the role under test
      verify.yml      # playbook with assertions
      destroy.yml     # teardown playbook (if custom cleanup is needed)

**Scenario naming**

- Lowercase with hyphens; name describes the tested configuration
  variant: `with-ofelia`, `without-tls`

- One scenario per distinct configuration; avoid a catch-all `default`
  scenario

**Driver**

- Use the `default` driver with `ansible_connection: local` — no VM
  overhead in CI

- Set `ANSIBLE_ROLES_PATH` so the role under test is resolvable by name

**Verifier**

- Use the Ansible verifier (`verifier: name: ansible`) with
  `ansible.builtin.assert`

- Write assertions that verify observable outcomes (files exist, config
  contains expected values), not internal role variables

- Name each assertion task clearly: `Assert Traefik version is correct`

**Skipping tasks in Molecule context**

- Tag tasks that must not run in Molecule (e.g. system-level side
  effects) with `molecule_skip`

- Configure the provisioner to skip them:
  `options: skip-tags: molecule_skip`

**CI matrix**

- Run all scenarios in a matrix; add a version axis for
  externally-versioned dependencies (e.g. `traefik_version`)

- Use `fail-fast: false` so all matrix cells are reported even if one
  fails

- Pin the `community-ansible-dev-tools` image version for
  reproducibility

**Coding Conventions — Dockerfile**

Tooling: [hadolint](https://github.com/hadolint/hadolint).

**Base image**

- Always pin base images to a specific version tag — never use `latest`

- Prefer official images from Docker Hub or GitHub Container Registry

- Document the rationale for the chosen base image in a comment

**Layer optimisation**

- Combine related `RUN` commands with `&&` and `\` to minimise layer
  count and improve cache reuse

- Delete package manager caches in the same `RUN` layer:
  `apt-get clean && rm -rf /var/lib/apt/lists/*`

- Order instructions from least to most frequently changed (maximises
  cache hits)

- Use `COPY` instead of `ADD` unless explicitly extracting a tar archive

**Security**

- Run as a non-root user: `RUN useradd -r appuser` followed by
  `USER appuser`

- Never store secrets in image layers — they are visible in
  `docker history` regardless of later deletion

- Use multi-stage builds to exclude build tools and intermediate
  artefacts from the final image

**Configuration**

- `ARG` for build-time values; `ENV` only for runtime configuration

- Add a `HEALTHCHECK` in production images

- Add OCI image labels: `org.opencontainers.image.source`, `.version`,
  `.description`

**.dockerignore**

- Every repository with a Dockerfile must include a `.dockerignore`

- Exclude at minimum: `.git/`, `node_modules/`, `*.log`, and local
  override files

**Coding Conventions — Docker Compose**

**File structure**

- `docker-compose.yml` is the canonical base; local overrides belong in
  `docker-compose.override.yml`

- `docker-compose.override.yml` is always listed in `.gitignore` — never
  committed

- Omit the top-level `version:` field (deprecated in Compose v2); start
  directly with `services:`

**Services**

- Service names: lowercase with hyphens (`wiki`, `mysql`, `smtp`)

- Always set `container_name` for stable references in scripts and CI

- Set `restart: unless-stopped` on all long-running services

**Volumes**

- Named volumes for persistent data; bind mounts only for local
  development overrides

**Compose v2**

- Use the Docker Compose plugin (`docker compose`, with a space) — never
  the legacy `docker-compose` binary (v1, EOL)

- In Ansible roles: set `docker_install_compose_plugin: true`; never use
  `docker_install_compose: true`

# Commit Convention

# Conventional Commits Policy

Commit messages follow the [Conventional Commits
specification](https://www.conventionalcommits.org/).

Commit format:

`type(scope): short description`

The scope is optional and should describe the affected subsystem,
module, or dependency when useful.

Examples:

- feat(api): add autocomplete endpoint

- fix(parser): handle empty token lists

- docs(readme): explain input architecture

- refactor(parser): simplify token parsing

- deps(smw): bump from 5.1.0 to 5.2.0

- ci(github): update workflow configuration

- test(api): add autocomplete tests

Recommended commit types:

- `feat` — new functionality

- `fix` — bug fixes

- `deps` — dependency updates

- `docs` — documentation changes

- `refactor` — internal code changes without behavioral change

- `test` — tests added or updated

- `ci` — changes to continuous integration configuration

- `chore` — repository maintenance tasks without impact on runtime
  behavior

Dependency updates:

- Use the `deps` type for dependency upgrades

- The scope should identify the dependency being updated

- Include the version change when applicable

Example:

- deps(smw): bump from 5.1.0 to 5.2.0

Guidelines:

- Use the imperative mood (e.g. "add feature", not "added feature")

- Keep the subject line concise

- Use the commit body to explain **why**, not only **what**

- Scopes should be short, lowercase identifiers (e.g. `api`, `parser`,
  `smw`, `mediawiki`, `docker`)

- Use `chore` only for repository maintenance tasks that do not affect
  runtime behavior, dependencies, CI configuration, or tests

# Project-Specific Conventions

**Variable naming — UPPERCASE exception**

This role deliberately uses `UPPERCASE` variable names (e.g.
`TRAEFIK_VERSION`, `OFELIA_VERSION`, `TRAEFIK_INSTALLATION_PATH`)
instead of the standard lowercase `manage_traefik_` prefix.

Rationale: UPPERCASE names are a deliberate signal to consumers that
these are **required input parameters** passed in from the outside
(analogous to environment variables), not internal role variables. This
convention predates the prefix rule and is kept for backward
compatibility with all existing consumer projects (e.g. wiki-factory). A
rename would be a breaking change and is therefore deferred until a
major version bump.
