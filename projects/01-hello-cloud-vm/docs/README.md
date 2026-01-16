 # Project 01: Terraform "Hello, World" VM

    ## Objective

    The goal of this project was to learn and demonstrate the fundamental end-to-end workflow of Infrastructure as Code (IaC) using Terraform to provision a resource in Google Cloud Platform (GCP).

    ---

    ## Proof of Success

    The following screenshot shows the `hello-world-vm` successfully created and running in the GCP Compute Engine console after running `terraform apply`.

    ![Successful VM Creation](https://raw.githubusercontent.com/samperkins-cloud/gcp-professional-portfolio/main/projects/01-hello-cloud-vm/docs/hello-world-vm-success.png)

    ---

    ## Technologies Used

    *   **Terraform:** For defining and managing the infrastructure as code.
    *   **Google Cloud Platform (GCP):**
        *   **Compute Engine:** To provision the virtual machine.

    ---

    ## Key Learnings

    This foundational project was crucial for understanding the core Terraform lifecycle:

    1.  **`terraform init`:** To initialize the project and download the necessary providers.
    2.  **`terraform plan`:** To create a safe execution plan and preview changes before applying them.
    3.  **`terraform apply`:** To provision the actual infrastructure in the cloud.
    4.  **`terraform destroy`:** To cleanly tear down all managed resources, ensuring a clean and cost-effective environment.

    I also gained valuable real-world experience in debugging environmental and authentication issues, including setting PowerShell execution policies and resolving cached Git credentials.

    ---

    ## How to Run

    1.  Navigate to this project directory: `cd projects/01-hello-cloud-vm`
    2.  Initialize Terraform: `terraform init`
    3.  Apply the configuration: `terraform apply`