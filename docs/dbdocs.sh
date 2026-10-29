#!/bin/bash

# Shell script to build model graphs and schema descriptions
pushd ./project

# generate schema doc page
python manage.py table_models > ../docs/docs/db/schema.md

# generate ER diagram png
python manage.py graph_models seazit -g -o ../docs/docs/db/seazit.png

popd
