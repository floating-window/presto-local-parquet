#!/bin/bash

# Exit on Ctrl+C
trap exit INT 

for file in `ls $1`; do
  SRC_FILE="$1/${file}"
  SCHEMA_FILE="/tmp/${file}.schema"
  
  printf "Getting shema for: ${SRC_FILE} ... "
  parquet-tools schema ${SRC_FILE} 2>/dev/null | ./convert-schema.awk > \
    ${SCHEMA_FILE}
  
  SCHEMA_HASH=`cat ${SCHEMA_FILE} | md5 | tr -d \\n`
  printf "${SCHEMA_HASH}\n"

  DST_DIR="$1/${SCHEMA_HASH}"
  mkdir -p ${DST_DIR}
  mv ${SRC_FILE} "$1/${SCHEMA_HASH}/${file}"

  if [[ ! -e "${DST_DIR}/schema.txt" ]]; then
    echo "Copying schema..."
    cp ${SCHEMA_FILE} "${DST_DIR}/schema.txt"
  fi
done
