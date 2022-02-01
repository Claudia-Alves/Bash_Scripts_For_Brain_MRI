#!/bin/bash
#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -o output_directory -- program to perform preprocessing of DTI data

where:
    -h Show this help text
    -i Input directory for preprocessing of DTI data
    -o Output folder to store output data";
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


#Get list of directories in input directory

#I also changed `command` to $(command), which also generally behaves similarly, but is nicer with nested commands.

subject_list=`find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name "*_S_*"`  

arr=($subject_list)

FILE_LIST_SIZE=${#arr[@]}

INDEX=1

for subject in $subject_list; 
    do 
    cd "$subject"
    if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*") ]]
    then        
        if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "*Sag*IR*FSPGR*" -o -name "*MP*RAGE*") ]]
        then
            Folder=`find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*"`

            #folder_dti=${folder_list[0]}
            cd "$folder_dti"
            DTI=`find $folder_dti -type f -name "*DTI*.nii"` #doesnt create a problem with mask because there is no mask with .nii only with .nii.gz, It was just "*DTI*.nii"
            bval=`find $folder_dti -type f -name "*.bval" `
            bvec=`find $folder_dti -type f -name "*.bvec" `
            masks=`find $folder_dti -type f -name "*DTI*_mask.nii.gz"`
            files_dti=($DTI)
            bval_files=($bval)
            bvec_files=($bvec)
            mask_files=($masks)    #these are in case there are more than one file per search
            files_list=${files_dti[0]}
            bval_file=${bval_files[0]}
            bvec_file=${bvec_files[0]}
            mask_file=${mask_files[0]}
            json=`find $folder_dti -type f -name "*DTI*.json"` 

           #-----------------Making acqparams.txt-----------------------
            #echo "this is $manuf 1"
            manuf=`cat $json | jq -r '.Manufacturer'` 
            #echo "this is $manuf"
            if [[ "$manuf" == "Siemens" ]]
            then
                total=` cat $json | jq '.TotalReadoutTime' ` #Funcionaaa! agora é usar este valor no acqparams
                echo -e "0 1 0 $total\n0 -1 0 $total" > acqparams.txt  #In some shells , interpretation of escape sequence characters is correctly done in echo command by -e option.
            elif [[ "$manuf" == "Philips" ]] 
            then
                etl=`cat $json | jq -r '.EchoTrainLength'` 
                tesla=`cat $json | jq -r '.MagneticFieldStrength'`
                let x=$etl
                let y=$tesla 
                echos=$( echo "scale=6; ( 12000 / ($y*3.35*42.576*$x))*0.001" | bc) #assuming 12 for WFS (with 3T) que multiplica com o 1000 dando 12000, 3.35 water-fat difference, 42.576 ressonance frequency https://support.brainvoyager.com/brainvoyager/functional-analysis-preparation/29-pre-processing/78-epi-distortion-correction-echo-spacing-and-bandwidth   1000*12=12000
                
                #echo "echo spacing $echos"

                total=$( echo "scale=6; $echos*$x" | bc)
                #echo "totaal $total"

                echo -e "0 1 0 $total\n0 -1 0 $total" > acqparams.txt
            elif [[ "$manuf" == "GE" ]]
            then
                total=` cat $json | jq '.TotalReadoutTime' ` 
                echo -e "0 1 0 $total\n0 -1 0 $total" > acqparams.txt
            else
                echo "Unrecognized protocol"
                #exit 1
            fi

            #echo $files_list
            #echo $bval_file
            #echo $bvec_file
            #echo $mask_file

            #Return which file is being processed
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject/$folder_dti
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject/$folder_dti >> $OUTPUT_DIR/eddy_OUTPUT.txt
            #Save start time
            STARTTIME=`date +%s%N`
            #-----------------Making index.txt-----------------------
            myVar=($(wc -w $bval_file))
            #echo $myVar
            indx=""
            for ((i=1;i<=$myVar;i+=1))
                do 
                    indx="$indx 1"
                done
            echo $indx>index.txt

            #x=`wc -w index.txt`
            #echo $x
            file_index="index.txt"
            #echo $file_index


            #Run the command
            eddy --imain=$files_list --mask=$mask_file --index=$file_index --acqp="acqparams.txt" --bvecs=$bvec_file --bvals=$bval_file --out=eddy_output --data_is_shelled 

            echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

            cd ..

            #Save end time
            ENDTIME=`date +%s%N`

            #Compute elapsed time
            elapsed=$(($ENDTIME -$STARTTIME))

            #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
            echo "$elapsed,$subject" >> $OUTPUT_DIR/results_eddy.txt
        else 
            cd ..
            echo "No Structural folder:" $subject
            echo "No Structural folder:" $subject >> $OUTPUT_DIR/NO_FOLDER.txt
        fi
    else 
        cd ..
        echo "No Diffusion folder:" $subject
        echo "No Diffusion folder:" $subject >> $OUTPUT_DIR/NO_FOLDER.txt
    fi
    let INDEX=${INDEX}+1
    cd ../
    #Increment INDEX
done