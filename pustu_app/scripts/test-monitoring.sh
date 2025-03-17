#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to test Prometheus metrics
test_prometheus() {
    echo -e "${YELLOW}Testing Prometheus metrics...${NC}"
    
    # Test basic metrics endpoint
    curl -s http://localhost:9090/-/healthy > /dev/null
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Prometheus health check passed${NC}"
    else
        echo -e "${RED}✗ Prometheus health check failed${NC}"
        return 1
    fi

    # Test specific metrics
    metrics=(
        "process_cpu_seconds_total"
        "go_goroutines"
        "http_requests_total"
    )

    for metric in "${metrics[@]}"; do
        curl -s "http://localhost:9090/api/v1/query?query=${metric}" | grep -q "success"
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Metric ${metric} available${NC}"
        else
            echo -e "${RED}✗ Metric ${metric} not found${NC}"
            return 1
        fi
    done
}

# Function to test Grafana
test_grafana() {
    echo -e "${YELLOW}Testing Grafana...${NC}"
    
    curl -s http://localhost:3000/api/health | grep -q "ok"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Grafana health check passed${NC}"
    else
        echo -e "${RED}✗ Grafana health check failed${NC}"
        return 1
    fi
}

# Function to test AlertManager
test_alertmanager() {
    echo -e "${YELLOW}Testing AlertManager...${NC}"
    
    curl -s http://localhost:9093/-/healthy | grep -q "ok"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ AlertManager health check passed${NC}"
    else
        echo -e "${RED}✗ AlertManager health check failed${NC}"
        return 1
    fi
}

# Function to test Loki
test_loki() {
    echo -e "${YELLOW}Testing Loki...${NC}"
    
    curl -s http://localhost:3100/ready | grep -q "ready"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Loki health check passed${NC}"
    else
        echo -e "${RED}✗ Loki health check failed${NC}"
        return 1
    fi
}

# Function to test Jaeger
test_jaeger() {
    echo -e "${YELLOW}Testing Jaeger...${NC}"
    
    curl -s http://localhost:16686/health | grep -q "ok"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Jaeger health check passed${NC}"
    else
        echo -e "${RED}✗ Jaeger health check failed${NC}"
        return 1
    fi
}

# Function to test Elasticsearch
test_elasticsearch() {
    echo -e "${YELLOW}Testing Elasticsearch...${NC}"
    
    curl -s http://localhost:9200/_cluster/health | grep -q "status"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Elasticsearch health check passed${NC}"
    else
        echo -e "${RED}✗ Elasticsearch health check failed${NC}"
        return 1
    fi
}

# Function to test Filebeat
test_filebeat() {
    echo -e "${YELLOW}Testing Filebeat...${NC}"
    
    curl -s http://localhost:5066/?pretty | grep -q "version"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Filebeat health check passed${NC}"
    else
        echo -e "${RED}✗ Filebeat health check failed${NC}"
        return 1
    fi
}

# Function to test data flow
test_data_flow() {
    echo -e "${YELLOW}Testing data flow...${NC}"
    
    # Generate test metric
    curl -X POST http://localhost:9090/api/v1/admin/tsdb/write \
        -d '{"metrics": [{"labels": [{"name": "__name__", "value": "test_metric"}], "samples": [{"value": 1, "timestamp": '$(date +%s)'}]}]}'
    
    # Generate test log
    echo "test log entry" >> /var/log/pustu/test.log
    
    # Generate test trace
    curl -X POST http://localhost:16686/api/traces \
        -H "Content-Type: application/json" \
        -d '{"operation_name": "test", "start_time": '$(date +%s)'000000, "duration": 1000000}'
    
    echo -e "${GREEN}✓ Test data generated${NC}"
    
    # Wait for data propagation
    sleep 5
    
    # Check if data is available in each system
    local errors=0
    
    # Check Prometheus
    curl -s "http://localhost:9090/api/v1/query?query=test_metric" | grep -q "1"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test metric found in Prometheus${NC}"
    else
        echo -e "${RED}✗ Test metric not found in Prometheus${NC}"
        ((errors++))
    fi
    
    # Check Loki
    curl -s -G --data-urlencode 'query={filename="/var/log/pustu/test.log"}' http://localhost:3100/loki/api/v1/query | grep -q "test log entry"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test log found in Loki${NC}"
    else
        echo -e "${RED}✗ Test log not found in Loki${NC}"
        ((errors++))
    fi
    
    # Check Jaeger
    curl -s http://localhost:16686/api/traces | grep -q "test"
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Test trace found in Jaeger${NC}"
    else
        echo -e "${RED}✗ Test trace not found in Jaeger${NC}"
        ((errors++))
    fi
    
    return $errors
}

# Main test execution
main() {
    local errors=0
    
    test_prometheus || ((errors++))
    test_grafana || ((errors++))
    test_alertmanager || ((errors++))
    test_loki || ((errors++))
    test_jaeger || ((errors++))
    test_elasticsearch || ((errors++))
    test_filebeat || ((errors++))
    test_data_flow || ((errors++))
    
    if [ $errors -eq 0 ]; then
        echo -e "\n${GREEN}All tests passed successfully!${NC}"
        exit 0
    else
        echo -e "\n${RED}${errors} test(s) failed!${NC}"
        exit 1
    fi
}

# Execute main function
main
