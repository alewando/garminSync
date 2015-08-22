#!/bin/sh

# Syncs activities from Garmin Fenix2 to NAS
# Keeps .fit files and also converts to .tcx

echo `date` >> /tmp/garminSync.log

# Find where the Garmin is mounted
if [ -e "/Volumes/GARMIN/Garmin" ]; then
 DEVICE_MOUNT_DIR=/Volumes/GARMIN
fi
if [ -z "$DEVICE_MOUNT_DIR" ]; then
 echo Cant determine device mount dir!
 exit 1
fi
echo Device mounted at: $DEVICE_MOUNT_DIR

# Find the target data dir
if [ -e /Volumes/data/files/gps ]; then
 GPS_DIR=/Volumes/data/files/gps
fi
# if [ -z "$GPS_DIR" ]; then
#  if [ -e "/Volumes/whatever" ]; then
#   GPS_DIR="/Volumes/whatever"
#  fi
# fi
if [ -z "$GPS_DIR" ]; then
 echo Cant determine target data dir!
 exit 1
fi
echo Target dir: $GPS_DIR

ACTIVITY_DIR=${DEVICE_MOUNT_DIR}/Garmin/Activity
if [ ! -e "$ACTIVITY_DIR" ]; then
  echo Activity dir not present on GPS device
  exit 1
fi

FIT_DIR=${GPS_DIR}/fit
if [ ! -e "$FIT_DIR" ]; then
  echo $FIT_DIR dir does not exist
  exit 1
fi

TCX_DIR=${GPS_DIR}/tcx
if [ ! -e "$TCX_DIR" ]; then
  echo $TCX_DIR dir does not exist
  exit 1
fi

LOG=${GPS_DIR}/sync.log
echo `date` > $LOG

echo Syncing activities: >> $LOG
echo  From $ACTIVITY_DIR >> $LOG
echo    To ${GPS_DIR} >> $LOG
echo ============================================= >> $LOG

# Find all activities
find "$ACTIVITY_DIR" -iname "*.fit"| while read filename
do
 BASE=`basename "${filename}"`

 # Copy to .fit dir if needed
 if [ ! -e "$FIT_DIR/$BASE" ]; then
  echo Copying: ${BASE} >> $LOG
  echo Copying: ${BASE}
  cp -p "$filename" "$FIT_DIR"
 fi

 # Convert to tcx if needed
 TCX_FILE=`echo $BASE | sed s/'\.fit$/.tcx'/`
 if [ ! -e "${TCX_DIR}/${TCX_FILE}" ]; then
  echo Converting to ${TCX_DIR}/${TCX_FILE}
  echo Converting to ${TCX_DIR}/${TCX_FILE} >> $LOG
  /usr/local/bin/gpsbabel -i garmin_fit -o gtrnctr "${filename}" "${TCX_DIR}/${TCX_FILE}"
 fi
done


