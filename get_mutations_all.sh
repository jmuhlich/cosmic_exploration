#!/bin/bash

cat <<EOF | psql cosmic
copy (select * from mutations_all) to stdout (format csv, header true);
EOF
