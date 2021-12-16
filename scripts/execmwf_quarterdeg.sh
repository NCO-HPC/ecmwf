#!/bin/bash

# NAME - ecmwf_quarterdeg.sh

# Grab the new ECMWF .25 degree files and create GEMPAK grids
#
# usage: get_ecmwf_quarterdeg.sh.ecf $PDY $cyc
# PDY in the YYYYMMDD format
# cyc is 00 or 12
# 00 files arrive usually 0550-0700 and the script is run at 0600
# 12 files arrive usually 1750-1900 and the script is run at 1800
#
# Log:
# M. Klein/WPC	  04/02/2013	  Add creation of subset grid for NHC.
# M. Klein/WPC    04/16/2013   Add DBNET alert to send grids to $MODEL.
# M. Klein/WPC    04/22/2013   Comment out copy of grids to $GRPHGD/ecmwf_0p25.
# M. Klein/WPC    12/17/2014   Remove exit if still running, since this runs only twice per day.
# W. Cencek/NCO   01/30/2015   Convert from C-shell to bash and to NCO standards
# K. Menlove/NCO  07/06/2017   Add 3-hourly 0.25 ECMWF det grids.

set -x

postmsg "$jlogfile" "Starging $0 on `hostname`"

if [ $# -ne 2 ] ; then
    err_exit "Wrong number of parameters provided to $0"
fi
fullddate=$1
cycle=$2
ddate=`echo ${fullddate} | cut -c3-8`
mn=`echo ${fullddate} | cut -c5-6`
dy=`echo ${fullddate} | cut -c7-8`

# FUNCTION DEFINITIONS #################################################

SENDFILE()
# restrict access, copy file $1 to $COMOUT and alert it using subtype $2
{
    chgrp rstprod $1
    chmod 640 $1
    [ "$SENDCOM" = 'YES' ]  &&  cp -p  $1  $COMOUT
    [ "$SENDDBN" = 'YES' ]  &&  $DBNROOT/bin/dbn_alert MODEL $2 $job $COMOUT/$1
}    

GEMPAK_gdinfo()
# fill levels, vcord, and parm arrays by reading a GEMPAK file $1
{
    rm -f gdinfo.fil
    gdinfo << EOF
        gdfile  = $1
        lstall  = yes
        output  = f
        gdattim = all
        glevel  = all
        gvcord  = all
        gfunc   = all
        l
        run

EOF
    grep "${ddate}/${cycle}00" gdinfo.fil > data.txt
    levels=()
    vcord=() 
    parm=() 
    local numlines=`wc -l data.txt | awk '{print $1}'`
    local cnt=1  # No. of line in data.txt
    while [ ${cnt} -le ${numlines} ] ; do
        local currline=`cat data.txt | head -n ${cnt} | tail -1`
        local currlevel=`echo ${currline} | awk '{print $3}'`
        local currvcord=`echo ${currline} | awk '{print $4}'`
        local currparm=`echo ${currline} | awk '{print $5}'`
        levels=( ${levels[@]} ${currlevel} )
        vcord=( ${vcord[@]} ${currvcord} ) 
        parm=( ${parm[@]} ${currparm} )
        (( cnt ++ ))
    done
}

fhrs=( $(seq -w 0 3 144) $(seq 150 6 240) )
cp ecmwfgrib128.tbl ecmwfgrib228.tbl
cp ecmwfgrib128.tbl ecmwfgrib0.tbl
cp ecmwfgrib128.tbl grib128.tbl
cp ecmwfgrib128.tbl grib228.tbl
cp ecmwfgrib128.tbl grib0.tbl
cp ${GEMTBL}/grid/wmogrib128.tbl ./wmogrib228.tbl
cp ${GEMTBL}/grid/wmogrib128.tbl ./wmogrib0.tbl
cp ${GEMTBL}/grid/cntrgrib1.tbl ./cntrgrib2.tbl
cp ${GEMTBL}/grid/vcrdgrib1.tbl ./vcrdgrib2.tbl
# for PTYPE (GRIB2)
cp ${GEMTBL}/grid/g2vcrdwmo2.tbl ./g2vcrdwmo5.tbl
( cat ${GEMTBL}/grid/g2varswmo2.tbl; echo "000 001 019 000 Precipitation Type               code table           PTYPE            0  -9999.00" ) > ./g2varswmo5.tbl

echo "Want to get 0.25 degree ECMWF for ${fullddate} at ${cycle}Z cycle"


# This script will run as a large "while" loop until all of the data is processed or
# it gets past a certain time of day.

finished="no"
finished_precip="no" 

while [ ${finished} = "no" ] || [ ${finished_precip} = "no" ] ; do ########################## WHILE LOOP START ##############

    echo "STARTING NEXT ITERATION OF THE WHILE LOOP"
    actual_hrs=()
    actual_hrs_precip=()
    numfiles=0
    numfiles_precip=0
    # Determine if a particular forecast hour has already been processed.  If so...do not reprocess.
    # If not, check for the file associated with that forecast hour.  If in, add it to the array of
    # files to process.

    for hr in ${fhrs[@]} ; do
        process_all_but_precip="yes"
        process_precip="yes"
        if [ -e ${COMOUTlogs}/processed_hours_${fullddate}_${cycle} ] ; then
            if [ $(grep -c ${hr} ${COMOUTlogs}/processed_hours_${fullddate}_${cycle}) = 1 ] ; then
                process_all_but_precip="no"
            fi
        fi
        if [ -e ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle} ] ; then
            if [ $(grep -c ${hr} ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle}) = 1 ] ; then
                process_precip="no"
            fi
        fi

        if [ ${process_all_but_precip} = "yes" ] ; then
            vdate=`datetime ${ddate}/${cycle}00 ${hr} %m%d%H`
            fname_check="U1D${mn}${dy}${cycle}00${vdate}00${ECMWF_FILE_EXT}"
            if [ ${hr} = "000" ] ; then
                fname_check="U1D${mn}${dy}${cycle}00${vdate}01${ECMWF_FILE_EXT}"
	        fi
            if [ -r ${DCOMIN}/${fname_check} ] ; then
                (( numfiles ++ ))
                actual_hrs=( ${actual_hrs[@]} ${hr} )
            fi
        # This case would happen if, say, the 18-hr fcst came in before the 12-hr.  The 18-hour would have already been taken care of 
        # EXCEPT for the precip
        elif [ ${process_precip} = "yes" ] && [ ${hr} != "000" ] ; then
            (( numfiles_precip ++ ))
            actual_hrs_precip=( ${actual_hrs_precip[@]} ${hr} )
        fi
    done

    echo "HOURS FOR MAIN + PRECIP PROCESSING IN THIS 'WHILE' ITERATION:"
    echo ${actual_hrs[@]}
    echo "HOURS FOR PRECIP-ONLY PROCESSING IN THIS 'WHILE' ITERATION:"
    echo ${actual_hrs_precip[@]}

    ######################################################
    #                                                    #
    # BEGIN PROCESSING OF GRIB FILES                     #
    #                                                    #
    ######################################################

    echo "Generating grids from raw grib files."
    for fhr in ${actual_hrs[@]} ; do ############################################ FOR LOOP START (ACTUAL) ###########

        echo "Main + precip processing started for hour $fhr"
        vdate=`datetime ${ddate}/${cycle}00 ${fhr} %m%d%H`
        gbfile="U1D${mn}${dy}${cycle}00${vdate}00${ECMWF_FILE_EXT}"
        [ ${fhr} = "000" ] && gbfile="U1D${mn}${dy}${cycle}00${vdate}01${ECMWF_FILE_EXT}"
	    cp ${DCOMIN}/${gbfile} ./${gbfile}
	    precip_done="no"

#!!!!!!!!!!!!!!!!! NAGRIB CALLED !!!!!!!!!!!!!!!!!
        nagrib_nc << EOF > proc_$fhr.txt 
         gbfile  = ${gbfile}
         indxfl  =
         gdoutf  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
         proj    =
         grdarea =
         kxky    = 
         maxgrd  = 1000
         cpyfil  = gds
         garea   =
         output  = t
         !gbtbls  = ecmwfgrib128.tbl
         gbtbls  = 
         gbdiag  =
         pdsext  = no
         overwr  = yes
         l 
         run

EOF

# CHECK FOR NAGRIB ERRORS.  THIS HAPPENED WITH THE EC ENSEMBLES A COUPLE OF TIMES AND I INCORRECTLY 
# WROTE THAT AN HOUR HAD BEEN PROCESSED WHEN THE FILE INSTEAD WAS CORRUPTED.

        [ -s proc_$fhr.txt ] || continue  # goto next iteration of "for fhr" loop if no nagrib_nc output
        numerr=`cat proc_$fhr.txt | egrep -c "NAGRIB -16|NAGRIB -15"`
        if [ ${numerr} -gt 0 ] ; then
            echo "WARNING: Problems degribbing forecast hour $fhr"
            continue  # goto next iteration of "for fhr" loop if nagrib_nc errors
	    fi
	
# ALL F000 GRIDS FROM NAGRIB DO NOT HAVE F000 IN THE DATE/TIME GROUP.  NEED TO ADD IT.

        if [ ${fhr} = "000" ] ; then   #-------------------------- IF 1-----------------------------------

#!!!!!!!!!!!!!!!!! GDINFO CALLED !!!!!!!!!!!!!!!!!
	        GEMPAK_gdinfo ecmwf_0p25_${fullddate}${cycle}f${fhr} 

            cnt=0  # No. of array element (starts from 0 in bash)
            for lv in ${levels[@]} ; do
#!!!!!!!!!!!!!!!!! GDDIAG CALLED !!!!!!!!!!!!!!!!!
                gddiag << EOF 
                 gdfile  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
                 gdoutf  = newf000.grd
                 gfunc   = ${parm[$cnt]}
                 gdattim = ${ddate}/${cycle}00
                 glevel  = $lv
                 gvcord  = ${vcord[$cnt]}
                 grdnam  = ${parm[$cnt]}^${ddate}/${cycle}00F000
                 grdtyp  = s
                 gpack   =
                 grdhdr  = 0/0
                 proj    =
                 grdarea =
                 kxky    =
                 maxgrd  = 1000
                 cpyfil  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
                 anlyss  = 4/2;2;2;2
                 l
                 run

EOF
                (( cnt ++ ))
            done

            mv newf000.grd ecmwf_0p25_${fullddate}${cycle}f${fhr}
    	    echo "Main processing finished for hour $fhr"
    
    	else #-------------------------- ELSE 1-----------------------------------
    
    	    echo "Main processing finished for hour $fhr"
# Determine if the file valid 3 or 6 hours earlier exists.  If so, process
            # If fhr is less than or equal to 144, do 3-hourly, otherwise do 6-hourly
            if [ $fhr -le 144 ]; then
                hrly=3
            else
                hrly=6
            fi
            frhb=$(printf %03d $(( 10#$fhr-$hrly )))
            if [ -e ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${frhb} ] ; then
#!!!!!!!!!!!!!!!!! GDDIAG CALLED !!!!!!!!!!!!!!!!!
                echo "Precip processing started for hour $fhr"
	    	    gddiag << EOF 
                 gdfile  = ecmwf_0p25_${fullddate}${cycle}f${fhr} + ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${frhb}
                 gdoutf  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
                 gfunc   = mul(sub(pxxm^f${fhr},pxxm+2^f${frhb}),1000)
                 gdattim = f${fhr}
                 glevel  = 0
                 gvcord  = none
                 grdnam  = P0${hrly}M^${ddate}/${cycle}00F${fhr}
                 grdtyp  = s
                 gpack   =
                 grdhdr  = 0/0
                 proj    =
                 grdarea =
                 kxky    =
                 maxgrd  =
                 cpyfil  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
                 anlyss  = 4/2;2;2;2
                 l
                 run

EOF
                precip_done="yes"
                echo "Precip processing finished for hour $fhr"
            else
                echo "Precip processing skipped for hour $fhr (awaiting data for hour $frhb)"
            fi
	    fi #-------------------------- FI 1-----------------------------------

# Adding the GRIB2 part (PTYPE)
#!!!!!!!!!!!!!!!!! NAGRIB2 CALLED !!!!!!!!!!!!!!!!!
        nagrib2_nc << EOF > proc2_$fhr.txt 
         gbfile  = ${gbfile}
         indxfl  =
         gdoutf  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
         proj    =
         grdarea =
         kxky    = 
         maxgrd  = 1000
         cpyfil  = gds
         garea   =
         output  = t
         !gbtbls  = ecmwfgrib128.tbl
         gbtbls  = 
         gbdiag  =
         pdsext  = no
         overwr  = yes
         l 
         run

EOF

        SENDFILE ecmwf_0p25_${fullddate}${cycle}f${fhr} ECMWF_0P25_GEMPAK

#make subset grid for NHC
	    echo "NHC processing started for hour $fhr"
#!!!!!!!!!!!!!!!!! GDINFO CALLED !!!!!!!!!!!!!!!!!
	    GEMPAK_gdinfo ecmwf_0p25_${fullddate}${cycle}f${fhr}
        cnt=0  # No. of array element (starts from 0 in bash)
        for lv in ${levels[@]} ; do
#!!!!!!!!!!!!!!!!! GDDIAG CALLED !!!!!!!!!!!!!!!!!
            gddiag << EOF 
             gdfile  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
             gdoutf  = ecmwfnhc_0p25_${fullddate}${cycle}f${fhr}
             gfunc   = ${parm[$cnt]}
             gdattim = ${ddate}/${cycle}00F${fhr}
             glevel  = $lv
             gvcord  = ${vcord[$cnt]}
             grdnam  = ${parm[$cnt]}^${ddate}/${cycle}00F${fhr}
             grdtyp  = s
             gpack   =
             grdhdr  = 0/0
             proj    = CED/0;0;0
             grdarea = -25.0;160.0;70.0;20.0
             kxky    = 880;381
             maxgrd  = 200
             cpyfil  = 
             anlyss  = 4/2;2;2;2
             l
             run

EOF
            (( cnt ++ ))
        done
        SENDFILE ecmwfnhc_0p25_${fullddate}${cycle}f${fhr} ECMWF_0P25_NHCGEMPAK
	    echo "NHC processing finished for hour $fhr"

        echo ${fhr} >> ${COMOUTlogs}/processed_hours_${fullddate}_${cycle}
        [ $precip_done = "yes" ] && echo ${fhr} >> ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle}

	    echo "Main + precip processing finished for hour $fhr"
    done  ############################################ FOR LOOP END (ACTUAL) #################################

    # If precips are still left over to process...
    for fhr in ${actual_hrs_precip[@]} ; do  #xxxxxxxxxxxxxxxxxxxxxxxxxxxxx FOR LOOP START (ACTUAL PRECIP) xxxxxxxxxxxxxxxxxxxxxxxx
        # Make sure the file from fhr-3 or fhr-6 is available.
        # If fhr is less than or equal to 144, check 3-hourly, otherwise check 6-hourly
        if [ $fhr -le 144 ]; then
            hrly=3
        else
            hrly=6
        fi
        frhb=$(printf %03d $(( 10#$fhr-$hrly )))
        if [ -e ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${frhb} ] && [ -e ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${fhr} ] ; then
            echo "Precip-only processing started for hour $fhr"
            cp ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${fhr} .
#!!!!!!!!!!!!!!!!! GDDIAG CALLED !!!!!!!!!!!!!!!!!
            gddiag << EOF 
             gdfile  = ecmwf_0p25_${fullddate}${cycle}f${fhr} + ${COMOUT}/ecmwf_0p25_${fullddate}${cycle}f${frhb}
             gdoutf  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
             gfunc   = mul(sub(pxxm^f${fhr},pxxm+2^f${frhb}),1000)
             gdattim = f${fhr}
             glevel  = 0
             gvcord  = none
             grdnam  = P0${hrly}M^${ddate}/${cycle}00F${fhr}
             grdtyp  = s 
             gpack   =
             grdhdr  = 0/0
             proj    =
             grdarea =
             kxky    = 
             maxgrd  =
             cpyfil  = ecmwf_0p25_${fullddate}${cycle}f${fhr}
             anlyss  = 4/2;2;2;2
             l
             run

           ! Make P06M for NHC grid
             gdoutf  = ecmwfnhc_0p25_${fullddate}${cycle}f${fhr}
             cpyfil  = ecmwfnhc_0p25_${fullddate}${cycle}f${fhr}
             l
             run

EOF
            SENDFILE ecmwf_0p25_${fullddate}${cycle}f${fhr} ECMWF_0P25_GEMPAK
            SENDFILE ecmwfnhc_0p25_${fullddate}${cycle}f${fhr} ECMWF_0P25_NHCGEMPAK
            echo ${fhr} >> ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle}
            echo "Precip-only processing finished for hour $fhr"
        else
            echo "Precip-only processing skipped for hour $fhr"
        fi
    done  #xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx FOR LOOP END (ACTUAL PRECIP) xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

    # Perform checks of processed files.
    # 1. If on the first pass, all of the forecast hours are in...set finished to yes.
    # 2. Check the "processed_hours" file to see if all forecast hours have been written to it.
    #    This will occur if something's been processed, but not necessarily all forecast hours in this pass.

    # Non-precip section
    if [ ${#actual_hrs[@]} = ${#fhrs[@]} ] ; then
        echo "All files are in for the .25 degree ECMWF for ${fullddate} ${cycle}Z"
        finished="yes"
    elif [ ${numfiles} -lt ${#fhrs[@]} ] && [ ${numfiles} -gt 0 ] ; then
        if [ -s ${COMOUTlogs}/processed_hours_${fullddate}_${cycle} ] ; then
            numprocessed=`cat ${COMOUTlogs}/processed_hours_${fullddate}_${cycle} | wc -l`
            if [ ${numprocessed} -eq ${#fhrs[@]} ] ; then
                echo "All files are in for the .25 degree ECMWF for ${fullddate} ${cycle}Z"
                finished="yes"
            fi
        fi
    fi
    
    # Precip section
    if [ -s ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle} ] ; then
        numprocessed=`cat ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle} | wc -l`
        if [ ${numprocessed} -eq $((${#fhrs[@]}-1)) ] ; then
            echo "All precips have been written for ${fullddate} ${cycle}Z"
            finished_precip="yes"
        fi
    fi
    
    if [ ${finished} = "yes" ] && [ ${finished_precip} = "yes" ] ; then
        echo "${fullddate}" > ${COMOUT}/ecmwf_quarterdeg_${cycle}    
        #[ -e ${COMOUTlogs}/processed_hours_${fullddate}_${cycle} ] && rm -f ${COMOUTlogs}/processed_hours_${fullddate}_${cycle}
        #[ -e ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle} ] && rm -f ${COMOUTlogs}/processed_hours_precip_${fullddate}_${cycle}
    else
        echo "Sleeping 2 minutes...waiting for new data"
        sleep 120
    fi
done ############################################ WHILE LOOP END #############################

postmsg "$jlogfile" "$0 completed normally"

