#!/bin/sh

YYMMDD=`date +"%y%m%d"`
#scrip_file_name=northamericax4v1pg2_scrip.nc
#hgrid_name=northamericax4v1pg2

scrip_filename=
scrip_filepath=
hgrid_name=
verbose=0

##################################################
# The command line help
##################################################
display_help() {
    echo "Usage: $0 " >&2
    echo
    echo "   -hgrid_name     <name>             The hgrid name (e.g. northamericax4v1pg2)"
    echo "   -scrip_filename <netcdf_filename>  The SCRIP filename (e.g. northamericax4v1pg2_scrip.nc)"
    echo "   -scrip_filepath <path>             The path to SCRIP file (e.g. /global/cfs/cdirs/e3sm/inputdata on NERSC"
    echo "   -v, --verbose                      Set verbosity option true"
    echo
    echo "Example: "
    echo "   ./create_mapping_scripts.sh                  \\"
    echo "   -hgrid_name northamericax4v1pg2              \\"
    echo "   -scrip_filename northamericax4v1pg2_scrip.nc \\"
    echo "   -scrip_filepath ~/data"
    echo
    exit 1
}


##################################################
# Get command line arguments
##################################################
while [ $# -gt 0 ]
do
  case "$1" in
    -hgrid_name )    hgrid_name="$2"; shift ;;
    -scrip_filename) scrip_filename="$2"; shift ;;
    -scrip_filepath)   scrip_filepath="$2"; shift ;;
    -v | --verbose)  verbose=1;;
    -*)
      echo "Unknown option: $1"
      display_help
      exit 0
      ;;
    -h | --help)
      display_help
      exit 0
      ;;
    *)  break;;	# terminate while loop
  esac
  shift
done

if [ $verbose -eq 1 ]
then
  echo "Verbosity: On"
  echo " "
fi

if [ -z $hgrid_name ]
then
  echo "hgrid_name is not specified"
  display_help
  exit 0
fi

if [ -z $scrip_filename ]
then
  echo "scrip_filename is not specified"
  display_help
  exit 0
else
  if [ ! -f "$scrip_filepath/$scrip_filename" ]
  then
    echo "$scrip_filepath/$scrip_filename does not exist"
    exit 0
  fi
fi

rm -rf $hgrid_name
mkdir -p $hgrid_name
echo "Creating batch scripts:"
for filename in map_*run; do
  echo "  $hgrid_name/$hgrid_name.$filename"
  cp $filename $hgrid_name/$hgrid_name.$filename
  sed -i "s/YYMMDD/${YYMMDD}/g"                  ${hgrid_name}/${hgrid_name}.$filename
  sed -i "s/SCRIP_FILE_NAME/${scrip_filename}/g" ${hgrid_name}/${hgrid_name}.$filename
  sed -i "s#SCRIP_FILE_PATH#${scrip_filepath}#g" ${hgrid_name}/${hgrid_name}.$filename
  sed -i "s/HGRID_NAME/${hgrid_name}/g"          ${hgrid_name}/${hgrid_name}.$filename
done


