#!/bin/bash
PROGNAME=$0

usage(){
  cat << EOF
  usage: $0 [-d] [-f] [-t <file>] <file>

  -d             debug. Don't clean up local directory
  -t <file>      target directory
  -f             force files to target directory. Create directory if it does not exist
  <file>         source file. Text document containing urls to download music from
EOF
}

debug=n force=n target_dir="~$(whoami)/Music/you-got"
while getopts "dft:" o; do
  case $o in
    (d) debug=y;;
    (t) target_dir="$OPTARG";;
    (f) force=y;;
    (*) usage; exit 1;;
  esac
done
shift $((OPTIND-1))

if ! ffmpeg -h >/dev/null; then echo "Please download ffmpeg"; exit 1; fi
if ! you-get --version; then echo "Please download you-get"; exit 1; fi

if [ ! -d "$target_dir" ]; then
  if [ "$force" = y ]; then
    mkdir -p "$target_dir"
  else
    echo "please enter a valid target directory"
    exit 1
  fi
fi

filename="$1"
while read -r LINE; do
  # TODO make sure all urls are valid
  you-get -o "$target_dir" $LINE
done < "$filename"

for FILE in "$target_dir"/*.mp4 ; do
  echo -e "Processing video '\e[32m$FILE\e[0m'"
  ffmpeg -i "${FILE}" -vn -ab 256k -ar 44100 -y "${FILE%.mp4}.mp3"
  if [ $? -ne 0 ]; then
    echo "Failed to convert: $FILE"
  fi
done;

for FILE in "$target_dir"/*.webm; do
  echo -e "Processing video '\e[32m$FILE\e[0m'"
  ffmpeg -i "${FILE}" -vn -ab 128k -ar 44100 -y "${FILE%.webm}.mp3"
  if [ $? -ne 0 ]; then
    echo "Failed to convert: $FILE"
  fi
done;

echo "Done converting videos";


# check to make sure the number of files created is the same as the number of lines of the target file
num_requested="$(wc -l "$1")"
num_mp3="$(ls "$target_dir"/.mp3 | wc -l)"
num_mp4="$(ls "$target_dir"/.mp4 | wc -l)"

if [ "$num_requested" == "$num_mp3" ]; then
  echo "Transfer of $num_requested files successful!"
else
  echo "There may have been an error during retrieval or conversion"
  echo "Number of files requested: $num_requested"
  echo "Number of mp4 files retrieved: $num_mp4"
  echo "Number of mp3 files converted: $num_mp3"
fi

# clean up local directory
if [ $debug = "n" ]; then
  cd "$target_dir"
  rm *.srt
  rm *.mp4
  rm *.webm
fi
