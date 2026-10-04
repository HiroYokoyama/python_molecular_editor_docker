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

if ! grep --fixed-strings --quiet "$expected_version" <<<"$version_output"; then
    echo "Expected version $expected_version was not found in moleditpy output." >&2
    exit 1
fi

echo "Docker smoke test passed for $image"
