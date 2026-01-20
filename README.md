# GCP Cloud Engineer Portfolio

This repository is a curated collection of enterprise-grade cloud infrastructure projects, showcasing a journey from foundational cloud concepts to advanced DevOps and serverless deployments on Google Cloud Platform (GCP). Every project is provisioned and managed entirely through Infrastructure as Code (IaC) using Terraform.

## Project Showcase

This portfolio follows a "crawl, walk, run" methodology, with each project building upon the skills of the last.

| Project | Description | Key GCP Services & Concepts |
| :--- | :--- | :--- |
| **01 - Hello Cloud VM** | Deploys a basic web server on a single Compute Engine virtual machine. | `Compute Engine`, `Startup Scripts` |
| **02 - Secure Custom VPC** | Establishes a secure, reusable Virtual Private Cloud (VPC) network as a foundational Terraform module. | `VPC`, `Firewall Rules`, `Terraform Modules` |
| **03 - Web Server in VPC** | Deploys a web server securely inside the custom VPC module, demonstrating module composition. | `Compute Engine`, `VPC`, `Module Reusability` |
| **04 - Automated Data Pipeline** | Creates an automated, event-driven data processing pipeline using serverless components. | `Cloud Functions`, `Cloud Storage`, `Pub/Sub` |
| **05 - Scalable Web App** | Builds a highly available, auto-scaling, and load-balanced web application using an Instance Group. | `Instance Groups`, `Load Balancing`, `Health Checks` |
| **06 - Automated Container Deployment** | Implements a full CI/CD pipeline to automatically build and deploy a containerized application to a serverless environment on every `git push`. | `Cloud Run`, `Cloud Build`, `Artifact Registry`, `Docker`, `GitOps` |

## Core Methodologies & Skills Demonstrated

This portfolio demonstrates hands-on experience with modern cloud engineering practices:

*   **Infrastructure as Code (IaC):** Proficient use of **Terraform** to define, provision, and manage all cloud resources in a repeatable and version-controlled manner.
*   **Modularity & Reusability:** Expertise in creating reusable Terraform modules (`VPC`, `Cloud Run`, `CI/CD`) to build scalable and maintainable architectures, mirroring enterprise best practices.
*   **CI/CD & DevOps:** Implementation of a fully automated GitOps workflow. Code pushed to GitHub automatically triggers builds, containerization, and deployments with **Cloud Build** and **Docker**.
*   **Serverless & Containers:** Experience with containerizing applications using **Docker** and deploying them on a fully managed, serverless platform (**Cloud Run**) for zero-ops scaling.
*   **Secure Networking:** Foundational knowledge of cloud networking, including the design and implementation of custom **VPCs** and granular **Firewall Rules** to secure infrastructure.

## Repository Structure

This repository is organized to reflect a professional, multi-project environment.

*   `**/modules/**`: Contains reusable, generic Terraform modules designed to be the building blocks of any project. These modules are self-contained and configurable through input variables.
*   `**/projects/**`: Contains the root configurations for each standalone project listed above. Each project's `main.tf` file composes one or more modules to build a complete architecture.

## My Learning Journey

This portfolio documents my professional development from the foundational knowledge of a Google Associate Cloud Engineer towards the advanced, practical skills required for a Machine Learning Professional. It is built on the principle that robust, scalable, and automated infrastructure is the bedrock of any successful MLOps system.