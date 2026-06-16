# Dockerfile for MoleditPy

## Overview

This repository provides a `Dockerfile` to set up an environment for running the GUI application [`moleditpy`](https://github.com/HiroYokoyama/python_molecular_editor) inside a Docker container.

Running Linux GUI applications inside a Docker container requires many graphics, window system, and input-related system libraries that are not included in the base OS image. This `Dockerfile` installs all the necessary dependencies to run `moleditpy` stably and creates a highly reproducible environment.

## Key Features

  * **Python 3.11** runtime environment
  * Installation of the `moleditpy-linux` application
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

*This Dockerfile was constructed through an iterative debugging process, ensuring that all necessary dependencies for the Qt-based GUI application are included.*
