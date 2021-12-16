#!/bin/ksh
######################################################################
#  UTILITY SCRIPT NAME :  execmwf_awips.sh
#         DATE WRITTEN :  05/30/2007
#
#  Abstract:  This utility script creates grid 232 in grib2 format for 
#             AWIPS from  ECMWF products.
#
#####################################################################
echo "------------------------------------------------"
echo "JECMWF_AWIPS ( 00Z AND 12Z) ECMWF postprocessing"
echo "------------------------------------------------"
echo "History: MAY 2007 - First implementation of this new script."
echo " "
#####################################################################

cd $DATA

set -xa
msg="Begin job for $job"
postmsg "$jlogfile" "$msg"

fhrcnt=0
refdate=`echo ${PDY}${cyc}| cut -c5-`
while [ $fhrcnt -le $fend ] ; do
  if [ $fhrcnt -ge 100 ] ; then
    typeset -Z3 fhr
  else
    typeset -Z2 fhr
  fi
  fhr=$fhrcnt
  fcst_date=`$NDATE $fhrcnt ${PDY}${cyc}|cut -c5-`
  
  icnt=1
  while [ $icnt -le 300 ]
  do
    if [ -s $COMIN_GRBCHK/ecens.t${cyc}z.f${fhr}.ready ]; then
      break
    else
      icnt=`expr $icnt + 1`
      sleep 10
    fi
    if [ icnt -gt 300 ]; then
      echo "WAITING for ECMWF data for 30 minutes, check if all" $COMIN/DCD* " available in /dcom!"
      export err=9
      err_chk
    fi
  done

  ln -sf $DCOMIN/DCD${refdate}00${fcst_date}00${ECMWF_FILE_EXT} $DATA/ecmwf_awips.${cycle}.${GRIB}${fhr}
  file=$DATA/ecmwf_awips.${cycle}.${GRIB}${fhr}
  $WGRIB $file | grep -F -f $PARMecmwf/params.ecmwf | $WGRIB -i -grib -o $file.cut $file > null
  echo '&NLCOPYGB IDS(228)=5, /' > precip_conversion_factor
  $COPYGB -N precip_conversion_factor -g232 -x $file.cut $file.cut.232
  $CNVGRIB -g12 -p40 -nv $file.cut.232 $file.grib2

  # Processing AWIPS ECMWF grid 232

  pgm=tocgrib2
  export pgm;. prep_step
  startmsg

  export FORT11=$file.grib2
  export FORT31=" "
  export FORT51=grib2.${cycle}.awpecmwf${fhr}.232

  $TOCGRIB2 <  $PARMecmwf/grib2_awp_ecmwf${fhr}.232 >> $pgmout 2> errfile

  err=$?;export err ;err_chk
  echo " error from tocgrib=",$err

  if [ $SENDCOM = "YES" ] ; then
     mv grib2.${cycle}.awpecmwf${fhr}.232  $pcom
     chgrp rstprod $pcom/grib2.${cycle}.awpecmwf${fhr}.232
     chmod 750 $pcom/grib2.${cycle}.awpecmwf${fhr}.232 
  fi

  if [ $SENDDBN = "YES" ] ; then
     $DBNROOT/bin/dbn_alert NTC_LOW ecmwf $job $pcom/grib2.${cycle}.awpecmwf${fhr}.232
  fi
  let fhrcnt=fhrcnt+finc

done

msg='ENDED NORMALLY.'
postmsg "$jlogfile" "$msg"

################## END OF SCRIPT #######################
