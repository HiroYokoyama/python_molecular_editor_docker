## This is a Dockerfile for MoleditPy installation

FROM python:3.11-slim-trixie

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcursor1 \
    libx11-xcb1 \
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
    libglib2.0-0t64 \
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    && rm -rf /var/lib/apt/lists/*

RUN python -m pip install --no-cache-dir --upgrade pip && \
    python -m pip install --no-cache-dir moleditpy matplotlib && \
    python -m pip check

ENV QT_API=pyside6

VOLUME /data

WORKDIR /data

CMD ["moleditpy"]
