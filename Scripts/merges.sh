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



touch $OUTPUT_DIR/results_cp_files.txt



#Loop accross every nifti files in the input directory

#echo "$subject"

#Create a new directory if the directory does not exist 
mkdir -p $OUTPUT_DIR/$RELATIVE_PATH

#Return which file is being processed
echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

if [[ -n $(find $OUTPUT_DIR -type f -name "*_*_right_HC_prob.nii.gz" ) ]] # 
then           
    echo "Merging right HC"
    fslmerge -t All_groups_right_HC_merged *_*_right_HC_prob.nii.gz
    fslmerge -t AD_right_HC_merged AD_*_right_HC_prob.nii.gz
    fslmerge -t CN_right_HC_merged CN_*_right_HC_prob.nii.gz
    fslmerge -t MCI_right_HC_merged MCI_*_right_HC_prob.nii.gz
    
    echo "Samples have been merged"
    
elif [[ -n $(find $OUTPUT_DIR -type f -name "*_*_right_EC_prob.nii.gz" ) ]] # 
then 

    echo "Merging right EC"
    fslmerge -t All_groups_right_EC_merged *_*_right_EC_prob.nii.gz
    fslmerge -t AD_right_EC_merged AD_*_right_EC_prob.nii.gz
    fslmerge -t CN_right_EC_merged CN_*_right_EC_prob.nii.gz
    fslmerge -t MCI_right_EC_merged MCI_*_right_EC_prob.nii.gz
    
    echo "Samples have been merged"
    
elif [[ -n $(find $OUTPUT_DIR -type f -name "*_*_left_EC_prob.nii.gz" ) ]] # 
then     
    echo "Merging left EC"
    fslmerge -t All_groups_left_EC_merged *_*_left_EC_prob.nii.gz
    fslmerge -t AD_left_EC_merged AD_*_left_EC_prob.nii.gz
    fslmerge -t CN_left_EC_merged CN_*_left_EC_prob.nii.gz
    fslmerge -t MCI_left_EC_merged MCI_*_left_EC_prob.nii.gz
    
    echo "Samples have been merged"

elif [[ -n $(find $OUTPUT_DIR -type f -name "*_*_left_HC_prob.nii.gz" ) ]] # 
then
    echo "Merging left HC"
    fslmerge -t All_groups_left_HC_merged *_*_left_HC_prob.nii.gz
    fslmerge -t AD_left_HC_merged AD_*_left_HC_prob.nii.gz
    fslmerge -t CN_left_HC_merged CN_*_left_HC_prob.nii.gz
    fslmerge -t MCI_left_HC_merged MCI_*_left_HC_prob.nii.gz
    
    echo "Samples have been merged"
    
elif [[ -n $(find $OUTPUT_DIR -type f -name "*_*_dtifit_FA_2registration.nii.gz" ) ]] # 
then
    echo "Merging FA files"
    fslmerge -t All_groups_FA_merged *_*_dtifit_FA_2registration.nii.gz
    fslmerge -t AD_FA_merged AD_*_dtifit_FA_2registration.nii.gz
    fslmerge -t CN_FA_merged CN_*_dtifit_FA_2registration.nii.gz
    fslmerge -t MCI_FA_merged MCI_*_dtifit_FA_2registration.nii.gz
    
    echo "Samples have been merged"

elif [[ -n $(find $OUTPUT_DIR -type f -name "*_*_dtifit_MD_2registration.nii.gz" ) ]] # 
then
    echo "Merging MD files"
    fslmerge -t All_groups_MD_merged *_*_dtifit_MD_2registration.nii.gz
    fslmerge -t AD_MD_merged AD_*_dtifit_MD_2registration.nii.gz
    fslmerge -t CN_MD_merged CN_*_dtifit_MD_2registration.nii.gz
    fslmerge -t MCI_MD_merged MCI_*_dtifit_MD_2registration.nii.gz
    
    echo "Samples have been merged"
else 
    echo "No samples to merge."
fi




