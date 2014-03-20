cosmic\_exploration
==================

Tools to load COSMIC data files into Postgres and explore them

Instructions
------------

1. 1\_fetch\_data.sh
2. 2\_create\_db.sh
3. 3\_create\_views.sh
4. get\_mutations\_summary.sh
5. get\_mutation\_matrix.sh ; create pivot table from results
   (read commented line in query for more details)
6. get\_mutations\_all.sh

Data files
----------
* cell\_line\_fixups.txt - corrections to normalize some COSMIC sample names
* marc\_cell\_lines.txt - cell lines from Marc to report on
* marc\_genes.txt - genes from Marc to report on

