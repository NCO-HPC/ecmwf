#! /bin/ksh
#
# Metafile Script : ecmwf_meta_mar.sh
#
# Log :
# J. Carr/PMB     12/09/2004    Pushed into production
#
# Set up Local Variables
#
set -x
#
export PS4='MAR:$SECONDS + '
mkdir $DATA/MAR
cd $DATA/MAR
sh $utilscript/setup.sh
cp $FIXgempak/datatype.tbl datatype.tbl

mdl=ecmwf
MDL="ECMWF"
metatype="mar"
metaname="${mdl}_${PDY}_${cyc}_${metatype}"
device="nc | ${metaname}"
PDY2=`echo $PDY | cut -c3-`

grid=${COMIN}/${mdl}_glob_${PDY}${cyc}

gdplot2_nc << EOFplt
\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+mefbao.ncp
gdfile	= ${grid}
gdattim	= f00-f168
GAREA	= 15;-100;70;5
PROJ	= mer//3;3;0;1
MAP	= 31 + 6 + 3 + 5
LATLON	= 18/2/1/1/10
CONTUR	= 7
device	= $device 
GLEVEL	= 0
GVCORD	= none
PANEL	= 0
SKIP	= 0/2
SCALE	= 0
GDPFUN	= pmsl
TYPE	= c
CINT	= 4
LINE	= 19//2
FINT	= 
FLINE	= 
HILO	= 20/H#;L#
HLSYM	= 1;1//22;22/3;3/hw
CLRBAR	= 0
GVECT	= 
WIND	=
REFVEC	=
TITLE   = 5/-2/~ ? ECMWF PMSL|~ ATL PMSL!0
TEXT	= 1.2/22/2/hw
CLEAR	= YES
li
run

GAREA	= 13;-84;50;-38
PROJ	= str/90;-67;1
LATLON	= 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ECMWF PMSL|~ WATL PMSL !0
li
run

GAREA   = 15;-100;70;5
PROJ    = mer//3;3;0;1
LATLON  = 18/2/1/1/10
GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  
SCALE   = 5                  !-1
GDPFUN   = sm5s(avor)         !sm5s(hght)
TYPE   = c/f                !c
CINT    = 3/3/99             !6
LINE    = 7/5/1/2            !20/1/2/1
FINT    = 15;21;27;33;39;45;51;57
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!          !
HLSYM   = 
GVECT   = 0
WIND    = 0
TITLE   = 5/-2/~ ? ECMWF @ HEIGHTS & ABS VORTICITY|~ ATL 500mb HGHT & VORT!0
li
ru

GAREA   = 13;-84;50;-38
PROJ    = str/90;-67;1
LATLON  = 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ECMWF @ HEIGHTS & ABS VORTICITY|~ WATL 500mb HGHT & VORT!0
li
run


\$MAPFIL=mepowo.gsf+mehsuo.ncp+mereuo.ncp+himouo.nws
GAREA	= 4;120;69;-105
PROJ	= mer//3;3;0;1
LATLON	= 18/2/1/1/10
GLEVEL  = 0
GVCORD  = none
SKIP    = 0
SCALE   = 0
GDPFUN   = pmsl
TYPE   = c
CINT    = 4
LINE    = 19//2
FINT    = 
FLINE   = 
HILO    = 20/H#;L#/1020-1070;900-1012
HLSYM   = 1;1//22;22/3;3/hw
CLRBAR  = 0
WIND    = 
TITLE   = 5/-2/~ ? ECMWF PMSL|~ PAC PMSL!0
li
ru

GAREA   = 11;-135;75;-98
PROJ    = str/90;-100;1
LATLON  = 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ECMWF PMSL|~ EPAC PMSL!0
li
ru

GAREA   = 4;120;69;-105
PROJ    = mer//3;3;0;1
LATLON  = 18/2/1/1/10
GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  
SCALE   = 5                  !-1
GDPFUN   = sm5s(avor)         !sm5s(hght)
TYPE   = c/f                !c
CINT    = 3/3/99             !6
LINE    = 7/5/1/2            !20/1/2/1
FINT    = 15;21;27;33;39;45;51;57
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!          !
HLSYM   = 
WIND    = 0
TITLE   = 5/-2/~ ? ECMWF @ HEIGHTS & ABS VORTICITY|~ PAC 500mb HGHT & VORT!0
li
ru

GAREA   = 11;-135;75;-98
PROJ    = str/90;-100;1
LATLON  = 18/2/1/1/5;5
TITLE   = 5/-2/~ ? ECMWF @ HEIGHTS & ABS VORTICITY|~ EPAC 500mb HGHT & VORT!0
li
ru

exit
EOFplt

export err=$?;err_chk
#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l $metaname
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
   mv ${metaname} ${COMOUT}/${mdl}_${PDY}_${cyc}_mar
   if [ $SENDDBN = "YES" ] ; then
      ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job ${COMOUT}/${mdl}_${PDY}_${cyc}_mar
   fi
fi

exit
