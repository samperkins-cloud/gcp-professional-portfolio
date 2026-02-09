# GCP Cloud Engineer Portfolio

This repository is a curated collection of enterprise-grade cloud infrastructure projects, showcasing a journey from foundational cloud concepts to advanced DevOps and serverless deployments on Google Cloud Platform (GCP). Every project is provisioned and managed entirely through Infrastructure as Code (IaC) using Terraform.

---

## Project Showcase

This portfolio follows a "crawl, walk, run" methodology, with each project building upon the skills of the last.

*   **Project 01:** `hello-cloud-vm` | Deploys a basic web server on a single Compute Engine virtual machine. | `Compute Engine`, `Startup Scripts`
*   **Project 02:** `secure-custom-vpc` | Establishes a secure, reusable Virtual Private Cloud (VPC) network as a foundational Terraform module. | `VPC`, `Firewall Rules`, `Terraform Modules`
*   **Project 03:** `web-server-in-vpc` | Deploys a web server securely inside the custom VPC module, demonstrating module composition. | `Compute Engine`, `VPC`, `Module Reusability`
*   **Project 04:** `automated-data-pipeline` | Creates an automated, event-driven data processing pipeline using serverless components. | `Cloud Functions`, `Cloud Storage`, `Pub/Sub`
*   **Project 05:** `scalable-web-app` | Builds a highly available, auto-scaling, and load-balanced web application using an Instance Group. | `Instance Groups`, `Load Balancing`, `Health Checks`
*   **Project 06:** `automated-container-deployment` | Implements a full CI/CD pipeline to automatically build and deploy a containerized application to a serverless environment on every `git push`. | `Cloud Run`, `Cloud Build`, `Artifact Registry`, `Docker`, `GitOps`
*   **Project 07:** `mlops-pipeline` | **(Conceptual)** Orchestrates a machine learning pipeline using Vertex AI to automate model training, evaluation, and deployment, triggered by changes in the source repository. | `Vertex AI Pipelines`, `Cloud Build`, `Cloud Storage`
*   **Project 08:** `automated-functions-deployment` | Adapts the CI/CD architecture to deploy containerized ETL functions, implementing secure secret management and advanced monorepo trigger filtering. | `Cloud Functions (2nd Gen)`, `Cloud Run`, `Secret Manager`, `Advanced IAM`

---

## Core Methodologies & Skills Demonstrated

This portfolio demonstrates hands-on experience with modern cloud engineering practices:

*   **Infrastructure as Code (IaC):** Proficient use of **`Terraform`** to define, provision, and manage all cloud resources in a repeatable and version-controlled manner. This includes authoring **reusable modules** and managing **remote state** with Terraform Cloud.

*   **CI/CD & Automation:** Deep implementation of a fully automated GitOps workflow. Code pushed to GitHub automatically triggers **`Cloud Build`** pipelines, containerizes applications with **`Docker`**, and deploys them on a fully managed, serverless platform (**`Cloud Run`**) for zero-ops scaling. This includes **ephemeral preview environments** for Pull Requests and **monorepo path filtering** to optimize trigger execution.

*   **Secure DevOps (DevSecOps):** Foundational knowledge of cloud networking, including the design and implementation of custom **`VPCs`** and granular **`Firewall Rules`**. Deep, practical experience implementing the **Principle of Least Privilege** for service accounts and securely managing application secrets with **`Secret Manager`** and IAM bindings.

*   **Systematic Debugging & Problem Solving:** Demonstrated ability to diagnose and resolve complex, multi-layered issues across the entire stack, including:
    *   **Advanced IAM:** Resolved silent permission failures (`403 Forbidden`) by diagnosing missing permissions (`run.services.setIamPolicy`) and the distinction between pipeline identity and runtime identity.
    *   **Terraform State:** Mastered "state drift" issues by using targeted `terraform destroy -target` commands to force-recreate stuck resources.
    *   **Application & Container Runtime:** Debugged container health check failures by correcting `Dockerfile` command execution and fixing application-level `ImportError` and `IndentationError` bugs by analyzing runtime logs.

---

## Repository Structure

This repository is organized to reflect a professional, multi-project environment.

*   `**/modules/**`: Contains reusable, generic Terraform modules designed to be the building blocks of any project. These modules are self-contained and configurable through input variables.
*   `**/projects/**`: Contains the root configurations for each standalone project listed above. Each project's `main.tf` file composes one or more modules to build a complete architecture.

---

## My Learning Journey

This portfolio documents my professional development from the foundational knowledge of a Google Associate Cloud Engineer towards the advanced, practical skills required for a senior Cloud or DevOps Engineering role. It is built on the principle that robust, scalable, and automated infrastructure is the bedrock of any successful system.