#!/usr/bin/env bash

while IFS= read -r -d '' EXPORT_DIR; do
    for FILE in "${EXPORT_DIR}"/*; do
        [ -e "${FILE}" ] || break
        FILENAME=$(basename "${FILE}")
        FILENAME=$(echo "${FILENAME}" | sed -E 's/-Page-1\.(.*)$/.\1/')
        ORIGINAL_DIR=$(dirname "$(dirname "${FILE}")")
        mv -v "${FILE}" "${ORIGINAL_DIR}/${FILENAME}"
    done
    rmdir "${EXPORT_DIR}"
done < <(find . -name 'export' -type d -print0)
