#! /usr/bin/env bash
#
# usage: ./deploy.sh <hostname>.lafayette.edu

usage() {
  echo "usage: $0 <hostname>.lafayette.edu"
}

target_dir="/var/www/purefood/"

host=$1

if [ -z "$host" ]; then
  echo -e "No host provided!\n"
  usage && exit 1
fi

echo "checking to see if $target_dir exists..."
ssh $host stat $target_dir > /dev/null 2>&1

if [ $? -ne 0 ]; then
  cat <<-EOL
[error] looks like the target directory doesn't exist! try running:

  mkdir -p $target_dir

on $host (make sure you can write to it!) and try again.
EOL
  exit 1
fi

echo "generating fresh build"

bundle exec jekyll clean
bundle exec jekyll build --safe

echo "moving the contents to $host"

# -r       => recursive
# -a       => archive mode
# -v       => verbose
# -e ssh   => which shell to use
# --delete => delete extraneous files on the target server
#
# note to self: make sure the directories have a trailing slash
#               so that only the contents are copied and not the
#               directories themselves.
rsync -rav -e ssh --delete _site/ $host:$target_dir
