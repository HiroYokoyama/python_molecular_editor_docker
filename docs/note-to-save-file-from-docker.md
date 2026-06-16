# Docker Version of Python Molecular Editor: Bind Mount Configuration Guide for Saving Files to the Host PC

This document explains the technical procedures for permanently saving files created in the "Python Molecular Editor" running as a Docker container to a specified folder on your host PC.

## 1. Purpose

By default, Docker containers are stateless. Any files created using GUI applications inside the container will be lost once the container is deleted (`docker rm`).

To solve this problem, we directly connect (**bind mount**) a folder on the host PC to a specific folder inside the container. This allows the application inside the container to save files to what appears to be a normal folder, while the actual files are stored persistently on the host PC.

## 2. Prerequisites

  - Docker must be installed on the host PC.
  - **(Important) An X Window System environment must be prepared to display GUI applications from the container.**
      - **macOS:** [XQuartz](https://www.xquartz.org/) must be installed and running.
      - **Windows:** [WSL2](https://learn.microsoft.com/en-us/windows/wsl/install) with VcXsrv or a Windows 11 environment with WSLg enabled must be prepared.
      - **Linux:** Usually requires no additional configuration.

## 3. Configuration Steps

### Step 1: Create a Folder for Data Storage on the Host PC

First, create a dedicated folder on the host PC to receive the files saved from the container. As an example, we will create a folder named `molecular-data` on the desktop.

```bash
# Go to the Desktop (adjust the path to match your environment)
cd ~/Desktop

# Create a folder for data storage
mkdir molecular-data
```

This `molecular-data` folder will serve as the shared point with the container.

### Step 2: Run the `docker run` Command with a Bind Mount

Add the `-v` option to the `docker run` command to connect the folder created in Step 1 to a folder inside the container.

#### Basic Command Structure

```bash
docker run -it --rm \
  -v <absolute_path_on_host>:<absolute_path_in_container> \
  <gui_connection_settings> \
  <image_name>
```

  - `-v`: Option to specify a volume (bind mount in this case).
  - `<absolute_path_on_host>`: The full path to the `molecular-data` folder created earlier.
  - `<absolute_path_in_container>`: The location inside the container where this folder will be visible. Placing it in the user's home directory makes it easy to find. Example: `/home/user/data` or `/data`.
  - `<gui_connection_settings>`: Environment variables or network settings to connect to the X Window System.
  - `<image_name>`: The name of the Docker image containing Python Molecular Editor (e.g., `pme-image:latest`).

### Step 3: Run Commands by Platform

Run the command corresponding to your OS.
The following examples mount the host's `~/Desktop/molecular-data` to `/data` inside the container.

-----

#### **macOS (Using XQuartz)**

Launch XQuartz and ensure "Allow connections from network clients" is checked in the security settings.

```bash
# Get the IP address in the terminal
IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')

# Allow connection
xhost + $IP

# Run the Docker container
docker run -it --rm \
  -v ~/Desktop/molecular-data:/data \
  -e DISPLAY=${IP}:0 \
  pme-image:latest
```

-----

#### **Windows (Using WSL2 + WSLg)**

Under Windows 11 WSLg, GUI settings are automated and very simple.

```bash
# Run from the WSL terminal
docker run -it --rm \
  -v /mnt/c/Users/<Your-Username>/Desktop/molecular-data:/data \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  pme-image:latest
```

*Note: Replace `<Your-Username>` with your actual Windows username.*

-----

#### **Linux**

This is the simplest setup to run.

```bash
# Allow connection (if necessary)
xhost +local:

# Run the Docker container
docker run -it --rm \
  -v ~/Desktop/molecular-data:/data \
  -e DISPLAY=$DISPLAY \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  pme-image:latest
```

## 4. Operation Inside the Container

When you start the container using the command above, the Python Molecular Editor GUI will open.

1.  Create or edit a molecular model within the application.
2.  Select "File" -> "Save As..." from the menu.
3.  When the file save dialog appears, navigate to the mount destination directory specified in the command (in this example, `/data`).
4.  Save the file with any name (e.g., `caffeine.xyz`).
5.  Once saved, you can verify that the `caffeine.xyz` file has been created inside the `molecular-data` folder on your host PC's desktop.

Even if you exit the container (using the `exit` command or closing the window, which automatically deletes the container due to the `--rm` option), the files on your host PC are completely preserved.

## 5. Summary

| Option | Role |
| :--- | :--- |
| **`-v <HOST_PATH>:<CONTAINER_PATH>`** | **Core setting for bind mounting.** Bi-directionally synchronizes files between the host and the container. |
| **`-e DISPLAY=...`** | **Required for GUI display.** Tells GUI applications inside the container where to draw (pointing to the host's display). |
| **`-v /tmp/.X11-unix...`** | **Required for GUI display.** Shares the communication socket with the X server between the host and the container. |

By following this procedure, you can safely and permanently manage the important data generated by the GUI application while benefiting from Docker's portability and isolation.
