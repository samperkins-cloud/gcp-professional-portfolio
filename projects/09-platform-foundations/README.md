# Project 09: The Platform Foundations Workspace

## Objective

This project represents the **"Platform Engineering"** layer in a modern, multi-workspace Infrastructure as Code architecture. Its sole responsibility is to provision and manage the foundational, shared GCP resources that the centralized **GitHub Actions CI/CD platform** consumes.

This workspace acts as the "provider" in a platform model. It uses Terraform to create the core components required for the CI/CD process to run securely and effectively. It is designed to be run once by a central Cloud Engineering team to bootstrap the environment for application teams.

This architecture enforces a strict **separation of duties**: the platform workspace owns the lifecycle of core infrastructure, and the GitHub Actions workflow consumes it to deploy applications.

---

## Architecture & Resources Created

This Terraform workspace is designed to be run by a central Cloud Engineering team. It creates the following critical resources:

*   **Workload Identity Federation (WIF):** While the initial Pool and Provider are created manually for bootstrap purposes, this workspace could be extended to manage WIF configurations for other repositories or organizations.

*   **Platform Service Account:** A dedicated `google_service_account` (`github-actions-runner`) for the GitHub Actions CI/CD platform to impersonate. This account is granted all necessary permissions to build, push, and deploy applications, including:
    *   `roles/run.admin`
    *   `roles/artifactregistry.writer`
    *   `roles/iam.serviceAccountUser`

*   **Application Artifact Registry:** A dedicated `google_artifact_registry_repository` for storing the container images built by the CI/CD pipeline. This is created with **tag immutability enabled** to enforce security best practices.

*   **Application Secrets:** Manages the lifecycle of application secrets using `google_secret_manager_secret`. This allows the platform team to control the secret values while the application pipeline simply references them by name.

The details of these resources (like the Service Account email) are then used to configure the GitHub repository's Actions secrets, completing the secure connection.

---

## How to Run

This workspace must be deployed **before** the GitHub Actions CI/CD pipeline can run successfully.

1.  **Manual Prerequisite:** Manually create the Workload Identity Federation Pool and Provider in the GCP console and grant the `Workload Identity User` role to the Service Account defined in this project. This is a one-time bootstrap step.
2.  **Navigate to this project directory:** `cd projects/09-platform-foundations`
3.  **Create a `terraform.tfvars` file** with the `project_id`, `app_name`, and the secret `app_api_key`.
4.  **Initialize Terraform:** `terraform init`
5.  **Apply the configuration:** `terraform apply`

Once applied, this workspace creates the necessary GCP resources. The final step is to configure the `GCP_WIF_PROVIDER` and `GCP_SA_EMAIL` secrets in the GitHub repository settings, enabling the CI/CD workflow to authenticate and run.