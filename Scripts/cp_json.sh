#!/bin/bash


#Print usage of script
usage () { echo "$(basename "$0") [-h] -i input_directory -o output_directory -- program to copy json to the main subject folder in order for recon-all to work

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


#Get list of files in input directory
FILE_LIST=`find $INPUT_DIR -maxdepth 3 -mindepth 1 -type f -name '*DTI*.json'`


#COnvert the list of files in an array
arr=($FILE_LIST)

#Get the length of the array to provide status below
FILE_LIST_SIZE=${#arr[@]}

#initialize index to 1
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
    echo "Processing folder ($INDEX/$FILE_LIST_SIZE):" $RELATIVE_PATH
    
    if [[ -n $(find $OUTPUT_DIR/$RELATIVE_PATH -maxdepth 3 -type f -name "*DTI*.json") ]]
        then
            echo "Processing folder ($INDEX/$FILE_LIST_SIZE):" $RELATIVE_PATH
            echo "Files were already copied."
        else 
        #Save start time
        STARTTIME=`date +%s%N`
        #Run the command
        cp -u $FILE $OUTPUT_DIR/$RELATIVE_PATH 

        echo "Copying $FILE to  folder $OUTPUT_DIR/$RELATIVE_PATH "

        #Save end time
        ENDTIME=`date +%s%N`

        #Compute elapsed time
        elapsed=$(($ENDTIME -$STARTTIME))

        #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
        echo "$elapsed,$FILE" >> $OUTPUT_DIR/results_cp_json_for_DTI.txt
    fi
    #Increment INDEX
    let INDEX=${INDEX}+1
done
