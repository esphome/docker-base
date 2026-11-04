# ESPHome Base Image

This base image is designed to be used as a base layer for the ESPHome containers.

## Releasing

Pull requests are built by CI as `pr-<N>` images and run an ESPHome integration test that compiles a test config on top of the new base image.

Merging to `main` updates a draft release (Release Drafter) that carries a warning not to publish it yet. The Build workflow then builds and pushes images tagged with the commit SHA, and clears the warning, or replaces it with a failure notice if the build failed.

Publishing the draft runs the Release workflow, which adds the version tags (`YYYY.MM.N`) to the already-built images without rebuilding them.

Maintainers can also build and push images from any branch by hand with "Run workflow" on the Build workflow. The images are tagged with the branch name (or a chosen tag, but never a version tag), and the draft release is not touched.
