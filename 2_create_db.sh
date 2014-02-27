#!/bin/bash

db_name=cosmic_clp

file_main="CosmicCellLineProject_v68.tsv.gz"
file_complete="CosmicCLP_CompleteExport_v68.tsv.gz"
file_mutant="CosmicCLP_MutantExport_v68.tsv.gz"

function normalize_headers {
    gzip -dc $1 | head -1 | \
        perl -p -e '$_=lc($_); s/ \([^)]+\)//g; s/[ -]/_/g;'
}

function create_stmt {
    echo "create table $1 ("
    perl -p -e 'chomp; s/\t/ text, /g'
    echo ' text'
    echo ");"
}

echo "drop database $db_name" | psql postgres 2>/dev/null
echo "create database $db_name" | psql postgres
for name in main complete mutant; do
    eval file="\$file_$name"
    normalize_headers $file | create_stmt $name | psql $db_name
    (
        echo "copy $name from stdin (format text);"
        gzip -dc $file | tail -n +1
    ) | \
        psql $db_name
done

echo "create table marc_genes (gene_name text);" | psql $db_name
(
    echo "copy marc_genes from stdin (format text);"
    cat marc_genes.txt
) | \
    psql $db_name

echo "create table marc_cell_lines (sample_name text);" | psql $db_name
(
    echo "copy marc_cell_lines from stdin (format text);"
    cat marc_cell_lines.txt
) | \
    psql $db_name