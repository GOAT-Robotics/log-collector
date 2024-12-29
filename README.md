
# Log Collection Scripts

This repository contains two scripts: `collect-gtstudio-logs.sh` and `collect-service-logs.sh`, which help collect logs from Docker containers and Linux services respectively, and compress them into `.tar.gz` archives.

---

## **1. collect-gtstudio-logs.sh**

### **Description**
This script collects logs from all running Docker containers on the server and compresses them into a single `.tar.gz` archive.

### **Usage Instructions**
1. Ensure Docker is installed and running on your system.
2. Save the script as `collect-gtstudio-logs.sh`.
3. Make the script executable:
   ```bash
   chmod +x collect-gtstudio-logs.sh
   ```
4. Run the script:
   ```bash
   ./collect-gtstudio-logs.sh
   ```

### **What It Does**
- Fetches logs from all running Docker containers using the `docker logs` command.
- Saves each container's logs in the `docker_logs` directory with filenames in the format `<container_name>_<container_id>.log`.
- Compresses the `docker_logs` directory into a `.tar.gz` archive with a timestamp in the filename (e.g., `docker_logs_YYYYMMDD_HHMMSS.tar.gz`).
- Deletes the temporary log files after compression.

### **Output**
- A `.tar.gz` file containing the logs of all running Docker containers.

---

## **2. collect-service-logs.sh**

### **Description**
This script collects logs from specific Linux services (`apex_startup.service` and `rcc-agent.service`) using `journalctl` and compresses them into a single `.tar.gz` archive.

### **Usage Instructions**
1. Save the script as `collect-service-logs.sh`.
2. Make the script executable:
   ```bash
   chmod +x collect-service-logs.sh
   ```
3. Run the script:
   ```bash
   ./collect-service-logs.sh
   ```

### **What It Does**
- Uses `journalctl` to fetch logs for the specified services (`apex_startup.service` and `rcc-agent.service`).
- Saves each service's logs in the `service_logs` directory with filenames in the format `<service_name>.log`.
- Compresses the `service_logs` directory into a `.tar.gz` archive with a timestamp in the filename (e.g., `service_logs_YYYYMMDD_HHMMSS.tar.gz`).
- Deletes the temporary log files after compression.

### **Output**
- A `.tar.gz` file containing logs for the specified services.

---

## **Customization**

### For Docker Logs
- This script automatically collects logs for all **running Docker containers**. No manual customization is needed.

### For Service Logs
- To add or remove services in `collect-service-logs.sh`, edit the `SERVICES` array in the script:
  ```bash
  SERVICES=("service1.service" "service2.service")
  ```

---

## **Notes**
- Both scripts require the necessary permissions to access Docker logs and system journal logs. Run the scripts with appropriate privileges (e.g., as a user with `docker` access or using `sudo`).
- Ensure sufficient disk space is available for temporary log storage and compression.

---

Enjoy seamless log collection and management!
