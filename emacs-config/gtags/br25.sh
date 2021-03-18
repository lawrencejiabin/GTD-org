#!/bin/bash

app="le"
# app="hid"
# app="mesh"

rm -f br25_ls

# ./sdk/apps
find ./sdk/apps \
     -path ./sdk/apps/hid        -prune -o \
     -path ./sdk/apps/mesh       -prune -o \
     -path ./sdk/apps/spp_and_le -prune -o \
     -type f -print >> br25_ls

#-------- spp_and_le ---------#
if [[ "$app" == "le" ]];then
echo "le"
find ./sdk/apps/spp_and_le \
     -path ./sdk/apps/spp_and_le/board -prune -o \
     -type f -print >> br25_ls

find ./sdk/apps/spp_and_le/board \
     -path ./sdk/apps/spp_and_le/board/bd19 -prune -o \
     -path ./sdk/apps/spp_and_le/board/bd29 -prune -o \
     -path ./sdk/apps/spp_and_le/board/br23 -prune -o \
     -path ./sdk/apps/spp_and_le/board/br30 -prune -o \
     -type f -print >> br25_ls
fi
#--------- hid ---------------#
if [[ "$app" == "hid" ]];then
echo "hid"
find ./sdk/apps/hid \
     -path ./sdk/apps/hid/board -prune -o \
     -type f -print >> br25_ls

find ./sdk/apps/hid/board \
     -path ./sdk/apps/hid/board/bd19 -prune -o \
     -path ./sdk/apps/hid/board/bd29 -prune -o \
     -path ./sdk/apps/hid/board/br23 -prune -o \
     -path ./sdk/apps/hid/board/br30 -prune -o \
     -type f -print >> br25_ls
fi
#--------- mesh ---------------#
if [[ "$app" == "mesh" ]];then
echo "mesh"
find ./sdk/apps/mesh \
     -path ./sdk/apps/mesh/board -prune -o \
     -type f -print >> br25_ls

find ./sdk/apps/mesh/board \
     -path ./sdk/apps/mesh/board/bd19 -prune -o \
     -path ./sdk/apps/mesh/board/bd29 -prune -o \
     -path ./sdk/apps/mesh/board/br23 -prune -o \
     -path ./sdk/apps/mesh/board/br30 -prune -o \
     -type f -print >> br25_ls
fi

# ./sdk/cpu
find ./sdk/cpu/br25 \
     -path ./sdk/cpu/br25/tools/bluetooth/app_ota/AC696X_config_tool -prune -o \
     -path ./sdk/cpu/br25/tools/bluetooth/standard/AC696X_config_tool -prune -o \
     -type f -print >> br25_ls

# ./sdk/include_lib
find ./sdk/include_lib \
     -path ./sdk/include_lib/driver/cpu/bd19 -prune -o \
     -path ./sdk/include_lib/driver/cpu/bd29 -prune -o \
     -path ./sdk/include_lib/driver/cpu/br23 -prune -o \
     -path ./sdk/include_lib/driver/cpu/br30 -prune -o \
     -type f -print >> br25_ls


# gtags -f ./br25_ls -v

