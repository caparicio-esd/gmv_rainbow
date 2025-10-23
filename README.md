# GMV Rainbow

This repository contains artifacts and scripts to deploy and test the Rainbow framework. It includes example certificates for authority, provider, and consumer, a central docker-compose file, and automation scripts in Bash.

## Repository Contents

- `certificates/` — Certificates and keys (authority, provider, consumer).
    - `authority/` — Authority certificate (CA).
        - `cert.pem`, `private_key.pem`, `public_key.pem`
    - `provider/` — Provider certificate.
    - `consumer/` — Consumer certificate.
- `deployment/docker-compose.core.yaml` — Main Docker Compose file for the core deployment.
- `scripts/bash/` — Automation scripts (setup, onboarding, start, stop).
    - `auto-setup.sh` — Initial environment preparation.
    - `auto-onboarding.sh` — Scripts for automatic entity onboarding.
    - `auto-start.sh` — Service startup.
    - `auto-stop.sh` — Service shutdown.
- `test-cases/` — Test cases (definition and implementation).

## Requirements

- Docker and docker-compose (or Docker Desktop)
- Permissions to execute scripts (chmod +x)

## External Dependencies

This project depends on walt.id as the entire authentication layer is based on the SSI paradigm. For this, it is important to download and deploy this docker-compose: https://github.com/walt-id/waltid-identity 

```bash
git clone <https://github.com/walt-id/waltid-identity.git> && cd waltid-identity
```

And deploy all services with docker compose

```bash
cd docker-compose && docker compose up
```

## Quick Use

Grant execution permissions to the scripts (if they don't have them):

```bash
chmod +x scripts/bash/*.sh
```

Prepare the environment (executes initial configurations):

```bash
./scripts/bash/auto-setup.sh
```

Alternatively, use the start script:

```bash
./scripts/bash/auto-start.sh
```

Stop the services:

```bash
./scripts/bash/auto-stop.sh
```

Run the automatic onboarding to have the actors authenticated and ready:

```bash
./scripts/bash/auto-onboarding.sh
```

### Development and Contribution

Create a branch for your change:

```bash
git checkout -b feature/my-change
```

Make clear and descriptive commits.

Open a pull request against main.