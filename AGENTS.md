# AGENTS.md

## What this repo is

CiteLibre ops: Kubernetes deployment of the CiteLibre services suite with Yupiik
Bundlebee, plus Minikube helper scripts. No application code: changes are Bundlebee
manifests, Kubernetes JSON descriptors, placeholders and scripts.

CiteLibre is split into three sibling repositories (usually cloned side by side):

- `packaging`: Maven assembly + Docker image build (Jib) of each service.
- `demo`: Docker Compose stack and e2e tests.
- `ops` (this one): Kubernetes deployment.

## Toolchain

- Maven ≥ 3.6 + Java ≥ 17 (enforcer). No `mvnw` wrapper, use `mvn`.
- `pom.xml` only configures `bundlebee-maven-plugin` (no profile needed) and the
  license check (BSD 2-Clause header on `.properties/.xml/.yaml`, `validate` phase;
  `mvn license:format` fixes it).

## Deployment (Bundlebee)

- Descriptors: `bundlebee/` (`manifest.json` + `manifests/*.json`, alveolus
  `citelibre`; Kubernetes descriptors in `bundlebee/kubernetes/`).
- Apply: `mvn -e bundlebee:apply@k8s`; delete: `mvn -e bundlebee:delete@k8s`;
  dry-run + verbose: `-Dbundlebee.debug=true`; other alveolus: `-Ddeployment.alveolus=…`.
- Default placeholder values: `bundlebee/environments/default.properties`.
- `scripts/0_install.sh` … `7_delete.sh` wrap minikube around these commands
  (`3_deploy.sh` / `4_destroy.sh` cd to the repo root, they can be run from anywhere).
- Images (`citelibre/citelibre-<app>`) are built in the `packaging` repo.

## Placeholder documentation

- The plugin skips `pom` packaging by default, which would silently skip every goal
  (including `apply`/`delete`): `pom.xml` sets `<skipPackaging>none</skipPackaging>` —
  keep it.
- Without a cluster, `mvn bundlebee:lint@k8s`, `bundlebee:list-alveoli@k8s` and
  `bundlebee:process@k8s -Dbundlebee.process.output=target/rendered` check and render
  the descriptors.
- Placeholders should be documented in
  `bundlebee/placeholders.descriptions.properties`. The `placeholder-extract`
  execution (`process-classes`, `failOnInvalidDescription=true`, output in
  `target/generated/deployment`) is skipped by default
  (`bundlebee.placeholder-extract.skip=true`): run with
  `-Dbundlebee.placeholder-extract.skip=false` to check — it fails today because many
  placeholders (`citelibre-elasticsearch.*`, `bundlebee.environment`, …) are not
  described yet.

## Community files

- `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md` and `SECURITY.md` are identical copies in
  `packaging`, `demo`, `ops` and the org `.github` repository (org-wide default). When
  changing one, apply the same change to all four copies. Keep their links relative
  (`CODE_OF_CONDUCT.md`, `SECURITY.md`) or absolute and repo-independent.
- Issue and pull request templates live only in the org `.github` repository; do not add
  a `.github/ISSUE_TEMPLATE/` here, it would replace all the org templates.
