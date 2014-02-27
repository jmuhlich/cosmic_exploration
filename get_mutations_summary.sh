#!/bin/sh

cat <<EOF | psql cosmic_clp
copy (
    select sample_name, count(distinct(gene_name)) as mutated_gene_count
    from complete join marc_cell_lines using (sample_name) join marc_genes using (gene_name)
    where mutation_somatic_status <> ''
    group by sample_name
    order by sample_name
) to stdout (format csv, header true);
EOF
