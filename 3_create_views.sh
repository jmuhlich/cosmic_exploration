#!/bin/bash

cat <<EOF | psql cosmic

create or replace view mutations_all as
  select
    sample_name, gene_name, mutation_aa,
    string_agg(distinct(mutation_cds),';') mutation_cds,
    string_agg(distinct(id_sample),';') id_sample,
    string_agg(distinct(mutation_somatic_status),';') mutation_somatic_status,
    string_agg(distinct(data_source),';') data_source
  from
    complete
    join marc_cell_lines using (sample_name)
    join marc_genes using (gene_name)
  where
    mutation_somatic_status <> ''
  group by
    sample_name, gene_name, mutation_aa
  order by
    sample_name, gene_name, mutation_aa
  ;

EOF
