#!/bin/bash

cat <<EOF | psql cosmic_clp
copy
(
    select id_sample, sample_name, gene_name, mutation_cds, mutation_aa, mutation_somatic_status
    from complete join marc_cell_lines using (sample_name) join marc_genes using (gene_name)
    where mutation_somatic_status <> ''
    order by sample_name, gene_name, mutation_aa
)
to stdout (format csv, header true);
EOF
