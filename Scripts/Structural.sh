#!/bin/bash

DICOM_PATH="/notebooks/disk2/Scripts/dicom2nifti_recon_all.sh"

CP_NII_FOLDER="/notebooks/disk2/Scripts/cp_nii_for_output.sh"

CP_NII="/notebooks/disk2/Scripts/cp_nii_for_recon.sh"

RECON_ALL="/notebooks/disk2/Scripts/recon-all_batch.sh"

RM_EMPTY_DIR="/notebooks/disk2/Scripts/rm_empty_dir.sh"

#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -o output_directory -- program to perform structural analysis

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


#------------TER ATENÇÃO AO INPUT DIR E OUTPUT DIR EM CADA ----------------------#


echo "-------------------------------Running scripts for Structural analysis-------------------------------"

echo "#############################"
echo "Converting Dicom to Nifti"
bash "$DICOM_PATH" -i $INPUT_DIR -o $OUTPUT_DIR   

echo "#############################"
echo "Copying MPRAGE files to the main folder"
bash "$CP_NII_FOLDER" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Copying MPRAGE files to the main folder"
bash "$CP_NII" -i $OUTPUT_DIR 

echo "#############################"
echo "Running Recon-all"
bash "$RECON_ALL" -i $OUTPUT_DIR

echo "#############################"
echo "Removing Empty Directories"
bash "$RM_EMPTY_DIR" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "-------------------------------Finished running scripts for Structural analysis-------------------------------"
