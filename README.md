# GCP Cloud Engineer Portfolio

This repository is a curated collection of enterprise-grade cloud infrastructure projects, showcasing a journey from foundational cloud concepts to advanced, platform-oriented DevOps. Every project is provisioned and managed entirely through Infrastructure as Code (IaC) using Terraform, with the later projects leveraging a full GitOps workflow using **GitHub Actions**.

---

## 🚀 Project Showcase

This portfolio follows a "crawl, walk, run" methodology, with each project building upon the skills of the last.

| Project | Description | Key Technologies |
| :--- | :--- | :--- |
| **01: `hello-cloud-vm`** | Deploys a basic web server on a single Compute Engine VM. | `Compute Engine`, `Startup Scripts` |
| **02: `secure-custom-vpc`** | Establishes a secure, reusable VPC network as a foundational Terraform module. | `VPC`, `Firewall Rules`, `Terraform Modules` |
| **03: `web-server-in-vpc`** | Deploys a web server securely inside the custom VPC module. | `Compute Engine`, `VPC`, `Module Reusability` |
| **04: `automated-data-pipeline`** | Creates an automated, event-driven data processing pipeline. | `Cloud Functions`, `Cloud Storage`, `Pub/Sub` |
| **05: `scalable-web-app`** | Builds a highly available, auto-scaling, and load-balanced web application. | `Instance Groups`, `Load Balancing`, `Health Checks` |
| **06: `automated-container-deployment`** | Implements a GCP-native CI/CD pipeline to deploy a containerized web app. | `Cloud Run`, `Cloud Build`, `Artifact Registry`, `Docker` |
| **07: `mlops-pipeline`** | **(Conceptual)** Orchestrates a Vertex AI pipeline to automate ML model training and deployment. | `Vertex AI`, `Cloud Build`, `Cloud Storage` |
| **08: `automated-functions-deployment`** | **(Platform)** Implements a reusable **GitHub Actions** CI/CD platform for serverless functions, featuring keyless auth, PR previews, and multi-workspace state. | `GitHub Actions`, `Workload Identity Federation`, `Terraform Cloud` |

---

## 🛠️ Core Methodologies & Skills Demonstrated

This portfolio demonstrates hands-on experience with modern cloud engineering practices:

*   **Infrastructure as Code (IaC):** Proficient use of **`Terraform`** to define, provision, and manage all cloud resources in a repeatable and version-controlled manner. This includes authoring **reusable modules**, managing **remote state** with Terraform Cloud, and implementing a **multi-workspace platform architecture** to separate platform and application concerns.

*   **CI/CD & GitOps:** Deep implementation of a fully automated GitOps workflow using **`GitHub Actions`**. This includes authoring **reusable workflows** to create a centralized deployment platform. The platform automatically builds **`Docker`** containers, pushes them to **`Artifact Registry`**, and deploys to **`Cloud Run`**, providing a complete "source-to-prod" lifecycle.

*   **Advanced Automation Features:** The CI/CD platform includes enterprise-grade features such as:
    *   **Ephemeral Preview Environments:** Automatically deploys a unique, isolated preview environment for every Pull Request and posts the live URL back as a PR comment.
    *   **Monorepo Path Filtering:** Intelligently triggers workflows only when relevant code paths are changed, optimizing execution in a multi-project repository.

*   **Secure DevOps (DevSecOps):** Deep, practical experience implementing the **Principle of Least Privilege**. This includes:
    *   **Keyless Authentication:** Configuring **`Workload Identity Federation`** to allow GitHub Actions to securely authenticate to GCP without using long-lived service account keys.
    *   **Secret Management:** Building a secure, end-to-end workflow to manage application secrets with **`Secret Manager`** and inject them into running services at deploy time.
    *   **IAM & Networking:** Designing custom **`VPCs`**, granular **`Firewall Rules`**, and debugging complex, multi-layered IAM permission failures.

*   **Systematic Debugging & Problem Solving:** Demonstrated ability to diagnose and resolve complex issues across the entire stack, from application code (`IndentationError`) and container runtimes (`CMD` contract) to Terraform state (`state drift`) and advanced IAM "handoff" failures between services.

---

## 📂 Repository Structure

This repository is organized to reflect a professional, multi-project environment.

*   `**/modules/**`: Contains reusable, generic Terraform modules designed to be the building blocks of any project.
*   `**/projects/**`: Contains the root configurations for each standalone project. Each project's `main.tf` file composes one or more modules to build a complete architecture.
*   `**/.github/workflows/**`: Contains the centralized, reusable GitHub Actions workflows that form the core of the CI/CD platform.

---

## 👨‍💻 My Learning Journey

This portfolio documents my professional development from the foundational knowledge of a Google Associate Cloud Engineer towards the advanced, practical skills required for a senior Cloud or DevOps Engineering role. It is built on the principle that robust, scalable, and automated infrastructure is the bedrock of any successful system.