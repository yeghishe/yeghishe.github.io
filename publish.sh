#!/bin/bash

tmp_dir=/tmp/blog
user=$(whoami)
message="Site updated at $(date -u '+%Y-%m-%d %T') UTC"

docker run --rm -ti -v $(pwd):/src yeghishe/blog:latest /bin/sh -c \
    'jekyll build'

rm -rf $tmp_dir
mkdir $tmp_dir

sudo chown -R $user .
mv _site/* $tmp_dir
git checkout -B master
rm -rf *
mv $tmp_dir/* .
git add .
git commit -am $message
git push origin master --force
git checkout blog
echo yolo
