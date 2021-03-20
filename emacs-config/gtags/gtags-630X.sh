#!/bin/bash

rm -f gtag_file_list

# ./sdk/apps
find ./sdk/apps \
     -path ./sdk/apps/hid        -prune -o \
     -path ./sdk/apps/mesh       -prune -o \
     -path ./sdk/apps/spp_and_le -prune -o \
     -type f -print >> gtag_file_list


find ./sdk/apps/spp_and_le \
     -path ./sdk/apps/spp_and_le/board -prune -o \
     -type f -print >> gtag_file_list

find ./sdk/apps/spp_and_le/board \
     -path ./sdk/apps/spp_and_le/board/bd19 -prune -o \
     -path ./sdk/apps/spp_and_le/board/bd29 -prune -o \
     -path ./sdk/apps/spp_and_le/board/br23 -prune -o \
     -path ./sdk/apps/spp_and_le/board/br30 -prune -o \
     -type f -print >> gtag_file_list

# ./sdk/cpu
find ./sdk/cpu/br25 \
     -path ./sdk/cpu/br25/tools/bluetooth/app_ota/AC696X_config_tool -prune -o \
     -path ./sdk/cpu/br25/tools/bluetooth/standard/AC696X_config_tool -prune -o \
     -type f -print >> gtag_file_list

# ./sdk/include_lib
find ./sdk/include_lib \
     -path ./sdk/include_lib/driver/cpu/bd19 -prune -o \
     -path ./sdk/include_lib/driver/cpu/bd29 -prune -o \
     -path ./sdk/include_lib/driver/cpu/br23 -prune -o \
     -path ./sdk/include_lib/driver/cpu/br30 -prune -o \
     -type f -print >> gtag_file_list


# gtags -f ./gtag_file_list

