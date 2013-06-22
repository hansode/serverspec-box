#!/bin/bash
#
# requires:
#  bash
#  chroot
#
set -x
set -e

echo "doing execscript.sh: $1"

## root

chroot $1 $SHELL <<'EOS'
  rpm -Uvh http://dlc.wakame.axsh.jp.s3-website-us-east-1.amazonaws.com/epel-release
  yum install -y libyaml-devel
EOS

## normal user

chroot $1 su - ${devel_user} <<'EOS'
  whoami

  git clone https://github.com/hansode/ruby-2.0.0-rpm.git /tmp/ruby-2.0.0-rpm
  rubyminorver=$(egrep "^%define rubyminorver" /tmp/ruby-2.0.0-rpm/ruby200.spec | awk '{print $3}')

  cd
  rpmdev-setuptree

  cp -f /tmp/ruby-2.0.0-rpm/ruby200.spec ~/rpmbuild/SPECS/ruby200.spec

  cd ~/rpmbuild/SOURCES; pwd
  wget http://ftp.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-${rubyminorver}.tar.gz

  rpmbuild -bb ~/rpmbuild/SPECS/ruby200.spec
EOS

## root

chroot $1 $SHELL <<EOS
  rpm -ivh /home/${devel_user}/rpmbuild/RPMS/*/ruby-2.0.0p*.rpm
  gem install bundler --no-rdoc --no-ri
EOS
