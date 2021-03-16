#!/usr/bin/env bash

watch() {
    find . -type f '(' -name '*.tex' -or -name '*.bib' ')' -print0 | xargs -0 inotifywait -e CLOSE_WRITE -e MOVE_SELF -e DELETE_SELF
}

while true; do
    watch
    make
done
