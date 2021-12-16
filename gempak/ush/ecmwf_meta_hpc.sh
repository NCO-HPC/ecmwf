#!/bin/ksh
#
# Metafile Script : ecmwf_meta_hpc
#
# Script creates ecmwf meta files for: pmsl & 1000-500 mb thicknes,
# 500 mb hgts & vort, 850 mb temps, and 500 mb hgt and 24 hr hgt falls.
#
# Log :
# J. Carr/HPC     1/98   Added new metafile
# J. Carr/HPC     5/98   Converted to gdplot2
# J. Carr/HPC     8/98   Changed map to medium resolution
# J. Carr/HPC     2/99   Changed skip to 0
# J. Carr/HPC     6/99   Added latlon and a filter to map
# J. Carr/HPC     7/99   Added South American area.
# J. Carr/HPC   2/2001   Edited to run on the IBM.
# J. Carr/HPC   5/2001   Added a mn variable for a/b side dbnet root variable.
# J. Carr/HPC   6/2002   Added ? for day of week in title line.
# M. Klein/HPC  2/2005   Changed location of working directory to /ptmp
# M. Klein/HPC 11/2006   Modify to run in production.

cd $DATA

echo " start with ecmwf_meta_hpc.sh"
set -xa

export pgm=gdplot2_nc;. prep_step; startmsg

device="nc | ecmwf_hpc_${cyc}.meta"
PDY2=`echo ${PDY} | cut -c3-`

#
# Copy in datatype table to define gdfile type
#
cp $FIXgempak/datatype.tbl datatype.tbl
#

#grid1="F-ECMWFG | ${PDY2}/${cyc}00"
grid1=${COMIN}/ecmwf_glob_${PDY}${cyc}

gdplot2_nc << EOF
\$MAPFIL = mepowo.gsf
GDFILE	= ${grid1}
GDATTIM	= F00-F168
DEVICE	= ${device}
PANEL	= 0
TEXT	= 1/21//hw
CONTUR	= 7
MAP	= 1/1/1/yes
CLEAR	= yes
CLRBAR  = 1
GAREA   = 17.529;-129.296;53.771;-22.374
PROJ    = str/90;-105;0
LATLON  = 18/2

GLEVEL  = 500!500!0
GVCORD  = pres!pres!none
SKIP    = 0 
SCALE   = -1!-1!0
GDPFUN  = sub(hght,mul(8.0,sub(pmsl@0%none,1000)))//x!x!pmsl
TYPE    = c
CINT    = 6/0/540 ! 6/546/999        ! 4
LINE    = 6/3/2   ! 2/3/2            ! 20//3
FINT    =
FLINE   =
HILO    = !! 26;2/H#;L#///30;30/y
HLSYM   = 2;1.5//21//hw
CLRBAR  = 1
WIND    = !         !                !                !Bk18//1
REFVEC  =
TITLE   = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~MSLP,EST 1000-500 THKN!0
ru

GLEVEL  = 500
GVCORD  = PRES
SKIP    = 0                  !0          !0
SCALE   = 5                  !5          !-1
GDPFUN  = abs(avor(geo))//v  !v          !hght
TYPE    = c/f                !c          !c
CINT    = 2/10/20            !2/4/8      !6
LINE    = 7/5/1/2            !29/5/1/2   ! 5/1/2/1
FINT    = 16;20;24;28;32;36;40;44
FLINE   = 0;23-15
HILO    = 2;6/X;N/10-99;10-99!           !
HLSYM   =
CLRBAR  = 1
WIND    =
REFVEC  =
TITLE	= 1/-2/~ ? ECMWF HGHTS, GEO ABS VORTICITY|~@ HGHT, GEO AVOR!0
ru

GLEVEL  = 850
GVCORD  = pres
GDPFUN  = (tmpc)!(tmpc)!(tmpc)
TYPE    = c/f       !c         !c 
CINT    = 3/-99/0   !3/3/18    !3/21/99
LINE    = 27/1/2    !2/1/2     !16/1/2
TITLE   = 1/-2/~ ? ECMWF 850 MB TEMPERATURES|~850 MB TEMPS!0
SCALE   = 999
WIND    =
HILO    =
HLSYM   =
CLRBAR  = 1/v/ll
SKIP    = 0
FINT    = -24;-18;-12;-6;0;18
FLINE   = 24;30;28;29;25;0;17
r

GDATTIM  = f24
GLEVEL   = 500
GVCORD   = pres
PANEL    = 0
SKIP     = 0
SCALE    = -1!0!0!-1
GDPFUN   = (hght)!(sub(hght^f24,hght^f00))!(sub(hght^f24,hght^f00))!(hght)
TYPE     = c!c/f!c/f!c
CONTUR   = 2
CINT     = 6    !20/20   !20/-240/-20 !6
LINE     = 5/1/3!32/1/1/1!1/10/2/1    !5/1/3
FINT     = 0!20;60;100;140;180;220!-220;-180;-140;-100;-60;-20
FLINE    = 0!0;24;25;30;29;28;27!11;12;2;10;15;14;0
HILO     = 0!0!0!5/H#;L#
HLSYM    = 0!!1.0//21//hw!1.5
CLRBAR   = 0!0!1!0
WIND     = 
REFVEC   = 
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0
TEXT     = 1/21////hw
CLEAR    = YES
l
run

GDATTIM  = f48
GDPFUN   = (hght)!(sub(hght^f48,hght^f24))!(sub(hght^f48,hght^f24))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0 
l
run 

GDATTIM  = f72
GDPFUN   = (hght)!(sub(hght^f72,hght^f48))!(sub(hght^f72,hght^f48))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0 
l
run

GDATTIM  = f96
GDPFUN   = (hght)!(sub(hght^f96,hght^f72))!(sub(hght^f96,hght^f72))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0 
l
run

GDATTIM  = f120
GDPFUN   = (hght)!(sub(hght^f120,hght^f96))!(sub(hght^f120,hght^f96))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0
l
run

GDATTIM  = f144
GDPFUN   = (hght)!(sub(hght^f144,hght^f120))!(sub(hght^f144,hght^f120))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0
l
run

GDATTIM  = f168
GDPFUN   = (hght)!(sub(hght^f168,hght^f144))!(sub(hght^f168,hght^f144))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 HGT CHG!1/-2/~ 24-HR HGT FALLS!0
l
run

! DO SOUTH AMERICAN AREA.

\$MAPFIL = mepowo.gsf
MAP	 = 1/1/1/yes
PROJ     = mer//3;3;0;1
GAREA    = -66;-127;14.5;-19
LATLON	 = 1//1/1/10

GDATTIM  = f24
GLEVEL   = 500
GVCORD   = pres
PANEL    = 0
SKIP     = 0
SCALE    = -1!0!0!-1
GDPFUN   = (hght)!(sub(hght^f24,hght^f00))!(sub(hght^f24,hght^f00))!(hght)
TYPE     = c!c/f!c/f!c
CONTUR   = 2
CINT     = 6    !20/20   !20/-240/-20 !6
LINE     = 5/1/3!32/1/1/1!1/10/2/1    !5/1/3
FINT     = 0!20;40;80;120;160;200;240!-240;-200;-160;-120;-80;-40;-20
FLINE    = 0!0;23;24;25;30;29;28;27  !11;12;2;10;15;14;13;0
HILO     = 0!0!0!5/H#;L#
HLSYM    = 0!!1.0//21//hw!1.5
CLRBAR   = 0!0!1!0
WIND     = 
REFVEC   = 
TITLE    = 1/-1/~ ?  ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0
TEXT     = 1/21////hw
CLEAR    = YES
l
run

GDATTIM  = f48
GDPFUN   = (hght)!(sub(hght^f48,hght^f24))!(sub(hght^f48,hght^f24))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0 
l
run 

GDATTIM  = f72
GDPFUN   = (hght)!(sub(hght^f72,hght^f48))!(sub(hght^f72,hght^f48))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0 
l
run

GDATTIM  = f96
GDPFUN   = (hght)!(sub(hght^f96,hght^f72))!(sub(hght^f96,hght^f72))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0 
l
run

GDATTIM  = f120
GDPFUN   = (hght)!(sub(hght^f120,hght^f96))!(sub(hght^f120,hght^f96))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0
l
run

GDATTIM  = f144
GDPFUN   = (hght)!(sub(hght^f144,hght^f120))!(sub(hght^f144,hght^f120))!(hght)
TITLE    = 1/-1/~ ? ECMWF @ HGT|~500 SA HGT CHG!1/-2/~ SA HGT FALLS!0
l
run

exit
EOF

export err=$?;err_chk

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
#ls -l ecmwf_hpc_${cyc}.meta
#export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
    mv ecmwf_hpc_${cyc}.meta ${COMOUT}/ecmwf_${PDY}_${cyc}_hpc
    if [ $SENDDBN = "YES" ] ; then
        ${DBNROOT}/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
        ${COMOUT}/ecmwf_${PDY}_${cyc}_hpc
    fi
fi

exit
