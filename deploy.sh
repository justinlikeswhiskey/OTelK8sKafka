#!/bin/bash

set -e

echo "🚀 Deploying Kafka + OpenTelemetry on Kubernetes"
echo "================================================"
echo ""

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f 00-namespace.yaml

# Apply secrets
echo "🔐 Applying secrets..."
kubectl apply -f 01-secrets.yaml

# Deploy Zookeeper
echo "🐘 Deploying Zookeeper..."
kubectl apply -f 02-zookeeper.yaml
echo "⏳ Waiting for Zookeeper to be ready..."
kubectl wait --for=condition=ready pod -l app=zookeeper -n kafka-monitoring --timeout=120s

# Deploy Kafka Broker
echo "📨 Deploying Kafka Broker..."
kubectl apply -f 03-kafka-broker.yaml
echo "⏳ Waiting for Kafka Broker to be ready..."
kubectl wait --for=condition=ready pod -l app=kafka-broker -n kafka-monitoring --timeout=180s

# Deploy OpenTelemetry Collector
echo "📊 Deploying OpenTelemetry Collector..."
kubectl apply -f 04-otel-collector.yaml
echo "⏳ Waiting for OTEL Collector to be ready..."
kubectl wait --for=condition=ready pod -l app=otel-collector -n kafka-monitoring --timeout=120s

# Deploy Consumer
echo "📥 Deploying Kafka Consumer..."
kubectl apply -f 05-kafka-consumer.yaml

# Deploy Producer
echo "📤 Deploying Kafka Producer..."
kubectl apply -f 06-kafka-producer.yaml

echo ""
echo "✅ Deployment Complete!"
echo "======================="
echo ""
echo "📋 Next Steps:"
echo ""
echo "1. Check pod status:"
echo "   kubectl get pods -n kafka-monitoring"
echo ""
echo "2. View OTEL Collector metrics:"
echo "   kubectl logs -n kafka-monitoring -l app=otel-collector -f"
echo ""
echo "3. Send test messages:"
echo "   kubectl exec -n kafka-monitoring kafka-producer -it -- \\"
echo "     kafka-console-producer --bootstrap-server kafka-broker:9092 \\"
echo "     --topic test-topic --producer.config /tmp/producer.properties"
echo ""
echo "4. View consumer output:"
echo "   kubectl logs -n kafka-monitoring -l app=kafka-consumer -f"
echo ""
