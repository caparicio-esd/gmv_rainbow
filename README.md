# **Rainbow Deployment**

![Rainbow front](./static/rainbow.png)

This repository contains artifacts and scripts to deploy and test the Rainbow framework. It includes example certificates for authority, provider, and consumer, a central docker-compose file, and automation scripts in Bash or Powershell.

## **Repository Contents**

- `certificates/` — Certificates and keys (authority, provider, consumer).
  - `authority/` — Authority certificate (CA).
    - `cert.pem`, `private_key.pem`, `public_key.pem`
  - `provider/` — Provider certificate.
  - `consumer/` — Consumer certificate.
- `deployment/docker-compose.core.yaml` — Main Docker Compose file for the core deployment.
- `scripts/bash/` — Automation scripts (setup, onboarding, start, stop).
  - `auto-setup.sh` — Initial environment preparation.
  - `auto-onboarding.sh` — Scripts for automatic entity onboarding.
  - `auto-start.sh` — Service startup.
  - `auto-stop.sh` — Service shutdown.
- `test-cases/` — Test cases (definition and implementation).

## **Requirements**

- Docker and docker-compose (or Docker Desktop)
- Permissions to execute scripts (chmod +x)

## **External Dependencies**

This project depends on walt.id as the entire authentication layer is based on the SSI paradigm. For this, it is important to download and deploy this docker-compose: https://github.com/walt-id/waltid-identity

```bash
git clone https://github.com/walt-id/waltid-identity.git
cd waltid-identity
cd docker-compose
```

If you are Linux user. Please, before running containers make sure they are able to communicate with `host.docker.internal`. For doing so, just go in the current `./waltid-identity/docker-compose` folder into `.env` and change SERVICE_HOST environement variable. By doing that containers under a Linux host are able to resolver `host.docker.internal` IP alias.

```bash
#SERVICE_HOST=localhost
SERVICE_HOST=host.docker.internal
```

Once all is properly configured, deploy all wallet services with docker compose by running:

```bash
docker compose up -d
```

## Quick use tutorial

### **Quick Use For Bash Users**

Please. If you are Linux or MacOS user, you are going to use the bash scripts, make sure you have `jq` installed, since automation scripts relay on it.

```bash
sudo apt install jq -y # for Linux users
brew install jq        # for MacOS user
```

Grant execution permissions to the scripts (if they don't have them):

```bash
chmod +x scripts/bash/*.sh
```

Prepare the environment (executes initial configurations):

```bash
./scripts/bash/auto-setup.sh

```

Use the start script:

```bash
./scripts/bash/auto-start.sh

```

If you need it, stop the services.

```bash
./scripts/bash/auto-stop.sh

```

Run the automatic onboarding to have the actors authenticated and ready:

```bash
./scripts/bash/auto-onboarding.sh

```

### **Quick Use For Powershell Users**

If you are Windows user, you’ll likely use Powershell. Just go ahead and run:

```bash
./scripts/powershell/auto-setup.ps1
./scripts/powershell/auto-start.ps1
./scripts/powershell/auto-onboarding.ps1
```

## **Testing flow with notebook**

For testing purposes, there is a notebook available with the whole flow defined. This is a jupyter notebook. For using it, please make sure you have Python 3.10 or newer installed.

If you are a Linux user install also python3-venv

```bash
sudo apt install python3-venv -y
```

After, you can create a virtual environment and install dependencies. For Linux or MacOS users:

```bash
python3 -m venv .venv
source ./.venv/bin/activate
pip install -r requirements.txt

```

For Windows users:

```bash
python -m venv .venv
.venv\Scripts\activate.ps1
pip install -r requirements.txt
```

Once that is done, the jupyter notebook is ready. If you are working in a IDE such as VSCode or IntelliJ, please select the python kernel in the root and play with the notebook.

## **Development and Contribution**

Create a branch for your change:

```bash
git checkout -b feature/my-change

```

Make clear and descriptive commits.

Open a pull request against main.
