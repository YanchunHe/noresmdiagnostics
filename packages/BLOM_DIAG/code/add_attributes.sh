#!/bin/bash

# BLOM DIAGNOSTICS package: add_attributes.sh
# PURPOSE: Add coordinate attributes to variables if necessary
# Johan Liakka, NERSC; Feb 2018
# Yanchun He, NERSC; Jun 2020

# Input arguments:
#  $casename  experiment name
#  $fyr_prnt  first yr climo
#  $lyr_prnt  last yr climo
#  $climodir  climo directory
#  $ann_mode  0 or 1
#  $mon_mode  0 or 1

casename=$1
fyr_prnt=$2
lyr_prnt=$3
climodir=$4
ann_mode=$5
mon_mode=$6

echo " "
echo "-----------------------"
echo "add_attributes.sh"
echo "-----------------------"
echo "Input arguments:"
echo " casename = $casename"
echo " fyr_prnt = $fyr_prnt"
echo " lyr_prnt = $lyr_prnt"
echo " climodir = $climodir"
echo " ann_mode = $ann_mode"
echo " mon_mode = $mon_mode"

function ncattget { $NCKS --trd -M -m ${3} | grep -E -i "^${2} attribute [0-9]+: ${1}" | cut -f 11- -d ' ' | sort ; }

if [ $ann_mode -eq 1 ]; then
    var_list=`cat $WKDIR/attributes/vars_climo_ann_${casename} | sed 's/,/ /g'|sed 's/depth_bnds //g'`
    ann_file=${casename}_ANN_${fyr_prnt}-${lyr_prnt}_climo.nc
    for var in $var_list
    do
        $NCKS --quiet -v $var -d x,0 -d y,0 $climodir/$mon_file >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            crd=$(ncattget coordinates $var $climodir/$mon_file)
            if [ "$crd" != "plon plat" ]
            then
                echo "Adding coordinate attributes to $var in $ann_file"
                $NCATTED -a coordinates,$var,c,c,"plon plat" $climodir/$ann_file
            fi
        fi
    done
fi
if [ $mon_mode -eq 1 ]; then
    var_list=`cat $WKDIR/attributes/vars_climo_mon_${casename} | sed 's/,/ /g'`
    for var in $var_list
    do
        for month in 01 02 03 04 05 06 07 08 09 10 11 12
        do
            mon_file=${casename}_${month}_${fyr_prnt}-${lyr_prnt}_climo.nc
            $NCKS --quiet -v $var -d x,0 -d y,0 $climodir/$mon_file >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                crd=$(ncattget coordinates $var $climodir/$mon_file)
                if [ "$crd" != "plon plat" ]
                then
                    echo "Adding coordinate attributes to $var"
                    $NCATTED -a coordinates,$var,c,c,"plon plat" $climodir/$mon_file
                fi
            fi
        done
    done    
fi
