# Development VM deployment

This guide describes the development-only deployment path for the Google Compute
Engine VM. It is not a production deployment design.

## Deployment model

GitHub Actions already runs the repository CI workflow in `.github/workflows/ci.yml`.
The optional `Deploy development VM` workflow runs after a push to `main` (or by
manual dispatch), authenticates to Google Cloud with GitHub OIDC, builds immutable
runtime images, pushes them to Artifact Registry, and connects to the VM through
IAP to pull and run those images with Docker Compose.

The workflow deliberately does not create, upload, print, or store `.env` files.
Runtime configuration remains on the VM and is ignored by Git. Do not add database
passwords, Cloud SQL credential files, SSH keys, or service-account JSON to GitHub.

The workflow does not build application images on the VM. This keeps deployment
repeatable and makes the deployed commit explicit through the image tag.

## One-time Google Cloud and GitHub configuration

A maintainer must configure these external resources before enabling the workflow:

1. A GitHub OIDC Workload Identity Pool and provider restricted to this repository
   and the `main` branch.
2. A dedicated deployment service account with only the permissions required to
   use IAP SSH, view the target VM, and use OS Login.
3. The service account's Workload Identity User binding for the GitHub principal.
4. An Artifact Registry Docker repository in the selected location. Grant the VM
   service account `Artifact Registry Reader` on that repository and grant the
   GitHub deployment service account permission to upload images.
5. GitHub **Environment variables** in the `development` environment:

   | Variable                         | Example value                                        |
   | -------------------------------- | ---------------------------------------------------- |
   | `GCP_PROJECT_ID`                 | `project-99b00a9a-cc2e-4e84-bd7`                     |
   | `GCP_WORKLOAD_IDENTITY_PROVIDER` | Full provider resource name using the project number |
   | `GCP_DEPLOYER_SERVICE_ACCOUNT`   | Dedicated deployment service-account email           |
   | `AR_LOCATION`                    | `asia-southeast1`                                    |
   | `AR_REPOSITORY`                  | `trusted-ai-platform`                                |
   | `GCE_VM_NAME`                    | `trusted-ai-platform-dev-20260802`                   |
   | `GCE_ZONE`                       | `asia-southeast1-b`                                  |
   | `DEPLOY_PATH`                    | `/home/USER/trusted-ai-platform`                     |

Do not put any of these values in a repository `.env` file. The provider resource
name uses the numeric Google Cloud project number, not the project ID.

## One-time VM setup

Run these commands through the VM's SSH terminal. Replace the repository URL and
the target directory with the real values; do not paste secrets into the shell
history.

```bash
sudo apt-get update
sudo apt-get install -y ca-certificates curl git

# Install Docker using the official Docker repository for Ubuntu.
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo usermod -aG docker "$USER"

# Install the Google Cloud CLI so the VM service account can authenticate Docker
# to the private Artifact Registry repository without a JSON key.
sudo apt-get install -y apt-transport-https ca-certificates gnupg
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | \
  sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | \
  sudo tee /etc/apt/sources.list.d/google-cloud-sdk.list > /dev/null
sudo apt-get update
sudo apt-get install -y google-cloud-cli

git clone YOUR_REPOSITORY_URL "$HOME/trusted-ai-platform"
cd "$HOME/trusted-ai-platform"
```

Sign out and reconnect after adding the user to the `docker` group. Then create
the required local runtime file from the repository template. For Cloud SQL,
follow the existing [Cloud SQL development profile](../DEVELOPMENT.md#optional-cloud-sql-development-connection).

```bash
cd "$HOME/trusted-ai-platform"
cp .env.example .env
# Edit .env locally on the VM; never commit it.
```

If `.env.cloud-sql` is present and valid, the deployment workflow uses the
Cloud SQL profile. Otherwise it starts the local PostgreSQL compatibility
container. The existing Cloud SQL instance for this project is PostgreSQL 18;
use a least-privilege application database user rather than the administrator.

## Manual first deployment

Before enabling automatic deployment, run one manual deployment and verify it:

```bash
cd "$HOME/trusted-ai-platform"
./scripts/docker/build.sh
./scripts/docker/start.sh
docker compose ps
```

For the Cloud SQL profile, use:

```bash
./scripts/docker/cloud-sql.sh config
./scripts/docker/cloud-sql.sh start
./scripts/docker/cloud-sql.sh check
```

The current frontend and backend ports bind to `127.0.0.1`. Keep them private
and use SSH port forwarding for development access. Do not open database or AI
service ports to the internet.

## CI/CD safety boundaries

- `.env`, `.env.cloud-sql`, and credential files remain on the VM.
- GitHub receives only short-lived OIDC credentials for the deployment job.
- Runtime images are tagged with the full Git commit SHA and pulled from Artifact
  Registry; the VM does not build unreviewed source code during deployment.
- Deployment is serialized so two pushes cannot update the VM concurrently.
- The workflow uses IAP SSH instead of storing a private SSH key in GitHub.
- The deployment path uses `git reset --hard origin/main`; keep the deployment
  directory separate from any manual source edits.
- The AI service runs in the repository's development mode. The current VM is
  not a suitable host for large model inference.
