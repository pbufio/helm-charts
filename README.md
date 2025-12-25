# helm-charts
Helm Charts for PBUF projects

---

# pbuf-registry

This Helm chart installs the `pbuf-registry` in a Kubernetes cluster. The application relies on a PostgreSQL database, which can be deployed internally for development/testing or configured to use an external database for production.

## Prerequisites

- Kubernetes 1.21+
- Helm 3.0+

## Installation

Add repository to Helm:

```shell
helm repo add pbuf https://pbufio.github.io/helm-charts
```

To install the chart with the release name `my-pbuf-registry`:

```shell
helm install my-pbuf-registry pbuf/pbuf-registry
```

## Configuration
The following table lists the configurable parameters of the `pbuf-registry` chart and their default values.

| Parameter                                   | Description                                                                                                               | Default                                                                                             |
|---------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `replicaCount`                              | Number of replicas                                                                                                        | `2`                                                                                                 |
| `image.repository`                          | The image repository to pull from                                                                                         | `ghcr.io/pbufio/registry`                                                                           |
| `image.pullPolicy`                          | Image pull policy                                                                                                         | `IfNotPresent`                                                                                      |
| `image.tag`                                 | Overrides the image tag whose default is the chart `appVersion`.                                                          | `""`                                                                                                |
| `imagePullSecrets`                          | Specify docker-registry secret names as an array                                                                          | `[]`                                                                                                |
| `nameOverride`                              | Override the app name                                                                                                     | `""`                                                                                                |
| `fullnameOverride`                          | Override the fullname of the chart                                                                                        | `""`                                                                                                |
| `serviceAccount.create`                     | Specifies whether a service account should be created                                                                     | `true`                                                                                              |
| `serviceAccount.automount`                  | Automatically mount a ServiceAccount's API credentials?                                                                   | `true`                                                                                              |
| `serviceAccount.annotations`                | Annotations to add to the service account                                                                                 | `{}`                                                                                                |
| `serviceAccount.name`                       | The name of the service account to use. If not set and create is true, a name is generated using the fullname template    | `""`                                                                                                |
| `podAnnotations`                            | Annotations to add to the pod                                                                                             | `{}`                                                                                                |
| `podLabels`                                 | Labels to add to the pod                                                                                                  | `{}`                                                                                                |
| `podSecurityContext`                        | Security context for the pod                                                                                              | `{}`                                                                                                |
| `securityContext`                           | Security context for the container                                                                                        | `{}`                                                                                                |
| `service.type`                              | Type of service to create                                                                                                 | `ClusterIP`                                                                                         |
| `service.http.port`                         | Service HTTP port                                                                                                         | `8080`                                                                                              |
| `service.http.auth.enabled`                 | Service HTTP authentication enabled                                                                                       | `false`                                                                                             |
| `service.http.auth.type`                    | Service HTTP authentication type ("", static-token)                                                                       | `""`                                                                                                |
| `service.grpc.port`                         | Service GRPC port                                                                                                         | `6777`                                                                                              |
| `service.grpc.tls.enabled`                  | Service GRPC TLS enabled                                                                                                  | `false`                                                                                             |
| `service.grpc.auth.enabled`                 | Service GRPC authentication enabled                                                                                       | `false`                                                                                             |
| `service.grpc.auth.type`                    | Service GRPC authentication type ("", static-token)                                                                       | `""`                                                                                                |
| `service.debug.port`                        | Service debug port                                                                                                        | `8082`                                                                                              |
| `secrets.create`                            | Specifies whether to create a secret                                                                                      | `true`                                                                                              |
| `secrets.databaseDSN`                       | The DSN for the database                                                                                                  | `""`                                                                                                |
| `secrets.staticToken`                       | Static Token for `static-token` auth type                                                                                 | `""`                                                                                                |
| `secrets.grpcTlsCert`                       | TLS certificate for GRPC transport                                                                                        | `""`                                                                                                |
| `secrets.grpcTlsKey`                        | TLS private key for GRPC transport                                                                                        | `""`                                                                                                |
| `secrets.eso.create`                        | Specifies whether to create resources for external secrets operator                                                       | `false`                                                                                             |
| `secrets.eso.secretStoreRefName`            | The name reference to the secret store for ESO                                                                            | `""`                                                                                                |
| `secrets.eso.remoteRefKey`                  | The key reference in the remote store for ESO                                                                             | `""`                                                                                                |
| `secrets.eso.databaseDSNProperty`           | The property name for the DSN in the ESO                                                                                  | `""`                                                                                                |
| `secrets.eso.serverStaticTokenProperty`     | The property name for the static token                                                                                    | `""`                                                                                                |
| `secrets.eso.serverGrpcTlsCertFileProperty` | The property name for the TLS certificate                                                                                 | `""`                                                                                                |
| `secrets.eso.serverGrpcTlsKeyFileProperty`  | The property name for the TLS private key                                                                                 | `""`                                                                                                |
| `ingress.enabled`                           | Enable ingress controller resource                                                                                        | `false`                                                                                             |
| `ingress.className`                         | Ingress class name                                                                                                        | `""`                                                                                                |
| `ingress.annotations`                       | Ingress annotations                                                                                                       | `{}`                                                                                                |
| `ingress.hosts`                             | Ingress accepted hostnames                                                                                                | `[{"host": "chart-example.local", "paths": [{"path": "/", "pathType": "ImplementationSpecific"}]}]` |
| `ingress.tls`                               | Ingress TLS settings                                                                                                      | `[]`                                                                                                |
| `resources`                                 | CPU/Memory resource requests/limits                                                                                       | `{}`                                                                                                |
| `nodeSelector`                              | Node labels for pod assignment                                                                                            | `{}`                                                                                                |
| `tolerations`                               | Tolerations for pod assignment                                                                                            | `[]`                                                                                                |
| `affinity`                                  | Map of node/pod affinities                                                                                                | `{}`                                                                                                |
| `customSidecarContainers`                   | List of custom sidecar containers                                                                                         | `[]`                                                                                                |
| `background.compaction.enabled`             | Enable background compaction                                                                                              | `true`                                                                                              |
| `background.compaction.resources`           | CPU/Memory resource requests/limits for background compaction                                                             | `{}`                                                                                                |
| `background.compaction.command`             | Command to run for background compaction                                                                                  | `/app/pbuf-registry`                                                                                |
| `background.compaction.args`                | Arguments to pass to the background compaction command                                                                    | `["compaction"]`                                                                                    |
| `background.protoparser.enabled`            | Enable background proto parsing                                                                                           | `true`                                                                                              |
| `background.protoparser.resources`          | CPU/Memory resource requests/limits for background proto parsing                                                          | `{}`                                                                                                |
| `background.protoparser.command`            | Command to run for background proto parsing                                                                               | `/app/pbuf-registry`                                                                                |
| `background.protoparser.args`               | Arguments to pass to the background proto parsing command                                                                 | `["proto-parsing"]`                                                                                 |
| `postgresql.enabled`                        | Enable internal PostgreSQL deployment (for dev/test, disable for production)                                              | `true`                                                                                              |
| `postgresql.image.repository`               | PostgreSQL image repository                                                                                               | `postgres`                                                                                          |
| `postgresql.image.tag`                      | PostgreSQL image tag                                                                                                      | `18.1-alpine3.21`                                                                                   |
| `postgresql.image.pullPolicy`               | PostgreSQL image pull policy                                                                                              | `IfNotPresent`                                                                                      |
| `postgresql.auth.username`                  | PostgreSQL username                                                                                                       | `pbuf`                                                                                              |
| `postgresql.auth.password`                  | PostgreSQL password                                                                                                       | `pbuf`                                                                                              |
| `postgresql.auth.database`                  | PostgreSQL database name                                                                                                  | `pbuf_registry`                                                                                     |
| `postgresql.primary.persistence.enabled`    | Enable PostgreSQL persistent volume                                                                                       | `true`                                                                                              |
| `postgresql.primary.persistence.storageClass` | PostgreSQL persistent volume storage class                                                                              | `""`                                                                                                |
| `postgresql.primary.persistence.size`       | PostgreSQL persistent volume size                                                                                         | `8Gi`                                                                                               |
| `postgresql.primary.resources`              | CPU/Memory resource requests/limits for PostgreSQL                                                                        | `{}`                                                                                                |

## Database Configuration

### Internal PostgreSQL (Development/Testing)

For development and testing, you can deploy PostgreSQL as part of the chart:

```shell
helm install my-pbuf-registry pbuf/pbuf-registry \
  --set postgresql.enabled=true \
  --set postgresql.primary.persistence.enabled=true \
  --set secrets.staticToken=your-token-here
```

### External PostgreSQL (Production)

For production, disable internal PostgreSQL and provide an external database DSN:

```shell
helm install my-pbuf-registry pbuf/pbuf-registry \
  --set postgresql.enabled=false \
  --set secrets.databaseDSN="postgres://user:password@host:5432/database?sslmode=require" \
  --set secrets.staticToken=your-token-here
```

## Local Development

### Helm Linting

To run Helm lint checks locally (matching CI configuration):

```shell
./scripts/lint.sh
```

This script will:
- Run `helm lint` on the chart
- Run `ct lint` (chart-testing) to validate the chart structure
- Ensure your changes pass the same checks as CI

**Prerequisites:**
- [Helm](https://helm.sh/docs/intro/install/) v3+
- [chart-testing (ct)](https://github.com/helm/chart-testing) - Install via `brew install chart-testing` (macOS) or from releases

## E2E Testing

This chart includes comprehensive end-to-end tests using Kind (Kubernetes in Docker). The tests include:
- Helm chart deployment and health checks
- Internal and external PostgreSQL configurations
- **pbuf CLI functional testing** - Register, push, and vendor protobuf modules

See [tests/e2e/README.md](tests/e2e/README.md) for detailed instructions.

### Quick Start

```shell
cd tests/e2e
./run-e2e-tests.sh
```

The e2e tests automatically run in CI/CD via GitHub Actions on pull requests and pushes to main.

## Uninstalling the Chart
To uninstall/delete the my-pbuf-registry deployment:

```shell
helm delete my-pbuf-registry
```