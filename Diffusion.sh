#!/bin/bash

DICOM_PATH="/notebooks/disk2/Scripts/dicom2nifti_batch.sh"

CP_NII="/notebooks/disk2/Scripts/cp_nii_for_DTI1.sh"

CP_BVALS="/notebooks/disk2/Scripts/cp_bval.sh"

CP_BVECS="/notebooks/disk2/Scripts/cp_bvec.sh"

CP_JSON="/notebooks/disk2/Scripts/cp_json.sh"

BET="/notebooks/disk2/Scripts/bet_renewed.sh"

EDDY="/notebooks/disk2/Scripts/eddy_batch_tractography.sh"

DTIFIT="/notebooks/disk2/Scripts/dtifit_batch.sh"

TBSS="/notebooks/disk2/Scripts/tbss_and_stats.sh"

BEDPOST="/notebooks/disk2/Scripts/bedpost_batch.sh"

FLIRT="/notebooks/disk2/Scripts/flirt_batch.sh"

MASK="/notebooks/disk2/Scripts/mask_batch.sh"

PROB="/notebooks/disk2/Scripts/probtracK_batch.sh"

RM_EMPTY_DIR="/notebooks/disk2/Scripts/rm_empty_dir.sh"

#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -o output_directory -- program to perform diffusion analysis

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


echo "-------------------------------Running scripts for Diffusion analysis------------------------------------"

echo "#############################" 
echo "Converting Dicom to Nifti"
bash "$DICOM_PATH" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Copying necessary files to the output folder"
bash "$CP_NII" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
bash "$CP_BVALS" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
bash "$CP_BVECS" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
bash "$CP_JSON" -i $INPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Running BET"
bash "$BET" -i $INPUT_DIR -o $OUTPUT_DIR 

echo "#############################"
echo "Running Eddy"
bash "$EDDY" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "----------------------------------------Microstructural Analysis----------------------------------------------"
echo "#############################"
echo "Running DTIFIT "
bash "$DTIFIT" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Running TBSS"
#bash "$TBSS"  -i $OUTPUT_DIR -o $OUTPUT_DIR  #Não é necessário correr este, não vou usar 

echo "------------------------------------------------Tractography---------------------------------------------------"
echo "#############################"
echo "Running BedpostX"
bash "$BEDPOST" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Running FLIRT"
bash "$FLIRT" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Running Batch Masking"
bash "$MASK" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Running ProbtrackX"
bash "$PROB" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "#############################"
echo "Removing Empty Directories"
bash "$RM_EMPTY_DIR" -i $OUTPUT_DIR -o $OUTPUT_DIR

echo "-------------------------------Finished running scripts for Diffusion analysis-------------------------------"
