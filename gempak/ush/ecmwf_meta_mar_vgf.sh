#! /bin/ksh
#
# Metafile Script : ecmwf_meta_mar_vgf.sh
#
# Log :
# J. Carr/PMB      12/11/2004     Pushed into production.
#
#
# Set up Local Variables
#
set -x
#
export PS4='OPC_MAR_VGF:$SECONDS + '
workdir="${DATA}/OPC_MAR_VGF"
mkdir ${workdir}
cd ${workdir}

sh ${utilscript}/setup.sh
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=ecmwf
MDL="ECMWF"
PDY2=`echo $PDY | cut -c3-`

export DBN_ALERT_TYPE=VGF
export DBN_ALERT_SUBTYPE=OPC

atl120sfc="ATL_${mdl}_120sfc_${PDY2}_${cyc}.vgf"
pac120sfc="PAC_${mdl}_120sfc_${PDY2}_${cyc}.vgf"
atl5120="ATL_500_${mdl}_${PDY2}_${cyc}_f120.vgf"
pac5120="PAC_500_${mdl}_${PDY2}_${cyc}_f120.vgf"

deva120sfc="vg|${atl120sfc}"
devp120sfc="vg|${pac120sfc}"
deva5120="vg|${atl5120}"
devp5120="vg|${pac5120}"

grid=${COMIN}/${mdl}_glob_${PDY}${cyc}

gdplot2_vg << EOFplt
gdfile	= ${grid}
gdattim	= f120
GLEVEL  = 500
GVCORD  = PRES
PANEL   = 0
SKIP    = 0/9;4
SCALE   = -1
GDPFUN  = hght!hght
TYPE    = c!c
CONTUR  = 7
CINT    = 6/-99/558!6/570/999
LINE    = 20/1/3/2/2/.13!20/1/3/2/2/.13
FINT    =
FLINE   =
HILO    = 2;6/H#;L#///5;5!0
HLSYM   = 3.7;2.5/2/22;31/3;3/hw!
CLRBAR  =
WIND    =
REFVEC  =
TITLE   =
TEXT    = 1.5/21/2.2/hw
CLEAR   = y
STNPLT  =
SATFIL  =
RADFIL  =
STREAM  =
POSN    = 4
COLORS  = 2
MARKER  = 2
GRDLBL  = 5
LUTFIL  = none
FILTER  = no
GAREA   = 17;-98;64;10
PROJ    = mer
MAP     = 0
LATLON  = 0
DEVICE  = ${deva5120}
STNPLT  =
li
ru

clear   = no
gdpfun  = hght
type    = c
cint    = 6/564/564
line    = 20/1/6/2/2/.13
hilo    =
hlsym   =
li
ru

clear   = yes
device  = ${devp5120}
garea   = 17;136;64;-116
GDPFUN  = hght!hght
TYPE    = c!c
CINT    = 6/-99/558!6/570/999
LINE    = 20/1/3/2/2/.13!20/1/3/2/2/.13
WIND    =
HILO    = 2;6/H#;L#///5;5!0
HLSYM   = 3.7;2.5/2/22;31/3;3/hw!
li
ru

clear   = no
gdpfun  = hght
type    = c
cint    = 6/564/564
line    = 20/1/6/2/2/.13
hilo    =
hlsym   =
li
ru

gdattim = f120
garea   = 17;-98;64;10
proj    = mer
latlon  =
map     = 0
clear   = yes
device  = ${deva120sfc}
glevel  = 0
gvcord  = none
panel   = 0
skip    = 0
scale   = 0
gdpfun  = pmsl
type    = c
contur  = 7
cint    = 4
line    = 5/1/3/-5/2/.13
fint    =
fline   =
!hilo    = 7;7/h#;l#
!hlsym   = 1//21/1/hw
hilo    =
hlsym   =
clrbar  = 0
wind    =
refvec  =
title   =
text    = 1.3/21/2/hw
li
ru

garea   = 17;136;64;-116
clear   = yes
device  = ${devp120sfc}
li
ru
exit
EOFplt

if [ $SENDCOM = "YES" ] ; then
    mv *.vgf ${COMOUT}
    if [ $SENDDBN = "YES" ] ; then
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/ATL_${mdl}_120sfc_${PDY2}_${cyc}.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/PAC_${mdl}_120sfc_${PDY2}_${cyc}.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/ATL_500_${mdl}_${PDY2}_${cyc}_f120.vgf
        ${DBNROOT}/bin/dbn_alert ${DBN_ALERT_TYPE} ${DBN_ALERT_SUBTYPE} $job ${COMOUT}/PAC_500_${mdl}_${PDY2}_${cyc}_f120.vgf
    fi
fi
exit
