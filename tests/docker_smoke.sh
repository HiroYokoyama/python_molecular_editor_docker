#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 4 ]]; then
    echo "Usage: $0 <dockerfile> <context> <image> <expected-version>" >&2
    exit 2
fi

dockerfile=$1
context=$2
image=$3
expected_version=${4#v}

cleanup() {
    docker image rm --force "$image" >/dev/null 2>&1 || true
}
trap cleanup EXIT

echo "Building $image from $dockerfile (context: $context)"
docker build --pull --file "$dockerfile" --tag "$image" "$context"

echo "Checking moleditpy --version"
version_output="$(docker run --rm --entrypoint moleditpy "$image" --version 2>&1)"
printf '%s\n' "$version_output"

if ! grep --fixed-strings --line-regexp --quiet "MoleditPy $expected_version" <<<"$version_output"; then
    echo "CLI did not report the expected version $expected_version" >&2
    exit 1
fi

actual_version="$(docker run --rm --entrypoint python "$image" -c 'from importlib.metadata import version; print(version("moleditpy"))')"
if [[ "$actual_version" != "$expected_version" ]]; then
    echo "Expected $expected_version, got $actual_version" >&2
    exit 1
fi

docker run --rm --entrypoint python "$image" -m pip check

# Test xcb under a virtual X server when available (GitHub's Ubuntu runner).
# -ac lets the container connect without copying the host Xauthority file.
if command -v xvfb-run >/dev/null 2>&1; then
    xvfb-run -a --server-args="-screen 0 1280x1024x24 -ac" \
        timeout 120s docker run --rm -i --entrypoint python -e DISPLAY -e QT_QPA_PLATFORM=xcb \
        -e LIBGL_ALWAYS_SOFTWARE=1 -v /tmp/.X11-unix:/tmp/.X11-unix:ro \
        "$image" - "$expected_version" < tests/image_smoke.py
else
    timeout 120s docker run --rm -i --entrypoint python -e QT_QPA_PLATFORM=offscreen \
        -e LIBGL_ALWAYS_SOFTWARE=1 "$image" - "$expected_version" < tests/image_smoke.py
fi

echo "Docker smoke test passed for $image"
