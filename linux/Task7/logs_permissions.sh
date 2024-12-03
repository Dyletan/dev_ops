#!/bin/bash

DIR="/home/logs"
USER="executor"

#Для текущих файлов директории
setfacl -m u:$USER:rwX $DIR

#Для будущих файлов, ставит правило АСЛ по дефолту, добавляемые файлы будут уже с нужными правами
setfacl -d -m u:$USER:rwX $DIR

echo "Check the acl rules:"
getfacl $DIR