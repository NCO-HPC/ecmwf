#!/bin/ksh
#
# Metafile Script : ecmwf_meta_mar_ver.sh
#
# Log :
# J. Carr/PMB     12/10/2004      Added into production.
#
# Set up Local Variables
set -x
#
export PS4='MAR_VER:$SECONDS + '
mkdir $DATA/MAR_VER
cd $DATA/MAR_VER
sh $utilscript/setup.sh
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=ecmwf
MDL="ECMWF"
metatype="mar_ver"
metaname="${mdl}_${PDY}_${cyc}_${metatype}"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`
#
#
# DEFINE YESTERDAY
date1=`${NDATE:?} -24 ${PDY}${cyc} | cut -c -8`
# DEFINE 2 CYCLES AGO
date2=`${NDATE:?} -48 ${PDY}${cyc} | cut -c -8`
# DEFINE 3 CYCLES AGO
date3=`${NDATE:?} -72 ${PDY}${cyc} | cut -c -8`
# DEFINE 4 CYCLES AGO
date4=`${NDATE:?} -96 ${PDY}${cyc} | cut -c -8`
# DEFINE 5 CYCLES AGO
date5=`${NDATE:?} -120 ${PDY}${cyc} | cut -c -8`
# DEFINE 6 CYCLES AGO
date6=`${NDATE:?} -144 ${PDY}${cyc} | cut -c -8`
# DEFINE 7 CYCLES AGO
date7=`${NDATE:?} -168 ${PDY}${cyc} | cut -c -8`

# SET CURRENT CYCLE AS THE VERIFICATION GRIDDED FILE.
vergrid="F-GDAS | ${PDY2}/0600"
vergrid="$COMIN/${mdl}_glob_${PDY}${cyc}"
echo vergrid is ${vergrid}
fcsthr="f000"

# SET WHAT RUNS TO COMPARE AGAINST BASED ON MODEL CYCLE TIME.
verdays="${date1} ${date2} ${date3} ${date4} ${date5} ${date6} ${date7}"

# GENERATING THE METAFILES.
for area in ATL PAC
do
    if [ ${area} = "ATL" ] ; then
        garea="15.0;-100.0;70.0;20.0"
    else
        garea="5.0;120.0;70.0;-105.0"
    fi
    for verday in ${verdays}
    do
	grid="/com/nawips/prod/${mdl}.${verday}/${mdl}_glob_${verday}${cyc}"
        if [ ${verday} = ${date1} ] ; then
            dgdattim=f024
            echo grid for number 1 is ${grid}
        elif [ ${verday} = ${date2} ] ; then
            dgdattim=f048
        elif [ ${verday} = ${date3} ] ; then
            dgdattim=f072
        elif [ ${verday} = ${date4} ] ; then
            dgdattim=f096
        elif [ ${verday} = ${date5} ] ; then
            dgdattim=f120
        elif [ ${verday} = ${date6} ] ; then
            dgdattim=f144
        elif [ ${verday} = ${date7} ] ; then
            dgdattim=f168
        fi

# 500 MB HEIGHT METAFILE
export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc << EOF
PROJ     = MER 
GAREA    = ${garea}
map      = 1//2
clear    = yes
text     = 1/22/////hw
contur   = 2
skip     = 0
type     = c
latlon   = 0 
device   = ${device}

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(hght)
glevel   = 500
gvcord   = pres
scale    = -1
cint     = 6
line     = 6/1/3
title    = 6/-2/~ ? ${MDL} 500 MB HGT (00-HR FCST)|~${area} 500 HGT DIFF
list
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? ECMWF 500 MB HGT
clear    = no
list
r

gdfile   = ${vergrid}
gdattim  = ${fcsthr}
gdpfun   = sm5s(pmsl)
glevel   = 0
gvcord   = none
scale    = 0
cint     = 4
line     = 6/1/3
contur   = 2
title    = 6/-2/~ ? ${MDL} PMSL (00-HR FCST)|~${area} PMSL DIFF
clear    = yes
list
r

gdfile   = ${grid}
gdattim  = ${dgdattim}
line     = 5/1/3
contur   = 4
title    = 5/-1/~ ? ECMWF PMSL
clear    = no
list
r

ex
EOF

export err=$?;err_chk

    done
done

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   mv ${metaname} ${COMOUT}/${mdl}_${PDY}_${cyc}_mar_ver
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${PDY}_${cyc}_mar_ver
   fi
fi

exit
