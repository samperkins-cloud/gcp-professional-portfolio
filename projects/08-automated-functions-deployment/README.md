# Project 08: The Reusable GitHub Actions CI/CD Platform

## Objective

This project represents the final evolution of a CI/CD pipeline into a true, reusable **DevOps platform**, built entirely on **GitHub Actions**. The goal was to refactor the entire system to align with a modern, enterprise-grade "platform engineering" model, where a central, shared workflow provides a secure and automated "paved road" for application teams to deploy their services.

This showcases a key enterprise capability: creating a flexible, Git-native deployment platform that authenticates to GCP using secure, **keyless Workload Identity Federation**, and is supported by a multi-workspace Terraform configuration for managing foundational resources.

---

## Proof of Success

The final platform provides a complete, automated, and secure developer experience.

A developer opens a Pull Request, and the reusable GitHub Actions workflow automatically triggers. It builds the code, deploys a temporary preview environment, and **posts a comment back to the PR with a live URL**, closing the feedback loop.

![GitHub Actions PR Comment](docs/04-gha-pr-comment.png)

The workflow run itself shows a successful execution of the `deploy-preview` job, including keyless authentication, building the container, deploying to Cloud Run, and posting the comment back to the PR.

![Successful GitHub Actions Run](docs/05-gha-run-success.png)

The resulting preview service is live on Cloud Run, correctly configured with public access and running the code from the PR branch.

![Live Preview Environment URL](docs/06-gha-preview-url.png)

---

## Architecture & Design Choices

This project was architected as a professional, multi-component platform that separates platform logic from application code.

*   **GitHub Actions Reusable Workflow:** The core of the platform is a **reusable workflow** (`reusable-deploy-function.yml`) that lives in a central `.github/workflows` directory. This workflow contains all the logic for authentication, building, and deploying. Application teams consume this platform by creating a simple "caller" workflow that passes in project-specific parameters.

*   **Secure Keyless Authentication (WIF):** The platform authenticates to Google Cloud using **Workload Identity Federation (WIF)**. This is the industry best practice for security, as it allows GitHub Actions to impersonate a GCP Service Account using short-lived OIDC tokens instead of storing long-lived JSON service account keys as secrets.

*   **Explicit, Secure Build Process:** The GitHub Actions workflow uses an explicit, multi-step process (`docker build`, `docker push`, `gcloud run deploy`) rather than relying on implicit "magic" commands. This provides granular control and allows for the future injection of security scanning (e.g., Trivy, Artifact Analysis) and attestation (e.g., Binary Authorization) steps.

*   **Supporting IaC with Terraform:** While the CI/CD pipeline is now Git-native, **Terraform** is still used to manage the underlying, foundational infrastructure. This is structured into two distinct Terraform Cloud workspaces:
    1.  **`09-platform-foundations` (The Platform):** Owned by "Cloud Engineering," this workspace provisions the core resources the platform needs, such as the dedicated Service Account for GitHub Actions and the Artifact Registry repository.
    2.  **`08-automated-functions-deployment` (The Application):** This workspace is now much simpler. It's only responsible for provisioning application-specific resources that are not handled by the CI/CD pipeline, such as secrets in Secret Manager.

*   **Monorepo-Aware Triggers:** The "caller" workflow in the application's directory uses a `paths` filter, ensuring that the pipeline only runs when code changes are detected within its specific project directory (e.g., `projects/08-automated-functions-deployment/apps/**`).

---

## Key Learnings & Epic Debugging Journey

This project was a masterclass in debugging the complex interactions between Git, GitHub Actions, Terraform, and GCP. The journey went far beyond simple syntax errors into the deep, underlying mechanics of a modern cloud platform.

*   **Mastered GitHub Actions Workflows:** Successfully debugged a series of complex YAML syntax and logic errors, including:
    *   **Pathing Issues:** Corrected workflow file locations and `uses:` paths for local reusable workflows.
    *   **Permission Handshake:** Resolved "permission denied" errors by correctly granting `contents: read`, `pull-requests: write`, and `id-token: write` permissions to the "caller" workflow so it could delegate them to the reusable workflow.
    *   **Input Typos:** Fixed `Unexpected input(s)` errors by providing the correct input names (e.g., `service_account` vs. `service_account_email`) to the Google Auth action.

*   **Solved Advanced IAM for Keyless Auth:** Successfully configured Workload Identity Federation, including creating the identity pool, the provider with a restrictive condition, and the correct IAM bindings (`Workload Identity User`) to allow GitHub Actions to impersonate a GCP Service Account.

*   **Debugged CI/CD Tooling Conflicts:** Diagnosed a `PERMISSION_DENIED` error on `artifactregistry.repositories.get` when using the "magic" `gcloud run deploy --source` command. **The fix was to pivot to an explicit, multi-step pipeline** that manually runs `docker build` and `docker push` to a Terraform-managed repository, providing greater control and security.

*   **Mastered Container Runtime Contracts:** A persistent `Container Healthcheck failed` error led to a deep dive into the Cloud Run contract. **The final solution was to re-architect the `Dockerfile`'s `CMD` instruction to the canonical `CMD ["/bin/sh", "-c", "exec ... --port=$PORT"]` pattern**, creating a standard, portable container that correctly listens on the port provided by the Cloud Run environment.

This journey proves the ability to not only architect a complex, automated system but also to systematically debug and solve the complex, non-obvious issues that arise in a real-world, enterprise-grade cloud platform.

---

## How to Run

This project uses a Git-native workflow, supported by Terraform for foundational infrastructure.

1.  **Deploy the Foundation:**
    *   First, run `terraform apply` on the `09-platform-foundations` project to create the necessary GCP resources (Service Accounts, Artifact Registry, etc.).
2.  **Configure GitHub Secrets:**
    *   In the GitHub repository settings, create the `GCP_WIF_PROVIDER` and `GCP_SA_EMAIL` secrets with the values from the WIF setup.
3.  **Trigger the CI/CD Pipeline:**
    *   Create a new branch.
    *   Make a code change inside `projects/08-automated-functions-deployment/apps/`.
    *   Push the branch and open a Pull Request to trigger the preview deployment workflow.