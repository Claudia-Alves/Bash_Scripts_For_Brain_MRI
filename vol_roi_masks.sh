#!/bin/bash

#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -o output_directory -- program to copy files for merge

where:
    -h Show this help text
    -i Input directory for preprocessing of data
    -o Output folder to store output data
    -r Output file to log the running time";
}

#Defining allowed options in the script
options=':i:o:r:h'
while getopts $options option
do 
    case "$option" in
        i  ) INPUT_DIR=`realpath $OPTARG` ;;
        o  ) OUTPUT_DIR=$OPTARG;;
        h  ) usage; exit;;
        \? ) echo "Unknown option: -$OPTARG" >&2; exit 1;;
        :  ) echo "Missing option argument for -$OPTARG" >&2; exit 1;;
        *  ) echo "Unimplemented option: -$OPTARG" >&2; exit 1;;
    esac
done

#Checks if the required option was provided

if [ "x" == "x$INPUT_DIR" ]; then
    echo "-i [input_directory] is required"
    exit 1
fi

#Checks if the required option was provided

if [ "x" == "x$OUTPUT_DIR" ]; then
    echo "-o [output_directory] is required"
    exit 1
fi


mkdir -p $OUTPUT_DIR
#touch $OUTPUT_DIR/results_cp_files.txt

#Get list of files in input directory
subject_list=`find $INPUT_DIR -mindepth 1 -maxdepth 1 -type d -name "*_S_*"` 


#COnvert the list of files in an array
arr=($subject_list)

#Get the length of the array to provide status below
FILE_LIST_SIZE=${#arr[@]}

#initialize index to 1

INDEX=1

touch STATS_volume_masks.txt
#Loop accross every nifti files in the input directory
for subject in $subject_list; 
    do 
        #echo "$subject"
        cd "$subject"
        
        if [[ -n $(find $subject  -type f -name "dtifit_FA_2registration.nii.gz" ) ]] # 
        then
            if [[ -n $(find $subject -type f -name "right_HC_prob.nii.gz" ) ]]
            then
                
                Mask_R_HC=`find $subject -type f -name 'right_hippocampus.nii.gz' `
                Mask_R_EC=`find $subject -type f -name 'right_entorhinal.nii.gz' `
                Mask_L_HC=`find $subject -type f -name 'left_hippocampus.nii.gz' `
                Mask_L_EC=`find $subject -type f -name 'left_entorhinal.nii.gz' `
                
                
                #Return which file is being processed
                echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject
                
                #Save start time
                STARTTIME=`date +%s%N`

                
                echo "############"

                echo " Volume of Right EC for $(basename $subject)"
                fslstats $Mask_R_EC -V
                echo " Volume of Right HC for $(basename $subject)"
                fslstats $Mask_R_HC -V
                echo " Volume of Left EC for $(basename $subject)"
                fslstats $Mask_L_EC -V
                echo " Volume of Left HC for $(basename $subject)"
                fslstats $Mask_L_HC -V    

                echo "$(basename $INPUT_DIR)" >> $INPUT_DIR/STATS_volume_masks.txt
                echo "$(basename $subject)" >> $INPUT_DIR/STATS_volume_masks.txt

               
                #echo " Volume of Right EC for $(basename $subject)" 
                fslstats $Mask_R_EC -V  >> $INPUT_DIR/STATS_volume_masks.txt
                #echo " Volume of Right HC for $(basename $subject)"
                fslstats $Mask_R_HC -V  >> $INPUT_DIR/STATS_volume_masks.txt
                #echo " Volume of Left EC for $(basename $subject)" 
                fslstats $Mask_L_EC -V  >> $INPUT_DIR/STATS_volume_masks.txt
                #echo " Volume of Left HC for $(basename $subject)" 
                fslstats $Mask_L_HC -V  >> $INPUT_DIR/STATS_volume_masks.txt

                echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject 
                echo "--------------------------------------------------------" 
                #Save end time
                ENDTIME=`date +%s%N`

                #Compute elapsed time
                elapsed=$(($ENDTIME -$STARTTIME))

                #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                #echo "$elapsed,$FILE" >> ../$OUTPUT_DIR/results_cp_files.txt

                else
                    echo "No probtrackX output output found. $subject" 
                    echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_volume_masks.txt
                    echo "No probtrackX output output found. $subject" >> $INPUT_DIR/STATS_volume_masks.txt
                    echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_volume_masks.txt
                fi
            else
                echo "No DTIFIT output found. $subject"
                echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_volume_masks.txt
                echo "No DTIFIT output found. $subject" >> $INPUT_DIR/STATS_volume_masks.txt     
                echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_volume_masks.txt
            fi
            cd ..
            #Increment INDEX
            let INDEX=${INDEX}+1
done


