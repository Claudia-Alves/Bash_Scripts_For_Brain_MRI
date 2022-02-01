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

mkdir -p $OUTPUT_DIR/myTBSS

for subject in $subject_list; 
    do 
        cd "$subject"
       # Folder= `find $INPUT_DIR -type d -name "*DTI*"`
       
        DTI=`find $subject -type f -name "dtifit_output_FA.nii.gz"`      
        masks=`find $subject -type f -name "*DTI*_mask.nii.gz"`
        mask_files=($masks)
        mask_file=${mask_files[0]}
        
        #Return which file is being processed
        echo "Creating FA folder with info from subject ($INDEX/$FILE_LIST_SIZE):" $subject
        #Save start time
        STARTTIME=`date +%s%N`

        #change the names
        echo "fileeee $DTI"
        NAME="$(basename $subject)"
        
        echo "Subject $NAME" 
        cp $DTI {$NAME}_dtifit_output_FA.nii.gz
        mv $DTI {$NAME}_dtifit_FA_FA.nii.gz
        cp {$NAME}_dtifit_FA_FA.nii.gz ../myTBSS
        
        #https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/TBSS/UserGuide
        
        echo "Finished creating FA folder with info from subject ($INDEX/$FILE_LIST_SIZE):" $subject

        #Save end time
        ENDTIME=`date +%s%N`

        #Compute elapsed time
        elapsed=$(($ENDTIME -$STARTTIME))

        #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
        echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_cp_FA.txt
        
        let INDEX=${INDEX}+1
        cd ..
        #Increment INDEX
        
done

cd $OUTPUT_DIR/myTBSS

echo "Processing $FILE_LIST_SIZE subjects:"
#Save start time
STARTTIME=`date +%s%N`

tbss_1_preproc *.nii.gz

tbss_2_reg -n # usar a -n (compara cada sujeito com todos os outros e escolhe o mais representativo) vs -T 

tbss_3_postreg -S # escolhe o mais representativo (-S) e alinha todos com essse

tbss_4_prestats 0.3 # 0.3 é melhor, verificar a imagem (se é melhor 0.2, 0.3, etc)
                            
echo "Finished processing $FILE_LIST_SIZE subjects."
 
#Save end time
ENDTIME=`date +%s%N`

#Compute elapsed time
elapsed=$(($ENDTIME -$STARTTIME))

#Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_TBSS.txt
