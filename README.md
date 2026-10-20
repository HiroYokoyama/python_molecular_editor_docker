# Dockerfile for MoleditPy

Repo: [https://github.com/HiroYokoyama/python_molecular_editor_docker/](https://github.com/HiroYokoyama/python_molecular_editor_docker/)

## Overview

This repository provides a `Dockerfile` to set up an environment for running the GUI application [`moleditpy`](https://github.com/HiroYokoyama/python_molecular_editor) inside a Docker container.

Running Linux GUI applications inside a Docker container requires many graphics, window system, and input-related system libraries that are not included in the base OS image. This `Dockerfile` installs all the necessary dependencies to run `moleditpy` stably with the required runtime libraries.

## Key Features

  * **Python 3.11** runtime environment
  * Installation of the latest unified `moleditpy` package with PySide6
  * `QT_API=pyside6` selects the same binding for QtPy and PyVistaQt
  * Open Babel is available separately through the optimizer plugin
  * System libraries essential for running GUI applications:
      * **Graphics-related:** OpenGL, Mesa, EGL (such as `libgl1`, `libglu1-mesa`, `libegl1`) 
      * **X11/XCB-related:** Window management, keyboard/mouse input, and display communication (such as `libx11-xcb1`, `libxkbcommon-x11-0`, and various `libxcb-*` libraries)
      * **Core libraries:** Font configuration and event loops (such as `libfontconfig1`, `libglib2.0-0`) 

## Prerequisites

  * [Docker](https://www.docker.com/get-started) must be installed.
  * **Linux:** Standard desktop environment.
  * **macOS:** [XQuartz](https://www.xquartz.org/) must be installed and configured.
  * **Windows:** [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or WSL2 GUI support (WSLg) must be enabled.

## How to Use

### 1. Clone the Repository

```bash
git clone https://github.com/HiroYokoyama/python_molecular_editor_docker.git
cd python_molecular_editor_docker
```

### 2. Build the Docker Image

Run the following command in the directory containing the `Dockerfile` to build a Docker image named `moleditpy-app`.

```bash
docker build -t moleditpy-app .
```

### 3. Run the Container (with GUI Display)

Special configuration is required to display the GUI from inside the container on your host machine (your PC).

#### For Linux Hosts

1.  **(First time only) Allow connections from the container**
    Run the following command in your host terminal:

    ```bash
    xhost +local:docker
    ```

2.  **Start the container**
    Start the container using the following command, and the `moleditpy` GUI window will be displayed on your desktop.

    ```bash
    docker run --rm -it \
    -e DISPLAY=$DISPLAY \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v moleditpy-data:/data \
    -v moleditpy-setting:/root/.moleditpy \
    moleditpy-app
    ```

#### For macOS / Windows

The basic commands are the same, but the configuration of the `DISPLAY` environment variable may differ (e.g., `docker.for.mac.host.internal:0`, etc.).

-----

For software rendering on systems where GPU forwarding is unavailable, add
`-e LIBGL_ALWAYS_SOFTWARE=1` to `docker run`. Persistent settings and plugins are
stored in `/root/.moleditpy`; molecule files can be kept in `/data`.

## CI and releases

GitHub Actions builds both images and checks the CLI version, pip consistency,
Qt/xcb runtime libraries, PySide6 selection, RDKit, the application window and
3D rendering. CI uses Xvfb and software rendering; this does not test every
host GPU or display-server configuration.

The workflow can also be run manually on a selected branch/ref, with an expected
version for the pinned image (default `5.0.1`). The default image follows the
latest compatible packages from PyPI and checks that the CLI reports the installed
package version. The input does not change package versions.

Run the same checks locally on Linux with Docker and Xvfb installed:

```bash
bash tests/docker_smoke.sh Dockerfile . moleditpy-smoke latest
bash tests/docker_smoke.sh pinned-version/Dockerfile pinned-version moleditpy-smoke-pinned 5.0.1
```

Without Xvfb, the test uses Qt's offscreen platform. The image itself leaves Qt
platform selection to the runtime environment and sets no Mesa GL/GLSL override.

For pinned Python dependencies and a fixed base-image digest, see
[pinned-version](pinned-version/README.md). Debian package revisions are resolved
from current mirrors, so neither recipe promises byte-for-byte reproducibility.

A `v*.*.*` tag runs both smoke tests before publishing a GitHub release. Keep the
pinned application version in its requirements, workflow defaults and tag
aligned. The rolling image is tested against the version obtained at build time.
Release tags match the pinned application version, for example
`v5.0.1`. The workflow does not publish an image to a container registry.
