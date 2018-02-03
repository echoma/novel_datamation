#!/bin/bash

ARGS="--host=localhost --user=nd --password=nd --opt --skip-dump-date --order-by-primary"
mysqldump $ARGS story_of_stone | sed 's$VALUES ($VALUES\n($g' | sed 's$),($),\n($g' > ../db.sql
#mysqldump $ARGS story_of_stone > ../db.sql
