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

subject_list=`find $INPUT_DIR -maxdepth 1 -mindepth 1 -type d -name "*_S_*"` 

arr=($subject_list)

FILE_LIST_SIZE=${#arr[@]}

INDEX=1

for subject in $subject_list; 
    do 
        cd "$subject"
        if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "Axial*DTI*") ]]
        then  
            Folder=`find $subject -maxdepth 1 -mindepth 1 -type d -name "Axial*DTI*"`
            folder_list=($Folder)
            folder_dti=${folder_list[0]}
            cd "$folder_dti"
            DTI=`find $subject -type f -name "eddy_output.nii.gz" -o -name "data.nii.gz" ` 
            bval=`find $subject -type f -name "*.bval" -o -name "bvals"`
            bvec=`find $subject -type f -name "*eddy_output*.*bvecs" -o -name "bvecs"` #ir buscar os rodados depois do eddy!! 
            masks=`find $subject -type f -name "*DTI*_mask.nii.gz" -o -name "nodif_brain_mask.nii.gz"`
            files_dti=($DTI)
            bval_files=($bval)
            bvec_files=($bvec)
            mask_files=($masks)
            files_list=${files_dti[0]}
            bval_file=${bval_files[0]}
            bvec_file=${bvec_files[0]}
            mask_file=${mask_files[0]}
            echo $files_list >> $OUTPUT_DIR/dtifit_OUTPUT.txt
            echo $bval_file >> $OUTPUT_DIR/dtifit_OUTPUT.txt
            echo $bvec_file >> $OUTPUT_DIR/dtifit_OUTPUT.txt
            echo $mask_file >> $OUTPUT_DIR/dtifit_OUTPUT.txt
            #Return which file is being processed
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject
            echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_OUTPUT.txt
            #Save start time
            STARTTIME=`date +%s%N`

            #Run the script
            dtifit --data=$files_list --mask=$mask_file --bvecs=$bvec_file --bvals=$bval_file --out=dtifit_output 
            
            mkdir -p $folder_dti/xfms_dtifit
            
            if [[ -n $(find $folder_dti -maxdepth 1 -mindepth 1 -type d -name "dtifit_output_FA.nii.gz") ]]
            then
                masks=`find $subject -type f -name "dtifit_output_FA.nii.gz" ` 
                echo "Structural"
                Structural1=`find $subject -type f -name "brain.mgz" `
                #echo "strcutural one $Structural1"
                mri_convert $Structural1 brain.nii.gz 
                #echo "Converted"
                Structural=`find $subject -type f -name "brain.nii.gz"`
                echo "estrutrural" $Structural
                mask_files=($masks)
                Struct_files=($Structural) 
                mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                struct_file=${Struct_files[0]}

                echo "Processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                echo "Processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                flirt -in $mask_file -ref $struct_file -out dtifit_FA_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_FA_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                convert_xfm -omat $Folder_dti/xfms/str2dtifit_FA.mat -inverse $folder_dti/xfms_dtifit/dtifit_FA_2str.mat

                flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                convert_xfm -omat $Folder_dti/xfms/dtifit_FA_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_FA_2str.mat 

                convert_xfm -omat $Folder_dti/xfms/standard2dtifit_FA.mat -inverse $folder_dti/xfms_dtifit/dtifit_FA_2standard.mat

                echo "Finished processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                masks=`find $subject -type f -name "dtifit_output_MD.nii.gz" ` 
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

                echo "Processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                echo "Processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                flirt -in $mask_file -ref $struct_file -out dtifit_MD_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 
                flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_MD_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                convert_xfm -omat $Folder_dti/xfms/str2dtifit_MD.mat -inverse $folder_dti/xfms_dtifit/dtifit_MD_2str.mat

                flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                convert_xfm -omat $Folder_dti/xfms/dtifit_MD_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_MD_2str.mat 

                convert_xfm -omat $Folder_dti/xfms/standard2dtifit_MD.mat -inverse $folder_dti/xfms_dtifit/dtifit_MD_2standard.mat

                echo "Finished processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                masks=`find $subject -type f -name "dtifit_output_L1.nii.gz" ` 
                Structural=`find $subject -type f -name "brain.nii.gz"`
                echo "estrutrural" $Structural
                mask_files=($masks)
                Struct_files=($Structural) 
                mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                struct_file=${Struct_files[0]}

                echo "Processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                echo "Processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                flirt -in $mask_file -ref $struct_file -out dtifit_L1_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 
                flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L1_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                convert_xfm -omat $Folder_dti/xfms/str2dtifit_L1.mat -inverse $folder_dti/xfms_dtifit/dtifit_L1_2str.mat

                flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                convert_xfm -omat $Folder_dti/xfms/dtifit_L1_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L1_2str.mat 

                convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L1.mat -inverse $folder_dti/xfms_dtifit/dtifit_L1_2standard.mat

                echo "Finished processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject
                
                masks=`find $subject -type f -name "dtifit_output_L2.nii.gz" ` 
                Structural=`find $subject -type f -name "brain.nii.gz"`
                mask_files=($masks)
                Struct_files=($Structural) 
                mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                struct_file=${Struct_files[0]}

                echo "Processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                echo "Processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                flirt -in $mask_file -ref $struct_file -out dtifit_L2_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L2_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                convert_xfm -omat $Folder_dti/xfms/str2dtifit_L2.mat -inverse $folder_dti/xfms_dtifit/dtifit_L2_2str.mat

                flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                convert_xfm -omat $Folder_dti/xfms/dtifit_L2_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L2_2str.mat 

                convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L2.mat -inverse $folder_dti/xfms_dtifit/dtifit_L2_2standard.mat

                echo "Finished processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject
                
                masks=`find $subject -type f -name "dtifit_output_L3.nii.gz" ` 
                Structural=`find $subject -type f -name "brain.nii.gz"`
                echo "estrutrural" $Structural
                mask_files=($masks)
                Struct_files=($Structural) 
                mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                struct_file=${Struct_files[0]}

                echo "Processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                echo "Processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                flirt -in $mask_file -ref $struct_file -out dtifit_L3_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L3_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                convert_xfm -omat $Folder_dti/xfms/str2dtifit_L3.mat -inverse $folder_dti/xfms_dtifit/dtifit_L3_2str.mat

                flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                convert_xfm -omat $Folder_dti/xfms/dtifit_L3_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L3_2str.mat 

                convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L3.mat -inverse $folder_dti/xfms_dtifit/dtifit_L3_2standard.mat

                echo "Finished processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

                #Save end time
                ENDTIME=`date +%s%N`

                #Compute elapsed time
                elapsed=$(($ENDTIME -$STARTTIME))

                #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_dtifit.txt
                else
                    masks=`find $subject -type f -name "dtifit_output_FA.nii.gz" `
                    masks1=`find $subject -type f -name "dtifit_output_MD.nii.gz" `
                    masks2=`find $subject -type f -name "dtifit_output_L1.nii.gz" `
                    masks3=`find $subject -type f -name "dtifit_output_L2.nii.gz" `
                    masks4=`find $subject -type f -name "dtifit_output_L3.nii.gz" `
                    
                    mv $masks $folder_dti
                    mv $masks1 $folder_dti
                    mv $masks2 $folder_dti
                    mv $masks3 $folder_dti
                    mv $masks4 $folder_dti
                    
                    masks=`find $subject -type f -name "dtifit_output_FA.nii.gz" ` 
                    echo "Structural"
                    Structural1=`find $subject -type f -name "brain.mgz" ` 
                    #echo "strcutural one $Structural1"
                    mri_convert $Structural1 brain.nii.gz 
                    #echo "Converted"
                    Structural=`find $subject -type f -name "brain.nii.gz"`
                    echo "estrutrural" $Structural
                    mask_files=($masks)
                    Struct_files=($Structural) 
                    mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                    struct_file=${Struct_files[0]}

                    echo "Processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                    echo "Processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                    #Save start time
                    STARTTIME=`date +%s%N`

                    #Run the command
                    flirt -in $mask_file -ref $struct_file -out dtifit_FA_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                    flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_FA_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                    convert_xfm -omat $Folder_dti/xfms/str2dtifit_FA.mat -inverse $folder_dti/xfms_dtifit/dtifit_FA_2str.mat

                    flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                    convert_xfm -omat $Folder_dti/xfms/dtifit_FA_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_FA_2str.mat 

                    convert_xfm -omat $Folder_dti/xfms/standard2dtifit_FA.mat -inverse $folder_dti/xfms_dtifit/dtifit_FA_2standard.mat

                    echo "Finished processing dtifit FA registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                    masks=`find $subject -type f -name "dtifit_output_MD.nii.gz" ` 
                    echo "Structural"
                    
                    Structural=`find $subject -type f -name "brain.nii.gz"`
                    echo "estrutrural" $Structural
                    mask_files=($masks)
                    Struct_files=($Structural) 
                    mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                    struct_file=${Struct_files[0]}

                    echo "Processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                    echo "Processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                    #Save start time
                    STARTTIME=`date +%s%N`

                    #Run the command
                    flirt -in $mask_file -ref $struct_file -out dtifit_MD_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                    flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_MD_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                    convert_xfm -omat $Folder_dti/xfms/str2dtifit_MD.mat -inverse $folder_dti/xfms_dtifit/dtifit_MD_2str.mat

                    flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                    convert_xfm -omat $Folder_dti/xfms/dtifit_MD_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_MD_2str.mat 

                    convert_xfm -omat $Folder_dti/xfms/standard2dtifit_MD.mat -inverse $folder_dti/xfms_dtifit/dtifit_MD_2standard.mat

                    echo "Finished processing dtifit MD registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                    masks=`find $subject -type f -name "dtifit_output_L1.nii.gz" ` 
                    echo "Structural"
                    
                    Structural=`find $subject -type f -name "brain.nii.gz"`
                    echo "estrutrural" $Structural
                    mask_files=($masks)
                    Struct_files=($Structural) 
                    mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                    struct_file=${Struct_files[0]}

                    echo "Processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                    echo "Processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                    #Save start time
                    STARTTIME=`date +%s%N`

                    #Run the command
                    flirt -in $mask_file -ref $struct_file -out dtifit_L1_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L1_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                    convert_xfm -omat $Folder_dti/xfms/str2dtifit_L1.mat -inverse $folder_dti/xfms_dtifit/dtifit_L1_2str.mat

                    flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                    convert_xfm -omat $Folder_dti/xfms/dtifit_L1_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L1_2str.mat 

                    convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L1.mat -inverse $folder_dti/xfms_dtifit/dtifit_L1_2standard.mat

                    echo "Finished processing dtifit L1 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject
                    
                    masks=`find $subject -type f -name "dtifit_output_L2.nii.gz" ` 
                    echo "Structural"
                    
                    Structural=`find $subject -type f -name "brain.nii.gz"`
                    echo "estrutrural" $Structural
                    mask_files=($masks)
                    Struct_files=($Structural) 
                    mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                    struct_file=${Struct_files[0]}

                    echo "Processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                    echo "Processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                    #Save start time
                    STARTTIME=`date +%s%N`

                    #Run the command
                    flirt -in $mask_file -ref $struct_file -out dtifit_L2_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 

                    flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L2_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                    convert_xfm -omat $Folder_dti/xfms/str2dtifit_L2.mat -inverse $folder_dti/xfms_dtifit/dtifit_L2_2str.mat

                    flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                    convert_xfm -omat $Folder_dti/xfms/dtifit_L2_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L2_2str.mat 

                    convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L2.mat -inverse $folder_dti/xfms_dtifit/dtifit_L2_2standard.mat

                    echo "Finished processing dtifit L2 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject

                     masks=`find $subject -type f -name "dtifit_output_L3.nii.gz" ` 
                    echo "Structural"
                    
                    Structural=`find $subject -type f -name "brain.nii.gz"`
                    echo "estrutrural" $Structural
                    mask_files=($masks)
                    Struct_files=($Structural) 
                    mask_file=${mask_files[0]} #Isto era para o caso de haver mais que uma mask
                    struct_file=${Struct_files[0]}

                    echo "Processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject #/$folde_r_dti
                    echo "Processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject >> $OUTPUT_DIR/dtifit_registration.txt #/$folder_dti 
                    #Save start time
                    STARTTIME=`date +%s%N`

                    #Run the command
                    flirt -in $mask_file -ref $struct_file -out dtifit_L3_2registration.nii.gz -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio 
                    
                    flirt -in $mask_file -ref $struct_file -omat $folder_dti/xfms_dtifit/dtifit_L3_2str.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost mutualinfo

                    convert_xfm -omat $Folder_dti/xfms/str2dtifit_L3.mat -inverse $folder_dti/xfms_dtifit/dtifit_L3_2str.mat

                    flirt -in $struct_file -ref ../../../FSL/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz -omat $folder_dti/xfms_dtifit/str2standard.mat -searchrx -90 90 -searchry -90 90 -searchrz -90 90 -dof 12 -cost corratio

                    convert_xfm -omat $Folder_dti/xfms/standard2str.mat -inverse $folder_dti/xfms_dtifit/str2standard.mat

                    convert_xfm -omat $Folder_dti/xfms/dtifit_L3_2standard.mat -concat  $folder_dti/xfms_dtifit/str2standard.mat $folder_dti/xfms_dtifit/dtifit_L3_2str.mat 

                    convert_xfm -omat $Folder_dti/xfms/standard2dtifit_L3.mat -inverse $folder_dti/xfms_dtifit/dtifit_L3_2standard.mat

                    echo "Finished processing dtifit L3 registration for subject ($INDEX/$FILE_LIST_SIZE):" $subject


                    echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

                    #Save end time
                    ENDTIME=`date +%s%N`

                    #Compute elapsed time
                    elapsed=$(($ENDTIME -$STARTTIME))

                    #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                    echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_dtifit.txt
                    fi
            fi
        let INDEX=${INDEX}+1
        cd ../..
        #Increment INDEX
        
    done
                        
