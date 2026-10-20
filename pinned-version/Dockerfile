FROM python:3.11-slim@sha256:5e9093a415c674b51e705d42dde4dd6aad8c132dab6ca3e81ecd5cbbe3689bd2

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcursor1 \
    libx11-xcb1 \
    libxcb-cursor0 \
    libgl1 \
    libglx-mesa0 \
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
    libxcb-icccm4 \
    libxcb-keysyms1 \
    libxcb-shape0 \
    libxcb-xkb1 \
    libxkbcommon-x11-0 \
    libglib2.0-0t64 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir pip==26.2.1 && \
    pip install --no-cache-dir -r requirements.txt && \
    python -m pip check

ENV QT_API=pyside6

VOLUME /data

WORKDIR /data

CMD ["moleditpy"]
