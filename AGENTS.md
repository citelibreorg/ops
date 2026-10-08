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
  `citelibre` = `namespace` + `citelibre-platform` + `citelibre-application`;
  Kubernetes descriptors in `bundlebee/kubernetes/`, injected files in
  `bundlebee/resources/`).
- Apply: `mvn -e bundlebee:apply@k8s`; delete: `mvn -e bundlebee:delete@k8s`;
  dry-run + verbose: `-Dbundlebee.debug=true`; other alveolus: `-Ddeployment.alveolus=…`.
  Descriptors with `await` wait up to `bundlebee.apply.descriptorAwaitTimeout`
  (5 min in `pom.xml`: Keycloak first start, SQL imports).
- Default placeholder values: `bundlebee/environments/default.properties` (local dev
  values, incl. the dev OAuth2 client secrets). Override with `-D<placeholder>=…`.
- `scripts/0_install.sh` … `8_delete.sh` wrap minikube around these commands
  (`3_deploy.sh` / `5_destroy.sh` cd to the repo root, they can be run from anywhere).
  `3_deploy.sh` loads the locally built images into minikube (`CITELIBRE_IMAGES`);
  `4_expose.sh` port-forwards the ingress controller to `http://localhost:8088`.
- Images (`citelibre/citelibre-<app>`) are built in the `packaging` repo.

## Platform and applications

- Platform: MariaDB (single instance shared by every database), Elasticsearch, Solr,
  Keycloak (`KC_HTTP_RELATIVE_PATH=/keycloak`, theme from a ConfigMap). Applications:
  RendezVous (generic `application-template`, env in
  `kubernetes/applications/citelibre-rendezvous/configmap.json`). One nginx Ingress
  serves `/keycloak` and `/citelibre-<app>`.
- Public URLs must be `http://localhost*`: the Keycloak clients (demo realm data) only
  allow these redirect URIs. `citelibre.public.url` (default `http://localhost:8088`)
  drives Lutece URLs and `KC_HOSTNAME`; server-to-server calls (token, userinfo) use
  `http://citelibre-keycloak:8080/keycloak`.
- Databases are created by `database-init-template` (ConfigMap + Job), parameterized by
  `dbinit.name` (= folder `bundlebee/resources/sql/<dbinit.name>/`, files imported in
  alphabetical order) and `dbinit.database`. `resources/sql/init_db.sh` is idempotent
  (skips an existing database, drops it on a failed import). Job specs are immutable, so
  each deployment creates a new Job suffixed with `bundlebee.deploytime`, garbage
  collected after `dbinit.ttlSecondsAfterFinished`. Do not use the
  `io.yupiik.bundlebee/force` annotation on Jobs: it deletes then PUTs → 404.
- A ConfigMap read through `envFrom` must be created before its Deployment: put it in
  its own alveolus listed before the template, with `chainDependencies: true`
  (see `citelibre-rendezvous`).
- SQL files and the Keycloak theme are copies of the `demo` repo files: keep them in sync.
- Keycloak needs ≥ 2Gi (OOMKilled at 1Gi during its startup build).
- Every apply restarts the pods: the templates put `deploy.at` in the pod labels.
- `bundlebee:lint@k8s` must stay clean (only the "replicas >= 3" warnings are
  expected): pods use the `citelibre` ServiceAccount (no token automount) and set
  `dnsConfig`; containers declare resources.

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
