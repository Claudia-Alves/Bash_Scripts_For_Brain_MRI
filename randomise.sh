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

echo "####################One sample###########################"

echo "#################### FA ###########################"


randomise -i ../FA_images/AD_FA_merged -o AD_FA_right_EC  -m ../right_EC_images/AD_right_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/AD_FA_merged -o AD_FA_right_HC  -m ../right_HC_images/AD_right_HC_merged -1 -n 500 -T
randomise -i ../FA_images/AD_FA_merged -o AD_FA_left_EC  -m ../left_EC_images/AD_left_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/AD_FA_merged -o AD_FA_left_HC  -m ../left_HC_images/AD_left_HC_merged -1 -n 500 -T 

randomise -i ../FA_images/CN_FA_merged -o CN_FA_right_EC  -m ../right_EC_images/CN_right_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/CN_FA_merged -o CN_FA_right_HC  -m ../right_HC_images/CN_right_HC_merged -1 -n 500 -T
randomise -i ../FA_images/CN_FA_merged -o CN_FA_left_EC  -m ../left_EC_images/CN_left_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/CN_FA_merged -o CN_FA_left_HC  -m ../left_HC_images/CN_left_HC_merged -1 -n 500 -T 

randomise -i ../FA_images/MCI_FA_merged -o MCI_FA_right_EC  -m ../right_EC_images/MCI_right_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/MCI_FA_merged -o MCI_FA_right_HC  -m ../right_HC_images/MCI_right_HC_merged -1 -n 500 -T
randomise -i ../FA_images/MCI_FA_merged -o MCI_FA_left_EC  -m ../left_EC_images/MCI_left_EC_merged -1 -n 500 -T 
randomise -i ../FA_images/MCI_FA_merged -o MCI_FA_left_HC  -m ../left_HC_images/MCI_left_HC_merged -1 -n 500 -T 

echo "#################### MD ###########################"

randomise -i ../MD_images/AD_MD_merged -o AD_MD_right_EC  -m ../right_EC_images/AD_right_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/AD_MD_merged -o AD_MD_right_HC  -m ../right_HC_images/AD_right_HC_merged -1 -n 500 -T
randomise -i ../MD_images/AD_MD_merged -o AD_MD_left_EC  -m ../left_EC_images/AD_left_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/AD_MD_merged -o AD_MD_left_HC  -m ../left_HC_images/AD_left_HC_merged -1 -n 500 -T 

randomise -i ../MD_images/CN_MD_merged -o CN_MD_right_EC  -m ../right_EC_images/CN_right_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/CN_MD_merged -o CN_MD_right_HC  -m ../right_HC_images/CN_right_HC_merged -1 -n 500 -T
randomise -i ../MD_images/CN_MD_merged -o CN_MD_left_EC  -m ../left_EC_images/CN_left_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/CN_MD_merged -o CN_MD_left_HC  -m ../left_HC_images/CN_left_HC_merged -1 -n 500 -T 

randomise -i ../MD_images/MCI_MD_merged -o MCI_MD_right_EC  -m ../right_EC_images/MCI_right_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/MCI_MD_merged -o MCI_MD_right_HC  -m ../right_HC_images/MCI_right_HC_merged -1 -n 500 -T
randomise -i ../MD_images/MCI_MD_merged -o MCI_MD_left_EC  -m ../left_EC_images/MCI_left_EC_merged -1 -n 500 -T 
randomise -i ../MD_images/MCI_MD_merged -o MCI_MD_left_HC  -m ../left_HC_images/MCI_left_HC_merged -1 -n 500 -T 


echo "####################Two sample###########################"

echo "#################### MD ###########################"

randomise -i ../MD_images/All_groups_MD_merged -o twosample/All_MD_left_EC/All_MD_left_EC  -m ../left_EC_images/All_groups_left_EC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../MD_images/All_groups_MD_merged -o twosample/All_MD_left_HC/All_MD_left_HC  -m ../left_HC_images/All_groups_left_HC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../MD_images/All_groups_MD_merged -o twosample/All_MD_right_EC/All_MD_right_EC  -m ../right_EC_images/All_groups_right_EC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../MD_images/All_groups_MD_merged -o twosample/All_MD_right_HC/All_MD_right_HC  -m ../right_HC_images/All_groups_right_HC_merged -n 500 -T -d glm.mat -t glm.con

echo "#################### FA ###########################"

randomise -i ../FA_images/All_groups_FA_merged -o twosample/All_FA_left_EC/All_FA_left_EC  -m ../left_EC_images/All_groups_left_EC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../FA_images/All_groups_FA_merged -o twosample/All_FA_left_HC/All_FA_left_HC  -m ../left_HC_images/All_groups_left_HC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../FA_images/All_groups_FA_merged -o twosample/All_FA_right_EC/All_FA_right_EC  -m ../right_EC_images/All_groups_right_EC_merged -n 500 -T -d glm.mat -t glm.con

randomise -i ../FA_images/All_groups_FA_merged -o twosample/All_FA_right_HC/All_FA_right_HC  -m ../right_HC_images/All_groups_right_HC_merged -n 500 -T -d glm.mat -t glm.con