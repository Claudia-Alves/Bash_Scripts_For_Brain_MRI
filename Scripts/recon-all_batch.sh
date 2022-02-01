#!/bin/bash
#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -- program to perform recon-all

where:
    -h Show this help text
    -i Input directory for preprocessing of DTI data
    -r Output file to log the running time";
}

#Defining allowed options in the script
options=':i:o:r:h'
while getopts $options option
do 
    case "$option" in
        i  ) INPUT_DIR=`realpath $OPTARG` ;;
        o  ) OUTPUT_DIR=$INPUT_DIR;;
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


#CONSIDER THIS: find . -name "Accelerated_Sagittal_MPRAGE_*.nii" | parallel --jobs 8 recon-all -s {.} -i {} -all -qcache; except it stores every folder with the accelerated name in the subjects

export SUBJECTS_DIR=$INPUT_DIR


#Get list of files in input directory
FOLDER_LIST=`find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name '*_S_*'` #Other way of doing is with maxdepth and mindepth
 

#COnvert the list of files in an array
arr1=($FOLDER_LIST)

#Get the length of the array to provide status below

FOLDER_LIST_SIZE=${#arr1[@]}
 
#initialize index to 1
INDEX=1

#Loop accross every folders in the input directory

for FOLDER in $FOLDER_LIST
    do
        if ! [[ -n $(find $FOLDER -type d -name '*_S_*_recon') ]]
        then
            if [[ -n $(find $FOLDER -maxdepth 1 -mindepth 1 -type f -name '*MP*RAGE*.nii' -o -name '*Sag*IR*FSPGR*.nii') ]] #
            then 
                #cd $FOLDER
                Mprage=`find $FOLDER -maxdepth 1 -mindepth 1 -type f -name '*MP*RAGE*.nii' -o -name '*Sag*IR*FSPGR*.nii'` #
                #files_mprage=($Mprage)
                #files_list=${files_mprage[0]}
                #cd ..

                #Return which file is being processed
                echo "Processing file ($INDEX/$FOLDER_LIST_SIZE):" $FOLDER
                echo "Processing file ($INDEX/$FOLDER_LIST_SIZE):" $FOLDER >> Structural.txt
                #Save start time
                STARTTIME=`date +%s%N`
                #Run the command

                recon-all -i $Mprage -s {$FOLDER}_recon -all # >> Recon_OUTPUT{$FOLDER}.txt #coloca a pasta resultante na INPUT_DIR

                #this next part works well if there is no previous folder *_S_*_* in the INPUT_DIR, otherwise it will put all those folders in all subject folders. So if it is run from the start it will work, be sure to run it from start

                if [[ -n $(find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name '*_S_*_recon') ]] 
                    then
                    recon_list=$(find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name '*_S_*_recon')
                    arr2=($recon_list)
                    recon_list_size=${#arr2[@]}
                    index2=1
                    for recon in $recon_list
                        do 
                            cp -u -r $recon $FOLDER
                            rm -r $recon
                        let index2=${index2}+a
                        done
                fi

                #Save end time
                ENDTIME=`date +%s%N`

                #Compute elapsed time
                elapsed=$(($ENDTIME-$STARTTIME))

                #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                echo "$elapsed,$FILE" >> $OUTPUTDIR/"results_recon.txt"

            else
                echo "No structural file ($INDEX/$FOLDER_LIST_SIZE):" $FOLDER
                echo "No structural file ($INDEX/$FOLDER_LIST_SIZE):" $FOLDER >> Structural.txt
            fi          
        fi
        #Increment INDEX
        let INDEX=${INDEX}+1
        #cd ..
    done
