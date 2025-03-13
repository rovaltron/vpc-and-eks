# Web Application Helm Chart

This Helm chart deploys a basic web application on Kubernetes.

## Features

- Basic web application deployment using nginx
- LoadBalancer service type for external access
- Resource limits and requests
- Liveness and readiness probes
- Pod Disruption Budget for high availability

## Configuration

The following table lists the configurable parameters of the web application chart and their default values.

| Parameter | Description | Default |
|-----------|-------------|---------|
| `replicaCount` | Number of replicas | `2` |
| `image.repository` | Image repository | `nginx` |
| `image.tag` | Image tag | `1.21.1` |
| `image.pullPolicy` | Image pull policy | `IfNotPresent` |
| `service.type` | Service type | `LoadBalancer` |
| `service.port` | Service port | `80` |
| `resources.limits.cpu` | CPU limit | `100m` |
| `resources.limits.memory` | Memory limit | `128Mi` |
| `resources.requests.cpu` | CPU request | `50m` |
| `resources.requests.memory` | Memory request | `64Mi` |
| `podDisruptionBudget.enabled` | Enable PDB | `true` |
| `podDisruptionBudget.minAvailable` | Minimum available pods | `1` |

## Usage

```bash
helm install my-webapp ./webapp
```
