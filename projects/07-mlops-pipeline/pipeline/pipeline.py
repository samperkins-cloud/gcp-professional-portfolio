from kfp import dsl
from kfp.v2 import compiler
from kfp.v2.dsl import component
from google_cloud_aiplatform.v1beta1.schema.trainingjob.definition import \
    custom_task

# You can also use the ':latest' tag, but digests are better for production.
# To find your digest, you can look at the final line of the Cloud Build output
# or browse Artifact Registry in the Google Cloud Console.
# For now, we will use the one from your output.
TRAIN_COMPONENT_IMAGE_URI = "us-central1-docker.pkg.dev/my-portfolio-project-v2-484602/intelligent-api-components-repo/train-component@sha256:ca9a6c3e57d68dbf3374a2e7be13a8dd5bb760ebbc61275b59a1752b8c805c64"


@component(
    base_image=TRAIN_COMPONENT_IMAGE_URI,
)
def train_model():
    """
    This is a simple, one-step component that "trains" a model.
    In reality, it just runs the main.py from our `components/train` directory.
    The @component decorator wraps this function in the container image we specify.
    """
    # The container's ENTRYPOINT is ["python", "main.py"], so this component
    # will execute that script when it runs. No additional code is needed here.
    pass


@dsl.pipeline(
    name="intelligent-api-hello-world-pipeline",
    description="A simple pipeline to test component execution."
)
def pipeline():
    """Defines the structure of the pipeline."""
    train_model_task = train_model().set_cpu_limit('1').set_memory_limit('4G')


if __name__ == "__main__":
    compiler.Compiler().compile(
        pipeline_func=pipeline,
        package_path="intelligent_api_pipeline.json"
    )