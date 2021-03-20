#!/bin/bash

find ./linux-master/drivers/bluetooth ./linux-master/include/net/bluetooth ./linux-master/net/bluetooth -type f -print > gtag_file_list
find ./linux-master/drivers/hid -type f -print >> gtag_file_list
find ./linux-master/drivers/base -type f -print >> gtag_file_list
find ./linux-master/include -type f -print >> gtag_file_list
find ./linux-master/net/core ./linux-master/net/socket.c -type f -print >> gtag_file_list
find ./bluez-5.50 -type f -print >> gtag_file_list
find ./glib-master -type f -print >> gtag_file_list
find ./sbc -type f -print >> gtag_file_list
find ./dbus-1.13.6 -type f -print >> gtag_file_list
# gtags -f ./gtag_file_list
