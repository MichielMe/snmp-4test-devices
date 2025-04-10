#!/bin/bash
# Start the test SNMP devices

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
cd "$SCRIPT_DIR"

# Define the containers and their host ports
DEVICES=(
  "snmp-device-01:10161:router-01"
  "snmp-device-02:10162:router-02"
  "snmp-device-03:10163:switch-01"
  "snmp-device-04:10164:switch-02"
)

# Check if the containers are already running
RUNNING_COUNT=0
for DEVICE_INFO in "${DEVICES[@]}"; do
  IFS=':' read -r CONTAINER_NAME PORT DEVICE_NAME <<< "$DEVICE_INFO"
  if docker ps | grep -q $CONTAINER_NAME; then
    RUNNING_COUNT=$((RUNNING_COUNT+1))
    CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
    echo "$DEVICE_NAME is already running!"
    echo "Container: $CONTAINER_NAME"
    echo "IP Address: $CONTAINER_IP"
    echo "SNMP Port: 161 (mapped to host port $PORT)"
    echo
    echo "To test connectivity:"
    echo "  snmpwalk -v2c -c public localhost:$PORT system"
    echo
    echo "To add to your SNMP-Prometheus Automation system:"
    echo "  ./scripts/add-device.sh --ip $CONTAINER_IP --community public --name '$DEVICE_NAME'"
    echo
  fi
done

# If all containers are running, exit
if [ $RUNNING_COUNT -eq ${#DEVICES[@]} ]; then
  echo "All SNMP test devices are running!"
  exit 0
fi

# Create the containers
echo "Starting SNMP test devices..."
docker-compose up -d

# Wait for the containers to start
sleep 2

echo "SNMP test devices started successfully!"
echo

# Display information for each container
for DEVICE_INFO in "${DEVICES[@]}"; do
  IFS=':' read -r CONTAINER_NAME PORT DEVICE_NAME <<< "$DEVICE_INFO"
  CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $CONTAINER_NAME)
  echo "$DEVICE_NAME information:"
  echo "Container: $CONTAINER_NAME"
  echo "IP Address: $CONTAINER_IP"
  echo "SNMP Port: 161 (mapped to host port $PORT)"
  echo
  echo "To test connectivity:"
  echo "  snmpwalk -v2c -c public localhost:$PORT system"
  echo
  echo "To add to your SNMP-Prometheus Automation system:"
  echo "  ./scripts/add-device.sh --ip $CONTAINER_IP --community public --name '$DEVICE_NAME'"
  echo "--------------------------------------------"
  echo
done
