# SNMP Test Device

This is a standalone SNMP test device that simulates a network router or switch. It can be used to test the SNMP to Prometheus Automation system.

## Features

- Simulates a Cisco-like network device
- Provides realistic network interface data
- Exposes standard SNMP MIBs
- Randomized counter values to simulate traffic
- Runs independently from the main system

## Getting Started

### Prerequisites

- Docker
- Docker Compose

### Starting the Test Device

Make the start script executable:

```bash
chmod +x start-test-device.sh
```

Start the test device:

```bash
./start-test-device.sh
```

This will start a Docker container with an SNMP daemon that simulates a network device.

### Testing Connectivity

You can test the connectivity to the device using the `snmpwalk` command:

```bash
snmpwalk -v2c -c public localhost:10161 system
```

This should return system information from the test device.

### Adding to the Automation System

Once the test device is running, you can add it to your SNMP to Prometheus Automation system using the provided command:

```bash
# Replace IP_ADDRESS with the actual IP of the container
./scripts/add-device.sh --ip IP_ADDRESS --community public --name 'Test Router'
```

The script will display the actual command with the correct IP address.

## Customization

You can customize the SNMP data by editing the `snmpd.conf` file. After making changes, restart the container:

```bash
docker-compose down
docker-compose up -d
```

## Troubleshooting

If you can't connect to the device, check:

1. Is the container running?
   ```bash
   docker ps | grep snmp-test-device
   ```

2. What is the container's IP address?
   ```bash
   docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' snmp-test-device
   ```

3. Are the ports mapped correctly?
   ```bash
   docker-compose ps
   ```

## Stopping the Device

To stop the test device:

```bash
docker-compose down
```
