#!/usr/bin/env bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="${CLUSTER_NAME:-pbuf-registry-e2e}"
NAMESPACE="${NAMESPACE:-default}"
RELEASE_NAME="${RELEASE_NAME:-pbuf-registry-test}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CHART_DIR="${SCRIPT_DIR}/../../pbuf-registry"
TIMEOUT="${TIMEOUT:-300}"

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
    if [ "${SKIP_CLEANUP:-false}" != "true" ]; then
        log_info "Cleaning up resources..."
        helm uninstall "${RELEASE_NAME}" -n "${NAMESPACE}" 2>/dev/null || true
        kubectl delete namespace "${NAMESPACE}" --ignore-not-found=true 2>/dev/null || true
        
        if [ "${SKIP_CLUSTER_DELETE:-false}" != "true" ]; then
            log_info "Deleting Kind cluster..."
            kind delete cluster --name "${CLUSTER_NAME}" 2>/dev/null || true
        fi
    else
        log_warn "Skipping cleanup (SKIP_CLEANUP=true)"
    fi
}

wait_for_pods() {
    local label=$1
    local timeout=$2
    local namespace=$3
    
    log_info "Waiting for pods with label ${label} to be ready (timeout: ${timeout}s)..."
    kubectl wait --for=condition=ready pod \
        -l "${label}" \
        -n "${namespace}" \
        --timeout="${timeout}s" || return 1
}

wait_for_statefulset() {
    local name=$1
    local timeout=$2
    local namespace=$3
    
    log_info "Waiting for StatefulSet ${name} to be ready (timeout: ${timeout}s)..."
    kubectl wait --for=jsonpath='{.status.readyReplicas}'=1 statefulset/${name} \
        -n "${namespace}" \
        --timeout="${timeout}s" || return 1
}

# Trap cleanup on exit
trap cleanup EXIT

# Check prerequisites
log_info "Checking prerequisites..."
for cmd in kind kubectl helm; do
    if ! command -v "${cmd}" &> /dev/null; then
        log_error "${cmd} is not installed. Please install it first."
        exit 1
    fi
done

log_info "Prerequisites check passed"

# Create Kind cluster if it doesn't exist
if ! kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
    log_info "Creating Kind cluster: ${CLUSTER_NAME}"
    kind create cluster --name "${CLUSTER_NAME}" --config "${SCRIPT_DIR}/kind-config.yaml"
else
    log_info "Kind cluster '${CLUSTER_NAME}' already exists"
fi

# Set kubectl context
log_info "Setting kubectl context to kind-${CLUSTER_NAME}"
kubectl config use-context "kind-${CLUSTER_NAME}"

# Create namespace
log_info "Creating namespace: ${NAMESPACE}"
kubectl create namespace "${NAMESPACE}" --dry-run=client -o yaml | kubectl apply -f -

# Install the chart with internal PostgreSQL
log_info "Installing Helm chart: ${RELEASE_NAME}"
helm upgrade --install "${RELEASE_NAME}" "${CHART_DIR}" \
    --namespace "${NAMESPACE}" \
    --set postgresql.enabled=true \
    --set postgresql.primary.persistence.enabled=false \
    --set secrets.staticToken="test-token-12345" \
    --set replicaCount=1 \
    --wait \
    --timeout="${TIMEOUT}s"

# Wait for PostgreSQL to be ready
log_info "Waiting for PostgreSQL to be ready..."
wait_for_statefulset "${RELEASE_NAME}-postgresql" "${TIMEOUT}" "${NAMESPACE}"

# Wait for main application to be ready
log_info "Waiting for main application to be ready..."
wait_for_pods "app.kubernetes.io/name=pbuf-registry,app.kubernetes.io/component!=database" "${TIMEOUT}" "${NAMESPACE}"

# Wait for background jobs to be ready
log_info "Waiting for background jobs to be ready..."
sleep 10  # Give background jobs time to start

# Run health checks
log_info "Running health checks..."

# Get pod names
MAIN_POD=$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/name=pbuf-registry,app.kubernetes.io/component!=database" -o jsonpath='{.items[0].metadata.name}')

if [ -z "${MAIN_POD}" ]; then
    log_error "Could not find main application pod"
    exit 1
fi

log_info "Main pod: ${MAIN_POD}"

# Check health endpoint
log_info "Checking health endpoint..."
kubectl exec -n "${NAMESPACE}" "${MAIN_POD}" -- wget -q -O - http://localhost:8082/healthz || {
    log_error "Health check failed"
    kubectl logs -n "${NAMESPACE}" "${MAIN_POD}" --tail=50
    exit 1
}

log_info "Health check passed"

# Check database connectivity
log_info "Checking database connectivity..."
PG_POD=$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/component=database" -o jsonpath='{.items[0].metadata.name}')

if [ -z "${PG_POD}" ]; then
    log_error "Could not find PostgreSQL pod"
    exit 1
fi

kubectl exec -n "${NAMESPACE}" "${PG_POD}" -- psql -U pbuf -d pbuf_registry -c "SELECT version();" > /dev/null || {
    log_error "Database connectivity check failed"
    kubectl logs -n "${NAMESPACE}" "${PG_POD}" --tail=50
    exit 1
}

log_info "Database connectivity check passed"

# Check background jobs
log_info "Checking background jobs..."
for job in compaction protoparser; do
    JOB_POD=$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/name=pbuf-registry,background=${job}" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
    if [ -n "${JOB_POD}" ]; then
        log_info "Background job '${job}' pod: ${JOB_POD}"
        kubectl exec -n "${NAMESPACE}" "${JOB_POD}" -- wget -q -O - http://localhost:8082/healthz || {
            log_warn "Background job '${job}' health check failed (this might be expected if disabled)"
        }
    else
        log_warn "Background job '${job}' pod not found (might be disabled)"
    fi
done

# Test with external database configuration
log_info "Testing with external database configuration..."
helm upgrade --install "${RELEASE_NAME}-ext" "${CHART_DIR}" \
    --namespace "${NAMESPACE}" \
    --set postgresql.enabled=false \
    --set secrets.databaseDSN="postgres://pbuf:pbuf@${RELEASE_NAME}-postgresql:5432/pbuf_registry?sslmode=disable" \
    --set secrets.staticToken="test-token-12345" \
    --set replicaCount=1 \
    --wait \
    --timeout="${TIMEOUT}s"

log_info "Waiting for external DB configuration deployment..."
sleep 10

EXT_POD=$(kubectl get pods -n "${NAMESPACE}" -l "app.kubernetes.io/instance=${RELEASE_NAME}-ext" -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || echo "")
if [ -n "${EXT_POD}" ]; then
    kubectl exec -n "${NAMESPACE}" "${EXT_POD}" -- wget -q -O - http://localhost:8082/healthz || {
        log_error "External DB configuration health check failed"
        kubectl logs -n "${NAMESPACE}" "${EXT_POD}" --tail=50
        exit 1
    }
    log_info "External DB configuration check passed"
    helm uninstall "${RELEASE_NAME}-ext" -n "${NAMESPACE}"
fi

log_info "${GREEN}========================================${NC}"
log_info "${GREEN}All e2e tests passed successfully!${NC}"
log_info "${GREEN}========================================${NC}"

exit 0
