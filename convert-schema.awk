#!/usr/bin/awk -f

BEGIN {
    PRESTO_TYPE_BY_PARQUET_TYPE["binary"] = "VARCHAR"
    PRESTO_TYPE_BY_PARQUET_TYPE["int32"] = "INTEGER"
    PRESTO_TYPE_BY_PARQUET_TYPE["float"] = "REAL"
    NESTING=0
    CLOSE_ARRAY_NESTING=-1
}

{
    printf LAST

    match($0, /^ */);
    LEADING_SPACE=substr($0,0,RLENGTH);
    REPETITION=$1
    TYPE=$2
    gsub(/;/,"",$3)
    NAME=$3
    
    if ($1 == "}") {
        NESTING = NESTING - 1
    }

    if (NESTING == CLOSE_ARRAY_NESTING) {
        CLOSE_ARRAY = " )"
        CLOSE_ARRAY_NESTING = -1
    } 

    if (REPETITION == "repeated") {
        REPETITION = " ARRAY("
        CLOSE_ARRAY_NESTING = NESTING
    } else {
        REPETITION = ""
    }

    if ($1 == "}") {
        LAST = CLOSE_ARRAY "\n" LEADING_SPACE ")"
        LS = ",\n"
    } else if ($1 == "message") {
        LAST = LEADING_SPACE "CREATE TABLE _bucket_ ("
        LS = "\n"
        NESTING = NESTING + 1
    } else if (TYPE == "group") {
        LAST = CLOSE_ARRAY LS LEADING_SPACE NAME REPETITION " ROW("
        LS = "\n"
        NESTING = NESTING + 1
    } else {
        LAST = CLOSE_ARRAY LS LEADING_SPACE NAME " " PRESTO_TYPE_BY_PARQUET_TYPE[TYPE]
        LS = ",\n"
    }

    CLOSE_ARRAY = ""
}

END {
    sub(/,\n $/,"",LAST)
    printf LAST "\n"
    printf "WITH ( format = 'PARQUET',  external_location='s3://_bucket_/' );"
}