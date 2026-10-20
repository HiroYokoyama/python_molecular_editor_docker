# Pinned Python dependencies

This image runs **Moleditpy 5.0.1** on Python 3.11 / Debian 13 (trixie).
`requirements.txt` pins the application and its Python dependencies, including
PySide6 Essentials and Shiboken 6.11.2. PyQt6 and Open Babel are not installed.
The lock was resolved for Linux x86-64 / CPython 3.11; other architectures are
not covered by this dependency selection.

The base image is fixed by digest. Debian packages are installed from the current
trixie mirrors without exact revision pins: old revisions can disappear from
those mirrors. Consequently this is **not a byte-for-byte reproducible build**.
For an immutable deployment, retain the built image and deploy its digest.

## Build and run

From this directory:

```bash
docker build -t moleditpy-app:pinned .
xhost +local:docker
docker run --rm -it \
    -e DISPLAY="$DISPLAY" \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v moleditpy-data:/data \
    -v moleditpy-setting:/root/.moleditpy \
    moleditpy-app:pinned
```

The image selects `QT_API=pyside6`. See the main README for display-server
requirements and software-rendering options.

## Maintenance

Resolve dependencies in a clean Linux x86-64 Python 3.11 environment using the
intended `moleditpy` release and matplotlib. Replace `requirements.txt` with the
resolved packages, preserving exact versions. Keep the app version in both
Dockerfiles, the workflow defaults and the README aligned. PySide6/Shiboken
6.12.0 are excluded by Moleditpy 5.0.1's dependency constraints.

Update the base digest separately when applying OS/Python security updates.
The same package names must be available in that base image's Debian release.

From the repository root, validate changes with:

```bash
bash tests/docker_smoke.sh pinned-version/Dockerfile pinned-version moleditpy-smoke-pinned 5.0.1
```

CI tests the CLI, pip consistency, Qt/xcb, the real application window, RDKit and
3D rendering before the tag release workflow can publish a GitHub release.
