#!/bin/bash
for file in /tmp/mock_data/MOCK_DATA_*.csv; do
    psql -U lab1 -d lab1 -c "\copy lab1.mock_data FROM '$file' DELIMITER ',' CSV HEADER"
done