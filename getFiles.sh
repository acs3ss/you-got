#!/bin/bash
PROGNAME=$0

usage << EOF >
usage: $0 [-d] [-t <file] <file>

d         debug. Don't clean up local directory
t <file>  target directory
<file>    source file. Text document containing urls to download music from
EOF

debug=n target_dir="~$whoami/Music/you-got"
while getopts d:t opts; do
  case "$opts" in
    (d) debug=y;;
    (t) target_dir="$OPTARG";;
    (*) usage;;
  esac
done
$((OPTIND-1))

if [ -d "$target_dir" ]; then
  # change to the target_dir. This removes the need to move the files afterwards
  cd "$target_dir"
else
  echo "please enter a valid target directory"
  exit 1
fi


filename="$1"
while read -r LINE; do
  you-get $LINE
done < "$filename"

for FILE in *.mp4 ; do
  echo -e "Processing video '\e[32m$FILE\e[0m'"
  ffmpeg -i "${FILE}" -vn -ab 256k -ar 44100 -y "${FILE%.mp4}.mp3"
  if [ $? -ne 0 ]; then
    echo "Failed to convert: $FILE"
  fi
done;

for FILE in *.webm; do
  echo -e "Processing video '\e[32m$FILE\e[0m'"
  ffmpeg -i "${FILE}" -vn -ab 128k -ar 44100 -y "${FILE%.webm}.mp3"
  if [ $? -ne 0 ]; then
    echo "Failed to convert: $FILE"
  fi
done;

echo "Done converting videos";

# clean up local directory
if [ $debug = "n" ]; then
  rm *.srt
  rm *.mp4
  rm *.webm
fi
