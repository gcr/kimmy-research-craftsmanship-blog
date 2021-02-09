#!/bin/bash
set -e
function rem() {
  echo -e "\x1b[31;1m" $* "\x1b[0m"
}

if [ ! -d "$1" ]; then
    echo "Usage: $0 <directory>"
    exit 1
fi
SOURCE_DIRECTORY="$1"
TARGET_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd "$TARGET_DIRECTORY"

TAG=FE242E93-E6CE-4E62-BF5C-825AC318456C

rem " -- git pull"
git pull

rem " -- new local notes..."
rg -l "$TAG" "$SOURCE_DIRECTORY" | while read file; do
    if [ "$file" -nt "$TARGET_DIRECTORY/`basename "$file"`" ]; then
    #NUM_LINKS=`stat -f "%l" "$file"`
    #if [ $NUM_LINKS -eq 1 ]; then
        echo "$file --> git"
        cp -a "$file" "$TARGET_DIRECTORY"
    fi
done

rem " -- new remote notes..."
rg -l "$TAG" "$TARGET_DIRECTORY" | grep -v worksync.sh | while read file; do
    if [ "$file" -nt "$SOURCE_DIRECTORY/`basename "$file"`" ]; then
    #NUM_LINKS=`stat -f "%l" "$file"`
    #if [ $NUM_LINKS -eq 1 ]; then
        echo "`basename "$file"` <-- git"
        cp -a "$file" "$SOURCE_DIRECTORY"
    fi
done

rem " -- git commit"
cd "$TARGET_DIRECTORY"
git add -A .
git commit -m "Automatic commit from ingest.sh" || true

rem '-- emacs: rebuild org-roam cache'
emacsclient -e '(org-roam-db-build-cache)'

read -p 'Push? [y/N] > ' DO_PUSH
if [ "$DO_PUSH" = "y" ]; then
    rem ' -- git push'
    git push
fi
