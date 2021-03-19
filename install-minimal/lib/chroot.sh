#!/bin/bash

ln -s "/usr/share/zoneinfo/$region/$city" /etc/localtime
hwclock --systohc

## Uncomment desired language
sed -i "/${locale}/s/^#//" /etc/locale.gen

locale-gen

echo "LANG=$(printf $locale | sed 's/\s.*$//')" >/etc/locale.conf

echo $hostname >/etc/hostname

echo -e "127.0.0.1\t\tlocalhost\n::1\t\t\tlocalhost\n127.0.1.1\t\t${hostname}.localdomain ${hostname}" >>/etc/hosts

exit