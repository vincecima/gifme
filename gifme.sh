#!/usr/bin/env bash

# set up vars
input_file=
output_file="output_gif.gif"

start_time="00:00:00"
duration="5"
width="-1"
fps="15"
verbosity="-loglevel panic"
dither=

usage(){
  echo "usage: gifme [-s start time ] [-d duration ] [ -w width ]
  [ -f frames per second ] [ -b bayer scale filter] [INPUT FILE] [OUTPUT FILE]

  Cut a video file and output a gif. The only required argument is the input
  file argument.

  Positional arguments:
    INPUT FILE              A video file of (nearly) any format with extension
                            included.

    OUTPUT FILE             A .gif file to be written to disk. Defaults to
                            'output_gif.gif'. Optional.

  Optional arguments:
    -h HELP                 Shows this message.

    -s START TIME           Timecode to start gif. Uses format HH:MM:SS and can
                            accept fractional seconds. Defaults to 00:00:00.

    -d DURATION             Duration of gif in seconds or format HH:MM:SS.
                            Can accept fractional seconds. Defaults to 5.

    -w WIDTH                A number, in pixels, representing desired width of
                            output gif. Maintains aspect ratio. Defaults to -1
                            which is how ffmpeg represents maximum width.

    -f FRAMES PER SECOND    A number 1-30 representing desired gif frames per
                            second. Defaults to 15.

    -b BAYER SCALE          A number 1-3 representing desired Bayer Scale dithering
                            filter. The Bayer Scale is responsible for the
                            'cross-hatch' overlay. A larger cross-hatch may
                            speed up rendering and reduce filesize. Defaults to
                            none. 1 is the smallest cross-hatch, 3 is the
                            largest.

    -o DITHERING OFF        Turns off dithering. Do not use this option with -b
                            or the results may be unexpected.

    "


}

# process flags before positional
while getopts "s:d:w:f:b:oh" opt; do
  case $opt in
    # start time (takes HH:MM:SS)
    s)
      start_time=$OPTARG
      ;;
    # change duration (takes seconds or HH:MM:SS)
    d)
      duration=$OPTARG
      ;;
    # change width (height stays same)
    w)
      width=$OPTARG
      ;;
    # change frames per second
    f)
      fps=$OPTARG
      ;;
    # bayer scale controls "cross hatching". Choose 1, 2 or 3
    b)
      dither="=dither=bayer:bayer_scale="$OPTARG
      ;;
    o)
      dither="=dither=none"
      ;;
    h)
      usage
      exit
      ;;
  esac
done

echo "start time = "$start_time
echo "duration = "$duration
echo "width = "$width
echo "frames per second = "$fps
echo "dither"$dither

# set index for positionals
# positions come after OPTIND
index=$(($OPTIND))
# get argument value
arg="${!index}"

echo "arg = "$arg
# exit if there's no arg
if [ -z "$arg" ];then
echo "Please supply an input file and an optional output file"
exit 1
fi

# otherwise set the vars
input_file="$arg"

# get second index
index2="$(($OPTIND + 1))"
# get second index value
arg2="${!index2}"

# if there's a second arg, change default name
if [ $arg2 ];then
output_file=$arg2
fi

remove_palette(){
if [ -f temp_palette.png ];then
  rm temp_palette.png
fi
}

palette="temp_palette.png"
filters="fps=$fps,scale=$width:-1:flags=lanczos"


# http://blog.pkh.me/p/21-high-quality-gif-with-ffmpeg.html#usage

# create global color palette
ffmpeg $verbosity -ss $start_time -t $duration -i $input_file -r $fps -vf "$filters,palettegen" -y $palette

ffmpeg $verbosity -ss $start_time -t $duration -i $input_file -i $palette -r $fps -lavfi "$filters [x]; [x][1:v] paletteuse$dither" -y $output_file

echo "Created "$output_file" from "$input_file

remove_palette

exit 0
