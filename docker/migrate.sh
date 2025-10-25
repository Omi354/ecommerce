#!/bin/zsh

#################################
### 実行方法
### $ ./migrate.sh
#################################

# ./exec.sh rails db:migration
./exec.sh ridgepole -c config/database.yml -E development --apply -f db/Schemafile
./exec.sh ridgepole -c config/database.yml -E test --apply -f db/Schemafile
./exec.sh rails db:schema:dump
