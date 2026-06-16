# Pinned Version for Reproducible Builds

This document explains the `Dockerfile` for `moleditpy-app` where the versions of all dependencies are fully pinned.

Adopting this approach ensures **"absolute reproducibility: no matter who builds it, when, or where, the exact same environment will be constructed."**

## 1. What is Version Pinning?

Version pinning means explicitly specifying a single version for every software component your application depends on (including the base image, OS packages, Python libraries, etc.).

For example, instead of a vague instruction like "install `libgl1`," it strictly commands "install version `1.7.0-1+b2` of `libgl1`."

### Why Pin Versions?

1.  **Absolute Reproducibility**
    Guarantees the exact same environment across development, testing, and production. It completely eliminates the "it worked on my machine..." problem.

2.  **Ensuring Stability**
    Prevents "silent breakage" where minor updates of dependency packages inadvertently break the application. A build that works today will work the exact same way a year from now.

3.  **Easier Debugging**
    Since the environment is invariant, you can eliminate dependency updates as a source of problems when debugging, allowing you to focus on the application's actual code.

## 2. Implementation in this Dockerfile

In this project, versions are pinned at three levels:

### a) Base Image (Base Image Digest)

On the first line of the `Dockerfile`, the base image is specified not just by a tag (`3.11-slim`), but by its **digest (`@sha256:...`)**.

```dockerfile
FROM python:3.11-slim@sha256:5e9093a415c674b51e705d42dde4dd6aad8c132dab6ca3e81ecd5cbbe3689bd2
```

  * **Tags** are mutable labels and may point to newer images over time.
  * **Digests** are unique "fingerprints" of the image contents. This ensures the underlying OS environment remains unchanged forever.

### b) OS Packages (apt)

For all libraries installed using the `RUN apt-get install` command, the exact version is specified in the format `package_name=version`.

```dockerfile
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcb-cursor0=0.1.5-1 \
    libgl1=1.7.0-1+b2 \
    ...
    libglib2.0-0t64=2.84.4-3~deb13u1 \
    && rm -rf /var/lib/apt/lists/*
```

These versions were identified within the base image using the `apt-cache policy <package_name>` command. Suffixes like `t64` are also strictly specified to match the system's architecture.

### c) Python Packages (pip)

Python dependencies are managed via a `requirements.txt` file. The `pip install` command refers to this file to install packages of specific versions.

```dockerfile
COPY requirements.txt . 
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt
```

`requirements.txt` is typically generated with the `pip freeze` command, listing the main `moleditpy` package along with all indirect dependencies (like `PyQt6`) with pinned versions.

```txt
# Example requirements.txt
moleditpy-linux==1.2.6.2
PyQt6==6.9.1
...
```

## 3. How to Use

Building and running the container is done in the same way as the standard version, but using this `Dockerfile` guarantees identical results.

1.  **Build the Docker image**

    ```bash
    docker build -t moleditpy-app:pinned .
    ```

2.  **Run the container (for Linux)**

    ```bash
    xhost +local:docker
    docker run --rm -it \
           -e DISPLAY=$DISPLAY \
           -v /tmp/.X11-unix:/tmp/.X11-unix \
           -v moleditpy-data:/data \
           moleditpy-app:pinned
    ```

## 4. Maintenance: How to Update Dependencies

Pinning versions means security updates and patches are not automatically applied, necessitating **intentional and periodic maintenance**.

1.  **Updating the Base Image:**

      * Run `docker pull python:3.11-slim` to fetch the latest version.
      * Find the new digest using `docker images --digests python:3.11-slim`, and update the `FROM` line in your `Dockerfile`.

2.  **Updating OS Packages:**

      * Spin up a container from the new base image, check the latest versions of each package using `apt-cache policy`, and update the `Dockerfile`.

3.  **Updating Python Packages:**

      * Run `pip install --upgrade moleditpy-linux` in a clean Python virtual environment.
      * Re-generate `requirements.txt` by running `pip freeze > requirements.txt`.

Always thoroughly test that the application functions correctly after updating dependencies.
