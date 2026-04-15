#!/bin/sh
set -eu

REPO="${AGENT_MEMORY_REPO:-taichuy/agentMemory}"
REF="${AGENT_MEMORY_REF:-main}"
DESTINATION="${AGENT_MEMORY_DEST:-.}"
FORCE=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --ref)
      REF="$2"
      shift 2
      ;;
    --dest)
      DESTINATION="$2"
      shift 2
      ;;
    --force)
      FORCE=1
      shift
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

DESTINATION="$(cd "$DESTINATION" && pwd)"
TARGET_MEMORY_PATH="$DESTINATION/.memory"

if [ -e "$TARGET_MEMORY_PATH" ] && [ "$FORCE" -ne 1 ]; then
  echo ".memory already exists in '$DESTINATION'. Re-run with --force to replace it." >&2
  exit 1
fi

TMPDIR="$(mktemp -d 2>/dev/null || mktemp -d -t agentMemory)"
ARCHIVE_PATH="$TMPDIR/agentMemory.tar.gz"
EXTRACT_PATH="$TMPDIR/extract"

cleanup() {
  rm -rf "$TMPDIR"
}

trap cleanup EXIT INT TERM

mkdir -p "$EXTRACT_PATH"
DOWNLOAD_URL="https://codeload.github.com/$REPO/tar.gz/refs/heads/$REF"

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$DOWNLOAD_URL" -o "$ARCHIVE_PATH"
elif command -v wget >/dev/null 2>&1; then
  wget -qO "$ARCHIVE_PATH" "$DOWNLOAD_URL"
else
  echo "Either curl or wget is required to download the archive." >&2
  exit 1
fi

tar -xzf "$ARCHIVE_PATH" -C "$EXTRACT_PATH"
REPO_ROOT="$(find "$EXTRACT_PATH" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

if [ -z "$REPO_ROOT" ] || [ ! -d "$REPO_ROOT/.memory" ]; then
  echo "The repository archive does not contain a .memory directory." >&2
  exit 1
fi

if [ -e "$TARGET_MEMORY_PATH" ]; then
  rm -rf "$TARGET_MEMORY_PATH"
fi

cp -R "$REPO_ROOT/.memory" "$TARGET_MEMORY_PATH"
echo "Installed .memory into $DESTINATION"
