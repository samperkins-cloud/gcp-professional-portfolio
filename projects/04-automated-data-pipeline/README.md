# Automated GCP Data Pipeline with Terraform

This project demonstrates a fully automated, serverless, event-driven data pipeline on Google Cloud Platform (GCP), built and managed entirely with Infrastructure as Code (IaC) using Terraform.

## Project Summary

The pipeline automatically ingests CSV files uploaded to a Cloud Storage bucket, processes them with a Python-based Cloud Function, and loads the structured data into a BigQuery table for analysis. This architecture is highly scalable, cost-effective, and requires zero server management.

## Architecture Diagram

![Architecture Diagram](images/02-architecture-diagram.png)
*(You would place your architecture diagram screenshot in an 'images' folder in your repo)*

## Key Features

*   **Serverless:** No servers to manage. The entire pipeline scales automatically based on load.
*   **Event-Driven:** The pipeline is triggered automatically by file uploads to Cloud Storage, orchestrated by Eventarc.
*   **Infrastructure as Code:** All cloud resources are defined, versioned, and managed through Terraform, ensuring reproducibility and consistency.
*   **Least Privilege IAM:** Utilizes dedicated service accounts with fine-grained permissions to ensure a secure and robust architecture.

## Technologies Used

*   **Cloud:** Google Cloud Platform (GCP)
*   **IaC:** Terraform
*   **Services:** Cloud Storage, Cloud Functions (2nd Gen), BigQuery, Eventarc, Cloud Run, IAM, Cloud Build
*   **Language:** Python
*   **Version Control:** Git & GitHub

## Deployment Steps

1.  **Prerequisites:** Ensure you have Terraform and the `gcloud` CLI installed and authenticated.
2.  **Initialize:** Run `terraform init` to download the necessary providers.
3.  **Deploy Infrastructure:** Run `terraform apply` to create all GCP resources.
4.  **Upload Function Code:** Upload the packaged `src.zip` file to the newly created GCS bucket.
5.  **Re-apply:** Run `terraform apply` again to deploy the Cloud Function with the uploaded source code.
6.  **Test:** Upload a `users.csv` file to the same GCS bucket to trigger the pipeline.

## Challenges & Lessons Learned

This project was an invaluable real-world learning experience in debugging complex cloud deployments. Key challenges included:

*   **IAM Permissions:** The initial `403 Forbidden` errors were not a single issue, but a chain of missing permissions. I learned to systematically diagnose and apply roles for different service interactions, such as `run.invoker` for the Eventarc trigger and `bigquery.jobUser` for the function's service account, embracing the **principle of least privilege**.

*   **Terraform Dependency Management:** Encountered and resolved an `Error: Cycle` by refactoring resource dependencies. This taught me the importance of how Terraform builds its dependency graph and how to manage both implicit and explicit dependencies (`depends_on`).

*   **Platform-Level Anomalies:** After proving the configuration was correct, I still faced persistent authentication errors. This led me to debug a "stuck" resource state, which was ultimately resolved by a full `terraform destroy` and `apply`, forcing a clean rebuild of the entire environment. This was a critical lesson in the "eventual consistency" nature of cloud platforms.

## Future Improvements

*   Integrate a CI/CD pipeline (e.g., using GitHub Actions) to automate testing and deployment.
*   Add more robust error handling and a dead-letter queue for failed processing events.
*   Implement monitoring and alerting on function performance and errors using Cloud Monitoring.