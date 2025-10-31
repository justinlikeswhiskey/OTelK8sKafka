# Kafka + OpenTelemetry on Kubernetes

Complete deployment package for Apache Kafka with OpenTelemetry monitoring using SASL authentication.

## 🎯 Components

- **Kafka Broker**: Single broker with SASL/PLAIN authentication
- **Zookeeper**: Required for Kafka coordination
- **OpenTelemetry Collector**: Monitoring with kafkametrics receiver
- **Sample Consumer**: Example consumer with consumer group
- **Sample Producer**: Interactive producer pod for testing

## 📋 Prerequisites

- Kubernetes cluster (v1.19+)
- kubectl configured
- Sufficient cluster resources (at least 4GB RAM, 2 CPUs)

## 🚀 Quick Start

### Option 1: Automated Deployment
```bash
chmod +x deploy.sh
./deploy.sh
```

### Option 2: Manual Deployment
```bash
# Apply all manifests in order
kubectl apply -f 00-namespace.yaml
kubectl apply -f 01-secrets.yaml
kubectl apply -f 02-zookeeper.yaml
kubectl apply -f 03-kafka-broker.yaml
kubectl apply -f 04-otel-collector.yaml
kubectl apply -f 05-kafka-consumer.yaml
kubectl apply -f 06-kafka-producer.yaml

# Wait for pods to be ready
kubectl wait --for=condition=ready pod -l app=kafka-broker -n kafka-monitoring --timeout=120s
```

## 🔍 Verify Deployment

```bash
# Check all pods are running
kubectl get pods -n kafka-monitoring

# View OpenTelemetry Collector logs (should show Kafka metrics)
kubectl logs -n kafka-monitoring -l app=otel-collector -f

# View consumer logs
kubectl logs -n kafka-monitoring -l app=kafka-consumer -f
```

## 📤 Send Test Messages

```bash
# Execute into producer pod and send messages
kubectl exec -n kafka-monitoring kafka-producer -it -- \
  kafka-console-producer \
  --bootstrap-server kafka-broker:9092 \
  --topic test-topic \
  --producer.config /tmp/producer.properties

# Type messages and press Enter to send
# Press Ctrl+C to exit
```

## 👀 Monitor Metrics

The OpenTelemetry Collector is configured to collect:
- Broker metrics (CPU, memory, connections)
- Topic metrics (partition count, replication)
- Consumer metrics (lag, offset)

By default, metrics are logged. To export to your observability platform:

1. Edit `04-otel-collector.yaml`
2. Uncomment and configure the appropriate exporter (OTLP, Prometheus, etc.)
3. Apply the changes: `kubectl apply -f 04-otel-collector.yaml`

## 🔐 Authentication

SASL/PLAIN authentication is configured with three users:

| Username | Password | Purpose |
|----------|----------|---------|
| admin | admin-secret | Broker admin |
| producer | producer-secret | Message production |
| consumer | consumer-secret | Message consumption |

**⚠️ IMPORTANT**: Change these passwords in `01-secrets.yaml` before production use!

## 🛠️ Customization

### Change Kafka Configuration
Edit the environment variables in `03-kafka-broker.yaml`

### Modify Collection Interval
In `04-otel-collector.yaml`, change `collection_interval` under the kafkametrics receiver

### Add More Consumers/Producers
Copy and modify `05-kafka-consumer.yaml` or `06-kafka-producer.yaml`

## 🧹 Cleanup

```bash
# Delete all resources
kubectl delete namespace kafka-monitoring

# Or delete individual components
kubectl delete -f .
```

## 📚 Additional Resources

- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [OpenTelemetry Kafka Receiver](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/kafkametricsreceiver)
- [Kafka SASL Configuration](https://kafka.apache.org/documentation/#security_sasl)

## 🐛 Troubleshooting

### Pods not starting
```bash
kubectl describe pod <pod-name> -n kafka-monitoring
kubectl logs <pod-name> -n kafka-monitoring
```

### Authentication errors
Verify JAAS configuration in the kafka-jaas secret matches your connection settings

### No metrics in OTEL Collector
- Ensure Kafka broker is fully started before OTEL Collector
- Check OTEL Collector logs for connection errors
- Verify SASL credentials are correct

## 📧 Support

For issues related to:
- Kafka: [Apache Kafka Users Mailing List](https://kafka.apache.org/contact)
- OpenTelemetry: [CNCF Slack #otel](https://cloud-native.slack.com/)
