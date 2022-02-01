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
            if [[ -n $(find $subject -maxdepth 1 -mindepth 1 -type d -name "*Sag*IR*FSPGR*" -o -name "*MP*RAGE*") ]]
            then  
                Folder=`find $subject -maxdepth 1 -mindepth 1 -type d -name "Axial*DTI"`
                folder_list=($Folder)
                folder_dti=${folder_list[0]}
                cd "$folder_dti"
                DTI=`find $subject -type f -name "eddy_output.nii.gz"` 
                bval=`find $subject -type f -name "*.bval"`
                bvec=`find $subject -type f -name "*eddy_output*.*bvecs"` # do eddy!! 
                masks=`find $subject -type f -name "*DTI*_mask.nii.gz"`
                files_dti=($DTI)
                bval_files=($bval)
                bvec_files=($bvec)
                mask_files=($masks)
                files_list=${files_dti[0]}
                bval_file=${bval_files[0]}
                bvec_file=${bvec_files[0]}
                mask_file=${mask_files[0]}
                echo $files_list
                echo $bval_file
                echo $bvec_file
                echo $mask_file

                #expects to find bvals and bvecs in subject directory
                #expects to find data and nodif_brain_mask in subject directory
                #tem de ter os nomes assim, bvals, bvecs, data e nodif_brain_mask

                #https://www.cyberciti.biz/faq/bash-rename-files/
                mv $files_list data.nii.gz
                mv $bval_file bvals
                mv $bvec_file bvecs
                mv $mask_file nodif_brain_mask.nii.gz

                cd ..

                #Return which file is being processed
                echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject/$folder_list
                echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject/$folder_list >> $OUTPUT_DIR/bedpost_OUTPUT.txt
                #Save start time
                STARTTIME=`date +%s%N`

                #Run the command
                bedpostx $folder_dti # #$OUTPUT_DIR/$RELATIVE_PATH


                echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject

                #Save end time
                ENDTIME=`date +%s%N`

                #Compute elapsed time
                elapsed=$(($ENDTIME -$STARTTIME))

                #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_bedpostx.txt
                else 
                    echo "No Structural folder" >> $OUTPUT_DIR/NO_FOLDER.txt
                fi
            else 
                echo "No Diffusion folder" >> $OUTPUT_DIR/NO_FOLDER.txt
            fi
        cd ..
        echo "Processed subject ($INDEX/$FILE_LIST_SIZE):" $subject/$folder_list >> $OUTPUT_DIR/bedpost_OUTPUT.txt
        let INDEX=${INDEX}+1
        #Increment INDEX
        
    done

        
           
