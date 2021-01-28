#!/bin/bash
# Script to efficiently compress NEMO netcdf3 output
# Sebastian Wahl 03/2020 based on FOCI default postprocessing
#

# Mistral NCO
module load nco/4.7.5-gcc64 

# experiment settings
EXP_ID="GYRE"
datadir="/work/bb0519/b350090/models/release-4.0.1/cfgs/GYRE/EXP00_R4/"
filetags="grid_T grid_U grid_V grid_W grid_F"
steps="${EXP_ID}_1h ${EXP_ID}_3h ${EXP_ID}_5d"
startyear=1
endyear=40
yearstep=39
# set to true to delete original files after compression (recommended after testing)
# if set to false they are kept in a subdirectory nc3/
delete_netcdf3=false

# How many jobs in parallel?
max_jobs=4

# ncks settings
sortoption="--no-alphabetize"
tchunk=1; zchunk=1; ychunk=100; xchunk=100
[[ $(ncks --version 2>&1 | tail -1 | tr -dc '0-9') -lt 471 ]] && sortoption="-a"

if [[ ! -d $datadir ]] ; then
	echo
	echo "$datadir does not exist"
	echo
	exit 1
fi
cd $datadir 

echo 'NEMO netcdf4 conversion started'
mkdir -p nc3
for ((year=startyear; year<=endyear; year=year+yearstep))
do
        year1=$( printf "%04d" ${year} )
        year2=$( printf "%04d" $(( ${year} + ${yearstep} )) )
	for filetag in $filetags
	do
   	for s in $steps
      do
			input=nc3/${s}_${year1}0101_${year2}1231_${filetag}.nc3
                        echo $input
	    	output=${s}_${year1}0101_${year2}1231_${filetag}.nc
			# !!! output files will have the same name as the old input file !!! 
        	if [[ -f $output ]] ; then
			   # mv original .nc file to .nc3
				mv $output $input
               
				# If too many jobs run at the same time, wait
				while (( $(jobs -p | wc -l) >=  max_jobs )); do sleep 5s; done
				(
					echo "converting " $input " to " $output
					ncks -7 $sortoption -L 1 \
						--cnk_dmn time,${tchunk} --cnk_dmn time_counter,${tchunk} \
						--cnk_dmn z,${zchunk} --cnk_dmn depthu,${zchunk} --cnk_dmn depthv,${zchunk} --cnk_dmn depthw,${zchunk} --cnk_dmn deptht,${zchunk} \
						--cnk_dmn x,${xchunk} --cnk_dmn y,${ychunk} \
					$input $output 
					if [[ $? -eq 0 ]]; then
						echo "Conversion of $input to $output OK"
						$delete_netcdf3 && rm $input
					else
						echo "ERROR during conversion of $input to $output"
					fi
				) &
			fi
		done #steps
	done #filetags
done #years
wait

