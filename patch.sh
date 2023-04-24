#!/bin/bash

# This disables operating-system level mitigations and page table isolation
copy ./grub-configs/patch-grub /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

echo "Please reboot your system"