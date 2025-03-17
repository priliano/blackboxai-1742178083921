#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a service is running
check_service() {
    local service=$1
    local port=$2
    echo -e "${YELLOW}Checking $service on port $port...${NC}"
    if nc -z localhost $port; then
        echo -e "${GREEN}✓ $service is running${NC}"
        return 0
    else
        echo -e "${RED}✗ $service is not running${NC}"
        return 1
    fi
}

# Function to check configuration files
check_config() {
    local file=$1
    local type=$2
    echo -e "${YELLOW}Checking $type configuration...${NC}"
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $type config found${NC}"
        return 0
    else
        echo -e "${RED}✗ $type config missing${NC}"
        return 1
    fi
}

# Function to verify monitoring stack
verify_stack() {
    local errors=0

    # Check services
    check_service "Prometheus" 9090 || ((errors++))
    check_service "Grafana" 3000 || ((errors++))
    check_service "AlertManager" 9093 || ((errors++))
    check_service "Loki" 3100 || ((errors++))
    check_service "Jaeger" 16686 || ((errors++))
    check_service "Elasticsearch" 9200 || ((errors++))
    check_service "Kibana" 5601 || ((errors++))

    # Check configurations
    check_config "prometheus.yml" "Prometheus" || ((errors++))
    check_config "alertmanager/alertmanager.yml" "AlertManager" || ((errors++))
    check_config "prometheus/rules/alert.rules" "Alert Rules" || ((errors++))
    check_config "loki/loki-config.yml" "Loki" || ((errors++))
    check_config "jaeger/jaeger-config.yml" "Jaeger" || ((errors++))
    check_config "filebeat/filebeat.yml" "Filebeat" || ((errors++))
    check_config "grafana/provisioning/datasources/datasources.yml" "Grafana Datasources" || ((errors++))
    check_config "grafana/provisioning/dashboards/dashboards.yml" "Grafana Dashboards" || ((errors++))

    return $errors
}

# Function to start monitoring stack
start_stack() {
    echo -e "${YELLOW}Starting monitoring stack...${NC}"
    docker-compose up -d prometheus grafana alertmanager loki jaeger elasticsearch kibana
    echo -e "${GREEN}Monitoring stack started${NC}"
}

# Function to stop monitoring stack
stop_stack() {
    echo -e "${YELLOW}Stopping monitoring stack...${NC}"
    docker-compose down
    echo -e "${GREEN}Monitoring stack stopped${NC}"
}

# Function to restart monitoring stack
restart_stack() {
    echo -e "${YELLOW}Restarting monitoring stack...${NC}"
    stop_stack
    start_stack
}

# Function to show logs
show_logs() {
    local service=$1
    if [ -z "$service" ]; then
        docker-compose logs --tail=100 -f
    else
        docker-compose logs --tail=100 -f $service
    fi
}

# Function to check disk usage
check_storage() {
    echo -e "${YELLOW}Checking storage usage...${NC}"
    df -h /var/lib/docker | awk 'NR==2 {print "Docker storage usage: " $5}'
    du -sh data/* 2>/dev/null | sort -hr
}

# Function to backup configurations
backup_configs() {
    local backup_dir="backups/$(date +%Y%m%d_%H%M%S)"
    echo -e "${YELLOW}Backing up configurations to $backup_dir...${NC}"
    mkdir -p $backup_dir
    cp prometheus.yml $backup_dir/
    cp -r alertmanager $backup_dir/
    cp -r prometheus $backup_dir/
    cp -r loki $backup_dir/
    cp -r jaeger $backup_dir/
    cp -r filebeat $backup_dir/
    cp -r grafana $backup_dir/
    echo -e "${GREEN}Backup completed${NC}"
}

# Function to show help
show_help() {
    echo "Usage: $0 [command]"
    echo
    echo "Commands:"
    echo "  verify    - Check if all services are running and configs exist"
    echo "  start     - Start the monitoring stack"
    echo "  stop      - Stop the monitoring stack"
    echo "  restart   - Restart the monitoring stack"
    echo "  logs      - Show logs (use 'logs <service>' for specific service)"
    echo "  storage   - Check storage usage"
    echo "  backup    - Backup configuration files"
    echo "  help      - Show this help message"
}

# Main script
case "$1" in
    "verify")
        verify_stack
        ;;
    "start")
        start_stack
        ;;
    "stop")
        stop_stack
        ;;
    "restart")
        restart_stack
        ;;
    "logs")
        show_logs $2
        ;;
    "storage")
        check_storage
        ;;
    "backup")
        backup_configs
        ;;
    "help"|"")
        show_help
        ;;
    *)
        echo "Unknown command: $1"
        show_help
        exit 1
        ;;
esac

exit 0
