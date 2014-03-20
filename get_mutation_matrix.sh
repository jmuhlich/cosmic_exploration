#!/bin/bash

cat <<EOF | psql cosmic
copy (
    select
        marc_cell_lines.sample_name, gene_mutants.gene_name, mutant,
        case
          when mutations_all.sample_name is null

-- uncomment the following clause to discard mutations with unknown status
--            or mutation_somatic_status='Variant of unknown origin'

            then 0
          else 1
        end
    from
        marc_cell_lines
        left join
            (
            select
                distinct gene_name, concat(gene_name, '_', mutation_aa) as mutant
            from
                mutations_all
            ) as gene_mutants
            on true
        left join mutations_all
            on marc_cell_lines.sample_name=mutations_all.sample_name and
            gene_mutants.mutant=concat(mutations_all.gene_name, '_', mutation_aa)
    order by
        marc_cell_lines.sample_name, mutant
) to stdout (format csv, header true);
EOF
