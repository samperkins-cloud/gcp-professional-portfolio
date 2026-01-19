import functions_framework
from google.cloud import bigquery

# This is the main function that gets triggered
@functions_framework.cloud_event
def load_csv_to_bigquery(cloud_event):
    # ALL OF THE FOLLOWING LINES ARE INDENTED
    data = cloud_event.data
    bucket_name = data["bucket"]
    file_name = data["name"]

    # --- CONFIGURATION ---
    # TODO: Replace with your project ID and BigQuery details
    project_id = "my-portfolio-project-v2-484602"
    dataset_id = "portfolio_dataset"
    table_id = "user_data"
    # ---------------------

    client = bigquery.Client(project=project_id)
    table_ref = client.dataset(dataset_id).table(table_id)

    # Define the job configuration
    job_config = bigquery.LoadJobConfig(
        source_format=bigquery.SourceFormat.CSV,
        skip_leading_rows=1,  # Skip the header row
    )

    # Construct the GCS URI for the file
    uri = f"gs://{bucket_name}/{file_name}"

    # Start the load job
    load_job = client.load_table_from_uri(uri, table_ref, job_config=job_config)
    print(f"Starting job {load_job.job_id}")

    load_job.result()  # Wait for the job to complete
    print("Job finished.")

    destination_table = client.get_table(table_ref)
    print(f"Loaded {destination_table.num_rows} rows.")