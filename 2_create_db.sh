#!/bin/bash

db_name=cosmic

file_clp="CosmicCLP_CompleteExport_v68.tsv.gz"
file_cosmic="CosmicCompleteExport_v68.tsv.gz"

function normalize_headers {
    gzip -dc $1 | head -1 | \
        perl -p -e '$_=lc($_); s/ \([^)]+\)//g; s/[ -]/_/g;'
}

function create_stmt {
    echo "create table $1 ("
    perl -p -e 'chomp; s/\s+/ text, /g'
    echo ' text'
    echo ");"
}

function load_list {
    local table=${1}
    local columns=${2}
    echo $columns | create_stmt $table | psql $db_name
    (
        echo "copy $table from stdin (format text);"
        cat $table.txt
    ) | \
        psql $db_name
}

function do_sql {
    psql $db_name -c "$1"
}

if [[ "$BASH_SOURCE" == "$0" ]]; then

    # echo "Resetting database..."
    psql postgres -c "drop database $db_name" || exit 1
    psql postgres -c "create database $db_name" || exit 1

    echo "Loading main data..."
    HEADERS=$(normalize_headers $file_clp)' data_source'
    echo "$HEADERS" |  create_stmt complete | psql $db_name
    for ext in clp cosmic; do
        eval file="\$file_$ext"
        echo "    $file"
        (
            echo "copy complete from stdin (format text);"
            gzip -dc $file | tail -n +1 | sed -e "s/$/\t$ext/"
        ) | \
            psql $db_name
    done

    echo "Loading ancillary data..."
    load_list marc_genes gene_name
    load_list marc_cell_lines sample_name
    load_list cell_line_fixups 'src dest'

    echo "Creating indexes..."
    for index in 'complete(gene_name)' 'complete(sample_name)' \
        'marc_genes(gene_name)' 'marc_cell_lines(sample_name)' \
        'cell_line_fixups(src)' 'cell_line_fixups(dest)'; do
        echo "    $index"
        do_sql "create index on $index"
    done

    echo "Performing fixups.."
    do_sql "update complete set sample_name=dest from cell_line_fixups \
        where sample_name=src"

fi
