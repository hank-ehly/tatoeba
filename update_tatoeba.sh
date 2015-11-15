#!/bin/bash

read -p "Please provide your mysql user, followed by [ENTER]: " -t 30 -s USR
echo ""
read -p "Please provide your mysql password, followed by [ENTER]: " -t 30 -s PSWD
echo ""
rm -rf tmp_*/
TIMESTAMP=$(date +%Y%m%d%H%M%S)
TMP_DIR="./tmp_$TIMESTAMP"
mkdir "$TMP_DIR"
cd "$TMP_DIR" || exit
curl -L -O http://downloads.tatoeba.org/exports/jpn_indices.tar.bz2
tar xvjf jpn_indices.tar.bz2
rm jpn_indices.tar.bz2
cd "../" || exit
if [[ -f "setup_db.sql" ]]; then
  mysql -u $USR --password="$PSWD" < "setup_db.sql"
else
  exit
fi
cd "$TMP_DIR" || exit
mysqlimport	\
  --user $USR \
  --password="$PSWD" \
  --columns='sentence_id,meaning_id,text' \
  --default-character-set='utf8' \
  --fields-terminated-by='\t' \
  --lines-terminated-by='\n' \
  --delete \
  --local \
  	tatoeba \
  	jpn_indices.csv
cd "../" || exit
rm "$TMP_DIR/jpn_indices.csv"
rmdir "$TMP_DIR"