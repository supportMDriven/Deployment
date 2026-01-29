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
We use Docker Compose for local development. Choose the local folder.

1. Prerequisites
    - Docker Desktop & Git installed.
    - (Windows Users) Ensure WSL2 is enabled if running Linux containers.

2. Setup  
Maker sure docker engine is running by executing ```docker info``` and then Navigate to the local folder (e.g., deployments/local).  

3. Run  
Choose your OS architecture  
```AMD```: Run ``` docker compose -f compose.amd64.yaml up -d ```  
```ARM```: Run ``` docker compose -f compose.arm64.yaml up -d ```  
```MUSL```: Run ``` docker compose -f compose.musl.yaml up -d ```


### Production Deployment
Production configurations are grouped by Provider/Method in deployments/production.

- ```nginx/```: Use this for standard VMs (DigitalOcean, Linode, EC2). - Includes an Nginx reverse proxy configuration.

