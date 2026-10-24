# Changelog

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](https://semver.org/) and
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

Releases before 2.0.0 are listed on the [GitHub releases page](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/releases).

## [Unreleased]

## [2.0.0] - 2026-10-24

Moves Ofelia into its own role, prefixes all variables and manages Docker Compose with the compose module. Work through
the Breaking Changes before you update; the README has an upgrade table.

### Breaking Changes
- Require ansible-core 2.19 or newer; 2.18 is no longer supported [`28e9172`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/28e9172)
- Remove Ofelia (`OFELIA_VERSION`, `handlers/restart-ofelia.yml`); deploy it with the new `gesinn.manage_ofelia` role after this role [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Rename the variables to `manage_traefik_version`, `manage_traefik_installation_path`, `manage_traefik_acme_email`, `manage_traefik_log_level` and `manage_traefik_extra_certs_folder`; `manage_traefik_version` is now required [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Replace the task file `ensure-traefik.yml` by `tasks/main.yml` and the handler files by `tasks_from: restart`; `set-log-level` is called as before [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Remove `TRAEFIK_DASHBOARD_PASSWORD`, which never set a password but opened the unauthenticated dashboard; use `manage_traefik_dashboard_enabled`, which publishes the dashboard on `127.0.0.1` only [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Stop using the `docker_compose` variable; the role needs `community.docker` 3.6 or newer and the Docker Compose plugin [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)

### Added
- Add `manage_traefik_network`, `manage_traefik_acme_resolver` and `manage_traefik_manage_service`, and reject invalid input before anything is changed [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Create `acme.json` with mode 0600 when ACME is configured [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)

### Changed
- Mount the Docker socket read-only; the first run recreates the Traefik container [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Restart Traefik only when `traefik.yml` changed; `set-log-level` applies its change itself [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Remove the Ofelia container of 1.x from the Traefik compose project on the first run [`f685255`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/f685255)
- Document usage, variables, handlers and the upgrade from 1.x in the README [`cef7b2c`](https://github.com/gesinn-it-pub/ansible-role-manage-traefik/commit/cef7b2c)

[Unreleased]: https://github.com/gesinn-it-pub/ansible-role-manage-traefik/compare/2.0.0...HEAD
[2.0.0]: https://github.com/gesinn-it-pub/ansible-role-manage-traefik/compare/1.2.0...2.0.0
