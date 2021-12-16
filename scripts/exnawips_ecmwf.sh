#!/bin/ksh
###################################################################
echo "----------------------------------------------------"
echo "exnawips - convert NCEP GRIB files into GEMPAK Grids"
echo "----------------------------------------------------"
echo "History: Mar 2000 - First implementation of this new script."
echo "S Lilly: May 2008 - add logic to make sure that all of the "
echo "                    data produced from the restricted ECMWF"
echo "                    data on the CCS is properly protected."
#####################################################################

set -xa

cd $DATA

msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

NAGRIB_TABLE=${GEMPAKecmwf:?}/fix/nagrib.tbl
NAGRIB=nagrib_nc

entry=`grep "^$RUN " $NAGRIB_TABLE | awk 'index($1,"#") != 1 {print $0}'`

if [ "$entry" != "" ] ; then
  cpyfil=`echo $entry  | awk 'BEGIN {FS="|"} {print $2}'`
  garea=`echo $entry   | awk 'BEGIN {FS="|"} {print $3}'`
  gbtbls=`echo $entry  | awk 'BEGIN {FS="|"} {print $4}'`
  maxgrd=`echo $entry  | awk 'BEGIN {FS="|"} {print $5}'`
  kxky=`echo $entry    | awk 'BEGIN {FS="|"} {print $6}'`
  grdarea=`echo $entry | awk 'BEGIN {FS="|"} {print $7}'`
  proj=`echo $entry    | awk 'BEGIN {FS="|"} {print $8}'`
  output=`echo $entry  | awk 'BEGIN {FS="|"} {print $9}'`
else
  cpyfil=gds
  garea=dset
  gbtbls=
  maxgrd=4999
  kxky=
  grdarea=
  proj=
  output=T
fi  
pdsext=no

maxtries=180
fhcnt=$fstart
while [ $fhcnt -le $fend ] ; do
  if [ $fhcnt -ge 100 ] ; then
    typeset -Z3 fhr
  else
    typeset -Z2 fhr
  fi
  fhr=$fhcnt
  fhcnt3=`expr $fhr % 3`

  fhr3=$fhcnt
  typeset -Z3 fhr3
  GRIBIN=$COMIN/${model}.${cycle}.${GRIB}${fhr}${EXT}
  GEMGRD=${RUN}_${PDY}${cyc}f${fhr3}

  case $RUN in
   ecmwf_glob | ecmwf_trop)  GRIBIN=$COMIN/${model}.${cycle}
          GEMGRD=${RUN}_${PDY}${cyc} ;;
   ecmwf_hr)
          GRIBIN=$DATA/${RUN}.t${cyc}z.pgrb${fhr}
          ;;
   ecmwf_wave)
          GRIBIN=$DATA/${RUN}.t${cyc}z.pgrb${fhr}
          ;;
  esac

  GRIBIN_chk=$GRIBIN

  icnt=1
  while [ $icnt -lt 1000 ]
  do
    if [ -r $GRIBIN_chk ] ; then
      break
    else
      let "icnt=icnt+1"
      sleep 20
    fi
    if [ $icnt -ge $maxtries ]
    then
      msg="ABORTING after 1 hour of waiting for F$fhr to end."
      err_exit $msg
    fi
  done

  cp $GRIBIN grib$fhr

  export pgm="nagrib_nc F$fhr"
  startmsg

  $NAGRIB << EOF
   GBFILE   = grib$fhr
   INDXFL   = 
   GDOUTF   = $GEMGRD
   PROJ     = $proj
   GRDAREA  = $grdarea
   KXKY     = $kxky
   MAXGRD   = $maxgrd
   CPYFIL   = $cpyfil
   GAREA    = $garea
   OUTPUT   = $output
   GBTBLS   = $gbtbls
   GBDIAG   = 
   PDSEXT   = $pdsext
  l
  r
EOF
  export err=$?;err_chk

  #####################################################
  # GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
  # WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
  # FOR THIS CASE HERE.
  #####################################################
  if [ $model != "ukmet_early" ] ; then
    ls -l $GEMGRD
    export err=$?;export pgm="GEMPAK CHECK FILE";err_chk
  fi

  if [ "$NAGRIB" = "nagrib2" ] ; then
    gpend
  fi

  if [ $SENDCOM = "YES" ] ; then
     if [ $RUN = "ecmwf_hr" -o $RUN = "ecmwf_wave" ] ; then
       chgrp rstprod $GEMGRD
       chmod 750 $GEMGRD
     fi
     mv $GEMGRD $COMOUT/$GEMGRD

     if [ $RUN = "ecmwf_hr" ]; then
       echo "ready" > $COMOUT/ecens.t${cyc}z.f${fhr}.ready
     fi

     if [ $SENDDBN = "YES" ] ; then
       $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
         $COMOUT/$GEMGRD
     else
       echo "##### DBN_ALERT_TYPE is: ${DBN_ALERT_TYPE} #####"
     fi
  fi

  if [ $fhcnt -eq 144 -a $RUN = "ecmwf_wave" ] ; then
      finc=6
  fi
  let fhcnt=fhcnt+finc
done

#####################################################################
# GOOD RUN
set +x
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
echo "**************JOB $RUN NAWIPS COMPLETED NORMALLY ON THE IBM"
set -x
#####################################################################

msg='Job completed normally.'
echo $msg
postmsg "$jlogfile" "$msg"

############################### END OF SCRIPT #######################
