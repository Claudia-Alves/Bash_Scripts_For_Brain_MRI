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

#Loop accross every nifti files in the input directory
for subject in $subject_list
    do
        #Removes the content of INPUT_DIR and removes the extensions, keeping the "relative path" and file name
        RELATIVE_PATH=${subject#"$INPUT_DIR/"}
        RELATIVE_PATH=${RELATIVE_PATH%%.*}
        if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*") ]]
        then 
            #Create a new directory if the directory does not exist 
            mkdir -p $subject/probtrackX
            mkdir -p $subject/probtrackX/right_masks
            mkdir -p $subject/probtrackX/left_masks  
            mkdir -p $subject/probtrackX/right_masks/EC
            mkdir -p $subject/probtrackX/right_masks/HC
            mkdir -p $subject/probtrackX/left_masks/EC
            mkdir -p $subject/probtrackX/left_masks/HC 

            cd "$subject"
            Folder=`find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*.bedpostX"`
            folder_list=($Folder)
            folder_dti=${folder_list[0]}
            #cd "$folder_dti"
            
            Foldera=`find $subject -maxdepth 1 -mindepth 1 -type d -name "*Axial*DTI*" `
            foldera_list=($Foldera)
            foldera_dti=${foldera_list[0]}
            
            Right_EC=`find $subject -type f -name "right_entorhinal.nii.gz"` 
            Left_EC=`find $subject -type f -name "left_entorhinal.nii.gz"`
            Right_HC=`find $subject -type f -name "right_hippocampus.nii.gz"`
            Left_HC=`find $subject -type f -name "left_hippocampus.nii.gz"`

            echo $Right_HC > waypoint_hc_right.txt
            echo $Left_HC > waypoint_hc_left.txt

            echo $Right_EC > waypoint_ec_right.txt
            echo $Left_EC > waypoint_ec_left.txt
            #Save start time
            STARTTIME=`date +%s%N`
            
            #Return which file is being processed
            
            echo "---------------Start Processing------------------"
            echo "Processing rightside EC for subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "Processing rightside EC for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/probtrack_processing.txt

            
            #Run the command
            probtrackx2 -x $Right_EC -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=$folder_dti/xfms/str2diff.mat --invxfm=$folder_dti/xfms/diff2str.mat --wtstop=$Right_HC --forcedir --opd -s $folder_dti/merged -m $folder_dti/nodif_brain_mask --dir=$subject/probtrackX/right_masks/EC --waypoints=waypoint_hc_right.txt  --waycond=AND >> Probtrack_RIGHT_OUTPUT.txt 
            
            cd probtrackX/right_masks/EC
            mv fdt_paths.nii.gz right_EC_prob.nii.gz
            mv waytotal right_EC_way
            cd ../../..
            
            flirt -in $subject/probtrackX/right_masks/EC/fdt_paths.nii.gz -ref $foldera_dti/dtifit_FA_2registration.nii.gz -applyxfm -init $foldera_dti/xfms_dtifit/str2diff.mat -out $subject/probtrackX/right_masks/EC/right_EC_prob.nii.gz

            echo "Processing rightside Hippocampus for subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "Processing rightside Hippocampus for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/probtrack_processing.txt 

            probtrackx2 -x $Right_HC -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=$folder_dti/xfms/str2diff.mat --invxfm=$folder_dti/xfms/diff2str.mat --wtstop=$Right_EC --forcedir --opd -s $folder_dti/merged -m $folder_dti/nodif_brain_mask --dir=$subject/probtrackX/right_masks/HC --waypoints=waypoint_ec_right.txt  --waycond=AND >> Probtrack_RIGHT_OUTPUT.txt 
            
            cd probtrackX/right_masks/HC
            mv fdt_paths.nii.gz right_HC_prob.nii.gz
            mv waytotal right_HC_way
            cd ../../..
            
            flirt -in $subject/probtrackX/right_masks/HC/fdt_paths.nii.gz -ref $subject/diff2registration.nii.gz -applyxfm -init $folder_dti/xfms/str2standard.mat -out $subject/probtrackX/right_masks/HC/right_HC_prob.nii.gz

            echo "Finished processing rightside for subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "---------------Next Side------------------"
            echo "Processing leftside EC for subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "Processing leftside EC for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/probtrack_processing.txt
            
            cd probtrackX/left_masks/EC
            mv fdt_paths.nii.gz left_EC_prob.nii.gz
            mv waytotal left_EC_way
            cd ../../..

            probtrackx2 -x $Left_EC -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=$folder_dti/xfms/str2diff.mat --invxfm=$folder_dti/xfms/diff2str.mat --wtstop=$Left_HC --forcedir --opd -s $folder_dti/merged -m $folder_dti/nodif_brain_mask --dir=$subject/probtrackX/left_masks/EC --waypoints=waypoint_hc_left.txt  --waycond=AND >> Probtrack_LEFT_OUTPUT.txt 
            
            flirt -in $subject/probtrackX/left_masks/EC/fdt_paths.nii.gz -ref $subject/diff2registration.nii.gz -applyxfm -init $folder_dti/xfms/diff2str.mat -out $subject/probtrackX/left_masks/EC/left_EC_prob.nii.gz

            echo "Processing leftside Hippocampus for subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "Processing leftside Hippocampus for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/probtrack_processing.txt

            probtrackx2 -x $Left_HC -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=$folder_dti/xfms/str2diff.mat --invxfm=$folder_dti/xfms/diff2str.mat --wtstop=$Left_EC --forcedir --opd -s $folder_dti/merged -m $folder_dti/nodif_brain_mask --dir=$subject/probtrackX/left_masks/HC --waypoints=waypoint_ec_left.txt  --waycond=AND >> Probtrack_LEFT_OUTPUT.txt 
            
            cd probtrackX/left_masks/HC
            mv fdt_paths.nii.gz left_HC_prob.nii.gz
            mv waytotal left_HC_way
            cd ../../..
            
            flirt -in $subject/probtrackX/left_masks/HC/fdt_paths.nii.gz -ref $subject/diff2registration.nii.gz -applyxfm -init $folder_dti/xfms/diff2str.mat -out $subject/probtrackX/left_masks/HC/left_HC_prob.nii.gz

            # HC PARA O EC, LEFT AND RIGHT!! 

            #Tem de ser com a nodif_brain_mask, precisa da binaria que foi usada no bedpostx

            probtrackx2  -x ../right_entorhinal.nii.gz   -l --onewaycondition -c 0.2 -S 2000 --steplength=0.5 -P 5000 --fibthresh=0.01 --distthresh=0.0 --sampvox=0.0 --xfm=Axial_DTI.bedpostX/xfms/standard2diff.mat --invxfm=Axial_DTI.bedpostX/xfms/diff2standard.mat --wtstop=../right_hippocampus.nii.gz --forcedir --opd -s Axial_DTI.bedpostX/merged -m Axial_DTI.bedpostX/nodif_brain_mask  --dir=Axial_DTI.bedpostX/masks --waypoints=waypoints.txt  --waycond=AND 

            echo "Finished processing leftside for subject ($INDEX/$FILE_LIST_SIZE):" $subject

            #Save end time
            ENDTIME=`date +%s%N`

            #Compute elapsed time
            elapsed=$(($ENDTIME -$STARTTIME))

            #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
            echo "$elapsed,$FILE" >> $subject/results_probtrackX.txt
            fi
        cd ../
        #Increment INDEX
        let INDEX=${INDEX}+1
                    
done