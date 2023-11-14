# helm-charts
Helm Charts for PBUF projects

---

# pbuf-registry

This Helm chart installs the `pbuf-registry` in a Kubernetes cluster. The application relies on a PostgreSQL database, which should be configured separately and provided to the application through a DSN.

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

| Parameter                         | Description                                                                                                            | Default                                                                                             |
|-----------------------------------|------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------|
| `replicaCount`                    | Number of replicas                                                                                                     | `2`                                                                                                 |
| `image.repository`                | The image repository to pull from                                                                                      | `ghcr.io/pbufio/registry`                                                                           |
| `image.pullPolicy`                | Image pull policy                                                                                                      | `IfNotPresent`                                                                                      |
| `image.tag`                       | Overrides the image tag whose default is the chart `appVersion`.                                                       | `""`                                                                                                |
| `imagePullSecrets`                | Specify docker-registry secret names as an array                                                                       | `[]`                                                                                                |
| `nameOverride`                    | Override the app name                                                                                                  | `""`                                                                                                |
| `fullnameOverride`                | Override the fullname of the chart                                                                                     | `""`                                                                                                |
| `serviceAccount.create`           | Specifies whether a service account should be created                                                                  | `true`                                                                                              |
| `serviceAccount.automount`        | Automatically mount a ServiceAccount's API credentials?                                                                | `true`                                                                                              |
| `serviceAccount.annotations`      | Annotations to add to the service account                                                                              | `{}`                                                                                                |
| `serviceAccount.name`             | The name of the service account to use. If not set and create is true, a name is generated using the fullname template | `""`                                                                                                |
| `podAnnotations`                  | Annotations to add to the pod                                                                                          | `{}`                                                                                                |
| `podLabels`                       | Labels to add to the pod                                                                                               | `{}`                                                                                                |
| `podSecurityContext`              | Security context for the pod                                                                                           | `{}`                                                                                                |
| `securityContext`                 | Security context for the container                                                                                     | `{}`                                                                                                |
| `service.type`                    | Type of service to create                                                                                              | `ClusterIP`                                                                                         |
| `service.http.port`               | Service HTTP port                                                                                                      | `8080`                                                                                              |
| `service.grpc.port`               | Service GRPC port                                                                                                      | `8081`                                                                                              |
| `service.debug.port`              | Service debug port                                                                                                     | `8082`                                                                                              |
| `secrets.create`                  | Specifies whether to create a secret                                                                                   | `true`                                                                                              |
| `secrets.databaseDSN`             | The DSN for the database                                                                                               | `""`                                                                                                |
| `secrets.eso.create`              | Specifies whether to create resources for external secrets operator                                                    | `false`                                                                                             |
| `secrets.eso.secretStoreRefName`  | The name reference to the secret store for ESO                                                                         | `""`                                                                                                |
| `secrets.eso.remoteRefKey`        | The key reference in the remote store for ESO                                                                          | `""`                                                                                                |
| `secrets.eso.databaseDSNProperty` | The property name for the DSN in the ESO                                                                               | `""`                                                                                                |
| `ingress.enabled`                 | Enable ingress controller resource                                                                                     | `false`                                                                                             |
| `ingress.className`               | Ingress class name                                                                                                     | `""`                                                                                                |
| `ingress.annotations`             | Ingress annotations                                                                                                    | `{}`                                                                                                |
| `ingress.hosts`                   | Ingress accepted hostnames                                                                                             | `[{"host": "chart-example.local", "paths": [{"path": "/", "pathType": "ImplementationSpecific"}]}]` |
| `ingress.tls`                     | Ingress TLS settings                                                                                                   | `[]`                                                                                                |
| `resources`                       | CPU/Memory resource requests/limits                                                                                    | `{}`                                                                                                |
| `nodeSelector`                    | Node labels for pod assignment                                                                                         | `{}`                                                                                                |
| `tolerations`                     | Tolerations for pod assignment                                                                                         | `[]`                                                                                                |
| `affinity`                        | Map of node/pod affinities                                                                                             | `{}`                                                                                                |
| `customSidecarContainers`         | List of custom sidecar containers                                                                                      | `[]`                                                                                                |

## Uninstalling the Chart
To uninstall/delete the my-pbuf-registry deployment:

```shell
helm delete my-pbuf-registry
```