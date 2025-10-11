FROM python:3.11-slim@sha256:5e9093a415c674b51e705d42dde4dd6aad8c132dab6ca3e81ecd5cbbe3689bd2

RUN apt-get update && apt-get install -y --no-install-recommends \
    libxcb-cursor0=0.1.5-1 \
    libgl1=1.7.0-1+b2 \
    libglx-mesa0=25.0.7-2 \
    libglu1-mesa=9.0.2-1.1+b3 \
    libxrender1=1:0.9.12-1 \
    libsm6=2:1.2.6-1 \
    libice6=2:1.1.1-1 \
    libxext6=2:1.3.4-1+b3 \
    libxi6=2:1.8.2-1 \
    libxkbcommon0=1.7.0-2 \
    libfontconfig1=2.15.0-2.3 \
    libdbus-1-3=1.16.2-2 \
    libxcb-xinerama0=1.17.0-2+b1 \
    libegl1=1.7.0-1+b2 \
    libxcb-icccm4=0.4.2-1 \
    libxcb-keysyms1=0.4.1-1 \
    libxcb-shape0=1.17.0-2+b1 \
    libxcb-xkb1=1.17.0-2+b1 \
    libxkbcommon-x11-0=1.7.0-2 \
    libglib2.0-0t64=2.84.4-3~deb13u1 \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

VOLUME /data

CMD ["moleditpy"]
