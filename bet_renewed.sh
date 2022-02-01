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
FILE_LIST=`find $INPUT_DIR -maxdepth 4 -mindepth 1 -type f -name '*DTI*.nii' ` 


arr=($FILE_LIST)

FILE_LIST_SIZE=${#arr[@]}

INDEX=1

#Loop accross every nifti files in the input directory
for FILE in $FILE_LIST
do
    #Removes the content of INPUT_DIR and removes the extensions, keeping the "relative path" and file name
    RELATIVE_PATH=${FILE#"$INPUT_DIR/"}
    RELATIVE_PATH=${RELATIVE_PATH%%.*}
    
    #Create a new directory if the directory does not exist 
    mkdir -p $OUTPUT_DIR/$RELATIVE_PATH
    
    #Return which file is being processed
    echo "Processing file ($INDEX/$FILE_LIST_SIZE):" $RELATIVE_PATH >> $OUTPUT_DIR/bet_OUTPUT.txt
    echo "Processing file ($INDEX/$FILE_LIST_SIZE):" $RELATIVE_PATH
    #Save start time
    STARTTIME=`date +%s%N`
    #Run the command
    
    bet $FILE $OUTPUT_DIR/$RELATIVE_PATH -m -f 0.3  #FUNCIONA, FAZ O BET E COLOCA NO LOCAL DESEJADO
    
    #Save end time
    ENDTIME=`date +%s%N`
    
    #Compute elapsed time
    elapsed=$(($ENDTIME -$STARTTIME))
    
    #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
    echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_bet_tracto.txt
    
    # cd ..
    #Increment INDEX
    let INDEX=${INDEX}+1
done