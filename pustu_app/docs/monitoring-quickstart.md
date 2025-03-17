# PUSTU Queue App Monitoring Quick Start Guide

This guide provides quick steps to get started with the monitoring system for PUSTU Queue App.

## Prerequisites

- Docker and Docker Compose installed
- Access to all required ports (9090, 3000, 9093, 3100, 16686, 9200, 5601)
- Sufficient disk space for logs and metrics

## Quick Start

1. **Start the Monitoring Stack**
   ```bash
   ./scripts/monitor.sh start
   ```

2. **Verify the Setup**
   ```bash
   ./scripts/test-monitoring.sh
   ```

3. **Access the Dashboards**
   - Grafana: http://localhost:3000 (default: admin/admin)
   - Prometheus: http://localhost:9090
   - AlertManager: http://localhost:9093
   - Jaeger: http://localhost:16686
   - Kibana: http://localhost:5601

## Common Operations

### Check System Health
```bash
./scripts/monitor.sh verify
```

### View Service Logs
```bash
# All services
./scripts/monitor.sh logs

# Specific service
./scripts/monitor.sh logs prometheus
```

### Monitor Storage
```bash
./scripts/monitor.sh storage
```

### Backup Configurations
```bash
./scripts/monitor.sh backup
```

## Key Metrics

1. **System Health**
   - CPU Usage
   - Memory Usage
   - Disk Space
   - Network I/O

2. **Application Metrics**
   - Request Rate
   - Response Time
   - Error Rate
   - Active Users

3. **Queue Metrics**
   - Queue Length
   - Wait Time
   - Processing Rate
   - Service Level

4. **Database Metrics**
   - Query Performance
   - Connection Pool
   - Transaction Rate
   - Cache Hit Rate

## Alert Channels

- Critical Alerts: #alerts-critical
- Warnings: #alerts-warnings
- Info: #alerts-info
- General: #monitoring

## Default Alert Rules

1. **High CPU Usage**
   - Threshold: > 80%
   - Duration: 5m
   - Severity: warning

2. **High Memory Usage**
   - Threshold: > 85%
   - Duration: 5m
   - Severity: warning

3. **High Error Rate**
   - Threshold: > 5%
   - Duration: 2m
   - Severity: critical

4. **Long Queue Wait Time**
   - Threshold: > 15m
   - Duration: 5m
   - Severity: warning

## Log Categories

1. **Application Logs**
   - Location: /var/log/pustu/api/*.log
   - Format: JSON
   - Retention: 7 days

2. **Queue Logs**
   - Location: /var/log/pustu/queue/*.log
   - Format: JSON
   - Retention: 7 days

3. **Nginx Logs**
   - Location: /var/log/nginx/*.log
   - Format: Combined
   - Retention: 30 days

## Troubleshooting

### Common Issues

1. **Service Not Starting**
   ```bash
   # Check service status
   ./scripts/monitor.sh verify
   
   # View service logs
   ./scripts/monitor.sh logs <service>
   ```

2. **Missing Metrics**
   ```bash
   # Test data flow
   ./scripts/test-monitoring.sh
   ```

3. **Alert Not Firing**
   ```bash
   # Check AlertManager status
   curl -s http://localhost:9093/-/healthy
   ```

### Support

For additional help:
1. Check detailed documentation in `docs/monitoring.md`
2. Review service logs
3. Contact the monitoring team

## Security Notes

1. **Default Credentials**
   - Change all default passwords
   - Use secure communication
   - Enable authentication

2. **Access Control**
   - Restrict dashboard access
   - Use role-based access
   - Monitor audit logs

## Next Steps

1. **Customize Dashboards**
   - Add business metrics
   - Create team views
   - Set up SLO tracking

2. **Fine-tune Alerts**
   - Adjust thresholds
   - Update notification channels
   - Create escalation policies

3. **Optimize Storage**
   - Review retention policies
   - Configure data aggregation
   - Set up data cleanup

## Regular Maintenance

1. **Daily**
   - Check system health
   - Review active alerts
   - Monitor storage usage

2. **Weekly**
   - Review alert patterns
   - Check backup status
   - Update dashboards

3. **Monthly**
   - Audit access logs
   - Review retention policies
   - Update documentation

Remember to check `docs/monitoring.md` for detailed information about the monitoring setup.
