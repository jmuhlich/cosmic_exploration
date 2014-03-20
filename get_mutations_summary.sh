#!/bin/sh

for clause in "" "mutation_somatic_status<>'Variant of unknown origin'"; do
    echo "====="
    echo "${clause:-(all data)}"
    echo "====="
    cat <<EOF | psql cosmic
    copy (
      select
        marc_genes.gene_name,
        count(distinct(sample_name)) as lines_with_mutation
      from
        marc_genes
        left join mutations_all on
          marc_genes.gene_name = mutations_all.gene_name
          ${clause:+and} $clause
      group by marc_genes.gene_name
      order by marc_genes.gene_name
    ) to stdout (format csv, header true);
EOF
    echo
done
