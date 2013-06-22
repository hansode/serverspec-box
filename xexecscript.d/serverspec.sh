#!/bin/bash
#
# requires:
#  bash
#  chroot
#
set -x
set -e

echo "doing execscript.sh: $1"

chroot $1 $SHELL <<EOS
  gem install serverspec --no-rdoc --no-ri
EOS
