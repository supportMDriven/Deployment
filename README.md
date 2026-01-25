# Deployment

**MDriven Docker Infrastructure**  
This repository manages the Docker build pipelines and deployment configurations for MDriven applications.

It is organized into two distinct phases:

 - /builds: Source code and Dockerfiles used to create images (CI).

 - /deployments: Configuration files (Compose) used to run those images (CD).

### Supported Architectures
We build specific images for different architectures to ensure maximum compatibility and performance:

| Architecture | Folder Path | Tag Suffix | Use Case |
|---|---|---|---|
| Linux AMD64 | linux-amd64/ | -linux-amd64 | "Standard Linux VPS, Azure Web Apps, AWS EC2" |
| Linux ARM64 | linux-arm64/ | -linux-arm64 | "Apple M1/M2 dev AWS Graviton, Raspberry Pi" |


### How to Deploy (Local Development)
We use Docker Compose for local development. Choose the folder matching your OS.

1. Prerequisites
    - Docker Desktop & Git installed.
    - (Windows Users) Ensure WSL2 is enabled if running Linux containers.

2. Setup  
Navigate to your OS folder (e.g., deployments/local/macos).  
**Run** ``` docker-compose up -d ```


### Production Deployment
Production configurations are grouped by Provider/Method in deployments/production.

- ```nginx/```: Use this for standard VMs (DigitalOcean, Linode, EC2). - Includes an Nginx reverse proxy configuration.

