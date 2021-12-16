#!/bin/ksh

#
# Metafile Script : ecmwf_meta_all
#
# Log :
# D.W.Plummer/NCEP   3/97   Add log header
# D.W.Plummer/NCEP   3/97   Add southern hemisphere sector
# D.W.Plummer/NCEP   3/97   Changed GDATTIM=ALL to GDATTIM=F00-F144
# D.W.Plummer/NCEP   3/97   Added HGHT72 at F240
# D.W.Plummer/NCEP   3/97   Added $MAPFIL definitions
# D.W.Plummer/NCEP   7/97   Added tropical strip for mass fields
# J. Carr/HPC        1/98   Added a North Pacific area
# J. Carr/HPC        1/98   Added a Tropical Atlantic area
# J. Carr/HPC        2/99   Changed skip to 0
# B. Gordon/NCO      4/00   Converted for production on IBM-SP
#                           and changed gdplot_nc -> gdplot2_nc
# J. Carr/PMB       11/04   Extended time out to 168 to reflect all model data.
#                           Inserted a ? into all title/TITLE lines.
#                           Changed contur parameter to a 2.
#
cd $DATA

set -x
postmsg "$jlogfile" "Begin job for $job"

device="nc | ecmwf.nmeta"

grid1=${COMIN}/ecmwf_glob_${PDY}${cyc}
grid2=${COMIN}/ecmwf_trop_${PDY}${cyc}

export pgm=gdplot2_nc;. prep_step; startmsg

gdplot2_nc << EOF
GDFILE	= ${grid1}
GDATTIM	= F00-F168
DEVICE	= ${device}
PANEL	= 0
TEXT	= 1/21//hw
CONTUR	= 2
MAP     = 1
CLEAR	= yes
CLRBAR  = 1
GAREA   = 0;-130;0;50
PROJ    = str/90;-85;0
LATLON  = 18/1/1/1/15;15

restore ${USHrestore}/restore/pmsl_ethkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE   = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~NH MSLP,EST 1000-500 THKN!0
l
ru

restore ${USHrestore}/restore/500mb_hght_gabsv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 1/-2/~ ? ECMWF @ HGT, GEO ABS VORTICITY|~NH @ HGT, GEO AVOR!
l
ru

GLEVEL	= 700
l

GAREA   = 0;-135;0;45
PROJ    = str/-90;0;0

restore ${USHrestore}/restore/pmsl_ethkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE   = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~SH MSLP,EST 1000-500 THKN!0
l
ru

restore ${USHrestore}/restore/500mb_hght_gabsv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 1/-2/~ ? ECMWF @ HGT, GEO ABS VORTICITY|~SH @ HGT, GEO AVOR!
l
ru

GLEVEL	= 700
l

PROJ    = mer//3;3;0;1
GAREA   = -66;-127;14.5;-19
LATLON  = 1//1/1/10

restore ${USHrestore}/restore/pmsl_ethkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE   = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~SA MSLP,EST 1000-500 THKN!0
l
ru

restore ${USHrestore}/restore/500mb_hght_gabsv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE	= 1/-2/~ ? ECMWF @ HGT, GEO ABS VORTICITY|~SA @ HGT, GEO AVOR!
l
ru

restore ${USHrestore}/restore/garea_us.nts
GAREA   = 17.529;-129.296;53.771;-22.374
PROJ    = str/90;-105;0
LATLON  = 0

restore ${USHrestore}/restore/pmsl_ethkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~US MSLP,EST 1000-500 THKN!0
l
ru

restore ${USHrestore}/restore/500mb_hght_gabsv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE = 1/-2/~ ? ECMWF @ HGT, GEO ABS VORTICITY|~US @ HGT, GEO AVOR!
l
ru

restore ${USHrestore}/restore/pmsl_ethkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE = 1/-2/~ ? ECMWF PMSL, EST 1000-500 MB THKN|~NPAC MSLP,EST 1000-500 THKN!0
MAP   = 1//2
GAREA = 4;120;69;-115
PROJ  = mer//3;3;0;1
LATLON= 18//1/1/10
l
ru

restore ${USHrestore}/restore/500mb_hght_gabsv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
TITLE = 1/-2/~ ? ECMWF @ HGT, GEO ABS VORTICITY|~NPAC @ HGHT, GEO AVOR!
l
ru

GDATTIM = F240

GAREA   = 0;-130;0;50
PROJ    = str/90;-85;0
LATLON  = 18/1/1/1/15;15

GDPFUN  = HGHT72
GLEVEL	= 700
SCALE   = -1
CINT    = 6
TYPE    = c
LINE    = 5/1/2/1
TITLE   = 1/-2/~ ? ECMWF @ HGHT72|~NH @ HGHT72! 0
l
ru

GLEVEL	= 500
l
ru

GAREA   = 0;-135;0;45
PROJ    = str/-90;0;0

GDPFUN  = HGHT72
GLEVEL	= 700
SCALE   = -1
CINT    = 6
LINE    = 5/1/2/1
TITLE   = 1/-2/~ ? ECMWF @ HGHT72|~SH @ HGHT72! 0
l
ru

GLEVEL	= 500
l
ru

PROJ    = mer
GAREA   = -60;-120;20;-20
LATLON  = 18/1/1/1/10;10

GDPFUN  = HGHT72
GLEVEL	= 700
SCALE   = -1
CINT    = 6
LINE    = 5/1/2/1
TITLE   = 1/-2/~ ? ECMWF @ HGHT72|~SA @ HGHT72! 0
l

GLEVEL	= 500
l

restore ${USHrestore}/restore/garea_us.nts
GAREA   = 17.529;-129.296;53.771;-22.374
PROJ    = str/90;-105;0
LATLON  = 0

GDPFUN  = HGHT72
GLEVEL	= 700
SCALE   = -1
CINT    = 6
LINE    = 5/1/2/1
TITLE   = 1/-2/~ ? ECMWF @ HGHT72|~US @ HGHT72! 0
l
 
GLEVEL	= 500
l
 
GDATTIM	= F00-F168
GDFILE	= ${grid2}
CLRBAR  = 1/h/uc/0.5;0.95//-1

GAREA   = -50;0;50;180                              
PROJ    = mer                                      
MAP     = 1                                       
LATLON  = 1/1//1;1/30;30                         

GLEVEL  = 850                    
GVCORD  = PRES                  
SKIP    = 0/1;1              !/3
SCALE   = 0                   
GDPFUN  = knts((mag(wnd)))   !kntv(wnd)
TYPE    = c/f                !b
CINT    = 30;50;70;90;110;130;150                      
LINE    = 27/5/2/1                                    
FINT    = 70;90;110;130;150                          
FLINE   = 0;25;24;29;7;15                           
HILO    =                                          
HLSYM   =                                         
WIND    = 18//1                              
REFVEC  =                                      
TITLE   = 1/-2/~ ? ECMWF @ ISOTACHS AND WIND (KTS)|~@ TROP WIND (90E)! 
TEXT    = 1/21//hw                                                     
CLEAR   = yes                                                         
PANEL   = 0                                                                       
FILTER  = no
l
ru

GLEVEL  = 200 
GVCORD  = PRES                       
SKIP    = 0/1;1                   !/3
GDPFUN  = knts((mag(wnd)))        !kntv(wnd)
TYPE    = c/f                     !b
CINT    = 30;50;70;90;110;130;150         
LINE    = 27/5/2/1                       
FINT    = 70;90;110;130;150             
FLINE   = 0;25;24;29;7;15              
TITLE   = 1/-2/~ ? ECMWF @ ISOTACHS AND WIND (KTS)|~@ TROP WIND (90E)!
FILTER  = no
l
ru

GDFILE	= ${grid1}

restore ${USHrestore}/restore/pmsl_thkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE   = 1/-2/~ ? ECMWF MSLP, 1000-500 MB THICKNESS|~MSLP, 1000-500 THKN (90E)!0
l
ru

restore ${USHrestore}/restore/500mb_hght_absv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GDPFUN  = avor !avor !hght   
TITLE   = 1/-2/~ ? ECMWF @ HGT AND ABS VORTICITY|~@ HGT AND AVOR (90E)!0
l
ru

GDFILE	= ${grid2}
GAREA   = -50;-180;50;0                                              
PROJ    = mer                                                       
MAP     = 1                                                        
LATLON  = 1/1//1;1/30;30                                          

GLEVEL  = 850                                                    
GVCORD  = PRES                                                  
SKIP    = 1/2                  !/3                                                  
SCALE   = 0                                                   
GDPFUN  = knts((mag(wnd)))     !kntv(wnd)
TYPE    = c/f                  !b
CINT    = 30;50;70;90;110;130;150                         
LINE    = 27/5/2/1                                       
FINT    = 70;90;110;130;150                             
FLINE   = 0;25;24;29;7;15                              
HILO    =                                             
HLSYM   =                                            
WIND    = 18//1                                 
REFVEC  =                                         
TITLE   = 1/-2/~ ? ECMWF @ ISOTACHS AND WIND (KTS)|~@ TROP WIND (90W)! 
TEXT    = 1/21//hw                                                     
CLEAR   = yes                                                         
PANEL   = 0                                                                       
FILTER  = no
l
ru

GLEVEL  = 200                                                        
GVCORD  = PRES                                                      
SKIP    = 0/1;1             !/3
GDPFUN  = knts(mag(wnd))    !kntv(wnd)
TYPE    = c/f               !b
CINT    = 30;50;70;90;110;130;150                             
LINE    = 27/5/2/1                                           
FINT    = 70;90;110;130;150                                 
FLINE   = 0;25;24;29;7;15                                 
TITLE   = 1/-2/~ ? ECMWF @ ISOTACHS AND WIND (KTS)|~@ TROP WIND (90W)! 
FILTER  = no
l
ru

GDFILE	= ${grid1}

restore ${USHrestore}/restore/pmsl_thkn.2.nts
CLRBAR  = 1
HLSYM   = 2;1.5//21//hw
TEXT    = 1/21//hw
TITLE   = 1/-2/~ ? ECMWF MSLP, 1000-500 MB THICKNESS|~MSLP, 1000-500 THKN (90W)!0
l
ru

GAREA   = -6;-111;52;-14
PROJ    = MER/0.0;-49.5;0.0
TITLE   = 1/-2/~ ? ECMWF MSLP, 1000-500 MB THICKNESS|~ATL MSLP, 1000-500 THKN!0
l
r

restore ${USHrestore}/restore/500mb_hght_absv.2.nts
CLRBAR  = 1
TEXT    = 1/21//hw
GDPFUN   = avor !avor !sm9s(hght)   
TITLE   = 1/-2/~ ECMWF @ HGT AND ABS VORTICITY|~@ HGT AND AVOR (90W)!0
l
ru

GAREA   = -6;-111;52;-14
PROJ    = MER/0.0;-49.5;0.0
TITLE   = 1/-2/~ ? ECMWF @ HGT AND ABS VORTICITY|~ATL @ HGT AND AVOR (90W)!0
l
ru

exit
EOF
export err=$?;err_chk

#####################################################
# GEMPAK DOES NOT ALWAYS HAVE A NON ZERO RETURN CODE
# WHEN IT CAN NOT PRODUCE THE DESIRED GRID.  CHECK
# FOR THIS CASE HERE.
#####################################################
ls -l ecmwf.nmeta
export err=$?;export pgm="GEMPAK CHECK FILE";err_chk

if [ $SENDCOM = "YES" ] ; then
  mv ecmwf.nmeta ${COMOUT}/ecmwf_${PDY}_${cyc}
  if [ $SENDDBN = "YES" ] ; then
    $DBNROOT/bin/dbn_alert MODEL ${DBN_ALERT_TYPE} $job \
     $COMOUT/ecmwf_${PDY}_${cyc}
  fi
fi

