#!/usr/bin/env sh

for EXPORT_DIR in $(find -name 'export' -type d); do
    for FILE in $(ls "${EXPORT_DIR}"/*); do
        FILENAME=$(basename "${FILE}")
        FILENAME=$(echo "${FILENAME}" | sed -E 's/-Page-1\.(.*)$/.\1/')
        ORIGINAL_DIR=$(dirname "$(dirname "${FILE}")")
        mv -v "${FILE}" "${ORIGINAL_DIR}/${FILENAME}"
    done
    rmdir "${EXPORT_DIR}"
done
