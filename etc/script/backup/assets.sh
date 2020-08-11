#! /bin/bash

INP=nipin@ssh.nipin.xyz:web/chivi/var
OUT=var

rsync -azi "$INP/appcv/members" "$OUT/appcv"
rsync -aiz "$INP/bookdb/indexes" "$OUT/bookdb"
# rsync -aiz "$INP/appcv/chtexts" "$OUT/appcv"
# rsync -az "$INP/bookdb/serials" "$OUT/bookdb"
# rsync -az "$INP/bookdb/chlists" "$OUT/bookdb"
