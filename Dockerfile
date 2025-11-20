## This is a Dockerfile for MoleditPy installation

FROM python:3.11-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcb-cursor0 \
    libgl1 libglx-mesa0 \
    libglu1-mesa \
    libxrender1 \
    libsm6 \
    libice6 \
    libxext6 \
    libxi6 \
    libxkbcommon0 \
    libfontconfig1 \
    libdbus-1-3 \
    libxcb-xinerama0 \
    libegl1 \
    libglib-2.0-0 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

    RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir matplotlib==3.10.7 moleditpy-linux numpy==2.3.4 PyQt6==6.9.1 PyQt6-Qt6==6.9.2 PyQt6_sip==13.10.2 pyvista==0.46.4 pyvistaqt==0.11.3 QtPy==2.4.3 rdkit==2025.9.1 vtk==9.5.2

VOLUME /data

WORKDIR /data

CMD ["moleditpy"]
