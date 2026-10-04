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

RUN pip install --no-cache-dir pip==26.2.1 && \
    pip install --no-cache-dir matplotlib==3.11.2 moleditpy-linux==4.11.1 numpy==2.3.5 PyQt6==6.11.0 PyQt6-Qt6==6.11.2 PyQt6_sip==13.12.0 pyvista==0.48.4 pyvistaqt==0.12.0 QtPy==2.4.3 rdkit==2026.3.6 vtk==9.6.2

VOLUME /data

WORKDIR /data

CMD ["moleditpy"]
