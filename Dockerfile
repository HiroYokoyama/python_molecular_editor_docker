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
    pip install --no-cache-dir moleditpy-linux

CMD ["moleditpy"]
