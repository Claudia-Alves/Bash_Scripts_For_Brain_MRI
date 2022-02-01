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

subject_list=`find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name "*_S_*" ` 

arr=($subject_list)

FILE_LIST_SIZE=${#arr[@]}

INDEX=1

#Loop accross every folder in the input directory
for subject in $subject_list
    do
        #Removes the content of INPUT_DIR and removes the extensions, keeping the "relative path" and file name
        RELATIVE_PATH=${subject#"$INPUT_DIR/"}
        RELATIVE_PATH=${RELATIVE_PATH%%.*}

        cd "$subject"
        if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*") ]]
        then 
            echo "Mask"
            masks=`find $subject -type f -name "*DTI*_*.nii.gz"` 
            echo "Structural"
            #Structural1=`find $subject -type f -name "brain.mgz" ` 
            #echo "strcutural one $Structural1"
            #mri_convert $Structural1 brain.nii.gz
            #echo "Converted"
            Structural=`find $subject -type f -name "brain.nii.gz"`
            echo "estrutrural" $Structural
            mask_files=($masks)
            Struct_files=($Structural) 
            mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
            struct_file=${Struct_files[0]}
            Foldera=`find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*.bedpostX"`
            folder_list=($Foldera)
            Folder_dti=${folder_list[0]} 
            echo "pasta dti $Folder_dti"
            #Return which file is being processed
            #Folder=`find $subject -maxdepth 1 -mindepth 1 -type d -name "Axial*DTI.bedpostX"`
            #folder_list=($Folder)
            #folder_dti=${folder_list[0]}
            #echo $mask_file  se não colocar no sitio certo as matrizes fazer isto da pasta
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/flirt_processing.txt #/$folder_dti 
            #Save start time
            STARTTIME=`date +%s%N`
            
            #Run the command
            flirt -in $mask_file -ref $struct_file -out diff2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

            flirt -in $mask_file -ref $struct_file -omat $Folder_dti/xfms/diff2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo
            
            convert_xfm -omat $Folder_dti/xfms/str2diff.mat -inverse $Folder_dti/xfms/diff2str.mat

            flirt -in $struct_file -ref ../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $Folder_dti/xfms/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

            convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $Folder_dti/xfms/str2standard.mat

            convert_xfm -omat $Folder_dti/xfms/diff2standard.mat -concat  $Folder_dti/xfms/str2standard.mat $Folder_dti/xfms/diff2str.mat 

            convert_xfm -omat $Folder_dti/xfms/standard2diff.mat -inverse $Folder_dti/xfms/diff2standard.mat

            echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

            #Save end time
            ENDTIME=`date +%s%N`

            #Compute elapsed time
            elapsed=$(($ENDTIME -$STARTTIME))

            #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
            echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_flirt.txt
            
        fi
        cd ..
            
        #Increment INDEX
        let INDEX=${INDEX}+1

done