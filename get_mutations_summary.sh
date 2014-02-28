#!/bin/sh

cat <<EOF | psql cosmic_clp
copy (
    select gene_name, count(distinct(sample_name)) as lines_with_mutation
    from complete join marc_cell_lines using (sample_name) join marc_genes using (gene_name)
    where mutation_somatic_status <> ''
    group by gene_name
    order by gene_name
) to stdout (format csv, header true);
EOF
