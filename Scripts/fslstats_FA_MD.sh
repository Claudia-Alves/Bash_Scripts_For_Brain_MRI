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


mkdir -p $OUTPUT_DIR
#touch $OUTPUT_DIR/results_cp_files.txt

#Get list of files in input directory
subject_list=`find $INPUT_DIR -mindepth 1 -maxdepth 1 -type d -name "*_S_*"` 


#COnvert the list of files in an array
arr=($subject_list)

#Get the length of the array to provide status below
FILE_LIST_SIZE=${#arr[@]}

#initialize index to 1

INDEX=1

touch STATS_recent.txt
#Loop accross every nifti files in the input directory
for subject in $subject_list; 
    do 
        #echo "$subject"
        cd "$subject"
        
        if [[ -n $(find $subject  -type f -name "dtifit_FA_2registration.nii.gz" ) ]] # 
        then
            if [[ -n $(find $subject -type f -name "right_HC_prob.nii.gz" ) ]]
            then
                File=`find $subject -type f -name 'dtifit_FA_2registration.nii.gz' ` # 
                MD_file=`find $subject -type f -name 'dtifit_MD_2registration.nii.gz' `
                L1_file=`find $subject -type f -name 'dtifit_L1_2registration.nii.gz' `
                L2_file=`find $subject -type f -name 'dtifit_L2_2registration.nii.gz' `
                L3_file=`find $subject -type f -name 'dtifit_L3_2registration.nii.gz' `
                Mask_R_EC1=`find $subject -type f -name 'right_EC_prob.nii.gz' `
                Mask_R_HC1=`find $subject -type f -name 'right_HC_prob.nii.gz' `
                Mask_L_EC1=`find $subject -type f -name 'left_EC_prob.nii.gz' `
                Mask_L_HC1=`find $subject -type f -name 'left_HC_prob.nii.gz' `
                right_EC_way1=`find $subject -type f -name 'right_EC_way' ` #aqui é para ir buscar o valor do way total da trato
                right_HC_way1=`find $subject -type f -name 'right_HC_way' `
                left_EC_way1=`find $subject -type f -name 'left_EC_way' `
                left_HC_way1=`find $subject -type f -name 'left_HC_way' `
                
                #Create a new directory if the directory does not exist 
                #mkdir -p $OUTPUT_DIR/$RELATIVE_PATH
                right_EC_way=`cat $right_EC_way1`
                right_HC_way=`cat $right_HC_way1`
                left_EC_way=`cat $left_EC_way1`
                left_HC_way=`cat $left_HC_way1`
                
                #NOTA:: TENTA SÓ FAZER O THRESHOLDING, SEM A DIVISÃO PELO WAYTOTAL --> Assim já dá valores
                fslmaths $Mask_R_EC1 -div $right_EC_way right_EC_prob_norm.nii.gz -odt input
                fslmaths $Mask_R_HC1 -div $right_HC_way right_HC_prob_norm.nii.gz -odt input
                fslmaths $Mask_L_EC1 -div $left_EC_way left_EC_prob_norm.nii.gz -odt input
                fslmaths $Mask_L_HC1 -div $left_HC_way left_HC_prob_norm.nii.gz -odt input
                
                
                Mask_R_EC3=`find $subject -type f -name 'right_EC_prob_norm.nii.gz' `
                Mask_R_HC3=`find $subject -type f -name 'right_HC_prob_norm.nii.gz' `
                Mask_L_EC3=`find $subject -type f -name 'left_EC_prob_norm.nii.gz' `
                Mask_L_HC3=`find $subject -type f -name 'left_HC_prob_norm.nii.gz' `
                
                
                #Mask_R_EC21=`echo "${Mask_R_EC3%%.*}"`
                Mask_R_EC21=$(basename -- "$Mask_R_EC3")
                #Mask_R_EC2=`echo "${Mask_R_EC21%%.*}"`
                
                
                Mask_R_HC21=$(basename -- "$Mask_R_HC3")
                #Mask_R_HC2=`echo "${Mask_R_HC21%%.*}"`
                
                Mask_L_EC21=$(basename -- "$Mask_L_EC3")
                #Mask_L_EC2=`echo "${Mask_L_EC21%%.*}"`
                
                Mask_L_HC21=$(basename -- "$Mask_L_HC3")
                #Mask_L_HC2=`echo "${Mask_L_HC21%%.*}"`
                
                #NOTA:: TENTA SÓ FAZER O THRESHOLDING, SEM A DIVISÃO PELO WAYTOTAL (ou seja, em vez de EC2 usar EC1) --> assim já deu valores
                high_thres_R_EC1=`fslstats $Mask_R_EC1 -R | awk '{print $2}'`
                high_thres_R_HC1=`fslstats $Mask_R_HC1 -R | awk '{print $2}'`
                high_thres_L_EC1=`fslstats $Mask_L_EC1 -R | awk '{print $2}'`
                high_thres_L_HC1=`fslstats $Mask_L_HC1 -R | awk '{print $2}'`
                
                echo "high R EC1 $high_thres_R_EC1"
                echo "high R HC1 $high_thres_R_HC1"
                
                high_thres_R_EC=$( echo "scale=6; $high_thres_R_EC1*0.001" | bc)
                high_thres_R_HC=$( echo "scale=6; $high_thres_R_HC1*0.001" | bc)
                high_thres_L_EC=$( echo "scale=6; $high_thres_L_EC1*0.001" | bc)
                high_thres_L_HC=$( echo "scale=6; $high_thres_L_HC1*0.001" | bc)
                
                echo "high R EC $high_thres_R_EC"
                echo "high R HC $high_thres_R_HC"
                
                #NOTA:: TENTA SÓ FAZER O THRESHOLDING, SEM A DIVISÃO PELO WAYTOTAL (ou seja, em vez de EC2 usar EC1)
                fslmaths $Mask_R_EC1 -thr $high_thres_R_EC right_EC_prob_norm_thr.nii.gz -odt input
                fslmaths $Mask_R_HC1 -thr $high_thres_R_HC right_HC_prob_norm_thr.nii.gz -odt input
                fslmaths $Mask_L_EC1 -thr $high_thres_L_EC left_EC_prob_norm_thr.nii.gz -odt input
                fslmaths $Mask_L_HC1 -thr $high_thres_L_HC left_HC_prob_norm_thr.nii.gz -odt input
                 
                
                Mask_R_EC=`find $subject -type f -name 'right_EC_prob_norm_thr.nii.gz' ` #_thr
                Mask_R_HC=`find $subject -type f -name 'right_HC_prob_norm_thr.nii.gz' ` #_thr
                Mask_L_EC=`find $subject -type f -name 'left_EC_prob_norm_thr.nii.gz' ` #_thr
                Mask_L_HC=`find $subject -type f -name 'left_HC_prob_norm_thr.nii.gz' ` #_thr
                
                echo "check -R Mask_R_EC"
                fslstats $Mask_R_EC -R
                echo "check -m Mask_R_EC"
                fslstats $Mask_R_EC -m
                echo "check -M Mask_R_EC"
                fslstats $Mask_R_EC -M
                Mask_R_EC_y=$(basename -- "$Mask_R_EC_thr")
                Mask_R_EC=`echo "${Mask_R_EC_y%%.*}"`
                #echo "cfd $Mask_R_EC2"
                
                Mask_R_HC_y=$(basename -- "$Mask_R_HC_thr")
                Mask_R_HC=`echo "${Mask_R_HC_y%%.*}"`
                
                Mask_L_EC_y=$(basename -- "$Mask_L_EC_thr")
                Mask_L_EC=`echo "${Mask_L_EC_y%%.*}"`
                
                Mask_L_HC_y=$(basename -- "$Mask_L_HC_thr")
                Mask_L_HC=`echo "${Mask_L_HC_y%%.*}"`
                
                #echo "$Mask_R_HC_y $Mask_R_HC"
                
                echo "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"

                #Return which file is being processed
                echo "Processing subject ($INDEX/$FILE_LIST_SIZE):" $subject
                
                #Save start time
                STARTTIME=`date +%s%N`

                echo " Mean FA of Right EC for $(basename $subject)"
                fslstats $File -k $Mask_R_EC -M  
                echo " Mean FA of Right HC for $(basename $subject)"
                fslstats $File -k $Mask_R_HC -M
                echo " Mean FA of Left EC for $(basename $subject)"
                fslstats $File -k $Mask_L_EC -M
                echo " Mean FA of Left HC for $(basename $subject)"
                fslstats $File -k $Mask_L_HC -M

                echo "############"

                echo " Mean MD of Right EC for $(basename $subject)"
                fslstats $MD_file -k $Mask_R_EC -M 
                echo " Mean MD of Right HC for $(basename $subject)"
                fslstats $MD_file -k $Mask_R_HC -M
                echo " Mean MD of Left EC for $(basename $subject)"
                fslstats $MD_file -k $Mask_L_EC -M
                echo " Mean MD of Left HC for $(basename $subject)"
                fslstats $MD_file -k $Mask_L_HC -M
                
                echo "############"

                echo " Mean L1 of Right EC for $(basename $subject)"
                fslstats $L1_file -k $Mask_R_EC -M 
                echo " Mean L1 of Right HC for $(basename $subject)"
                fslstats $L1_file -k $Mask_R_HC -M
                echo " Mean L1 of Left EC for $(basename $subject)"
                fslstats $L1_file -k $Mask_L_EC -M
                echo " Mean L1 of Left HC for $(basename $subject)"
                fslstats $L1_file -k $Mask_L_HC -M
                
                echo "############"

                echo " Mean L2 of Right EC for $(basename $subject)"
                fslstats $L2_file -k $Mask_R_EC -M 
                echo " Mean L2 of Right HC for $(basename $subject)"
                fslstats $L2_file -k $Mask_R_HC -M
                echo " Mean L2 of Left EC for $(basename $subject)"
                fslstats $L2_file -k $Mask_L_EC -M
                echo " Mean L2 of Left HC for $(basename $subject)"
                fslstats $L2_file -k $Mask_L_HC -M
                
                echo "############"

                echo " Mean L3 of Right EC for $(basename $subject)"
                fslstats $L3_file -k $Mask_R_EC -M 
                echo " Mean L3 of Right HC for $(basename $subject)"
                fslstats $L3_file -k $Mask_R_HC -M
                echo " Mean L3 of Left EC for $(basename $subject)"
                fslstats $L3_file -k $Mask_L_EC -M
                echo " Mean L3 of Left HC for $(basename $subject)"
                fslstats $L3_file -k $Mask_L_HC -M

                echo "############"

                echo " Volume of Right EC for $(basename $subject)"
                fslstats $Mask_R_EC -V
                echo " Volume of Right HC for $(basename $subject)"
                fslstats $Mask_R_HC -V
                echo " Volume of Left EC for $(basename $subject)"
                fslstats $Mask_L_EC -V
                echo " Volume of Left HC for $(basename $subject)"
                fslstats $Mask_L_HC -V    

                echo "$(basename $INPUT_DIR)" >> $INPUT_DIR/STATS_recent.txt
                echo "$(basename $subject)" >> $INPUT_DIR/STATS_recent.txt

                #echo " Mean FA of Right EC for $(basename $subject)" 
                fslstats $File -k $Mask_R_EC -M  >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean FA of Right HC for $(basename $subject)" 
                fslstats $File -k $Mask_R_HC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean FA of Left EC for $(basename $subject)" 
                fslstats $File -k $Mask_L_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean FA of Left HC for $(basename $subject)" 
                fslstats $File -k $Mask_L_HC -M >> $INPUT_DIR/STATS_recent.txt

                echo "############"  >> $INPUT_DIR/STATS_recent.txt

                #echo " Mean MD of Right EC for $(basename $subject)" 
                fslstats $MD_file -k $Mask_R_EC -M  >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean MD of Right HC for $(basename $subject)"  
                fslstats $MD_file -k $Mask_R_HC -M  >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean MD of Left EC for $(basename $subject)"  
                fslstats $MD_file -k $Mask_L_EC -M  >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean MD of Left HC for $(basename $subject)"  
                fslstats $MD_file -k $Mask_L_HC -M  >> $INPUT_DIR/STATS_recent.txt
                
                echo "############" >> $INPUT_DIR/STATS_recent.txt

                #echo " Mean L2 of Right EC for $(basename $subject)"
                fslstats $L1_file -k $Mask_R_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Right HC for $(basename $subject)"
                fslstats $L1_file -k $Mask_R_HC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Left EC for $(basename $subject)"
                fslstats $L1_file -k $Mask_L_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Left HC for $(basename $subject)"
                fslstats $L1_file -k $Mask_L_HC -M >> $INPUT_DIR/STATS_recent.txt
                
                echo "############" >> $INPUT_DIR/STATS_recent.txt

                #echo " Mean L2 of Right EC for $(basename $subject)"
                fslstats $L2_file -k $Mask_R_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Right HC for $(basename $subject)"
                fslstats $L2_file -k $Mask_R_HC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Left EC for $(basename $subject)"
                fslstats $L2_file -k $Mask_L_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L2 of Left HC for $(basename $subject)"
                fslstats $L2_file -k $Mask_L_HC -M >> $INPUT_DIR/STATS_recent.txt
                
                echo "############" >> $INPUT_DIR/STATS_recent.txt

                #echo " Mean L3 of Right EC for $(basename $subject)"
                fslstats $L3_file -k $Mask_R_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L3 of Right HC for $(basename $subject)"
                fslstats $L3_file -k $Mask_R_HC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L3 of Left EC for $(basename $subject)"
                fslstats $L3_file -k $Mask_L_EC -M >> $INPUT_DIR/STATS_recent.txt
                #echo " Mean L3 of Left HC for $(basename $subject)"
                fslstats $L3_file -k $Mask_L_HC -M >> $INPUT_DIR/STATS_recent.txt

                echo "############"  >> $INPUT_DIR/STATS_recent.txt

                #echo " Volume of Right EC for $(basename $subject)" 
                fslstats $Mask_R_EC -V  >> $INPUT_DIR/STATS_recent.txt
                #echo " Volume of Right HC for $(basename $subject)"
                fslstats $Mask_R_HC -V  >> $INPUT_DIR/STATS_recent.txt
                #echo " Volume of Left EC for $(basename $subject)" 
                fslstats $Mask_L_EC -V  >> $INPUT_DIR/STATS_recent.txt
                #echo " Volume of Left HC for $(basename $subject)" 
                fslstats $Mask_L_HC -V  >> $INPUT_DIR/STATS_recent.txt

                echo "Finished processing subject ($INDEX/$FILE_LIST_SIZE):" $subject 
                echo "--------------------------------------------------------" 
                #Save end time
                ENDTIME=`date +%s%N`

                #Compute elapsed time
                elapsed=$(($ENDTIME -$STARTTIME))

                #Append the elapsed time and the file path to results.txt. This file contains the elapsed time of all the files processed
                #echo "$elapsed,$FILE" >> ../$OUTPUT_DIR/results_cp_files.txt

                else
                    echo "No probtrackX output output found. $subject" 
                    echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_recent.txt
                    echo "No probtrackX output output found. $subject" >> $INPUT_DIR/STATS_recent.txt
                    echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_recent.txt
                fi
            else
                echo "No DTIFIT output found. $subject"
                echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_recent.txt
                echo "No DTIFIT output found. $subject" >> $INPUT_DIR/STATS_recent.txt      
                echo "--------------------------------------------------------"  >> $INPUT_DIR/STATS_recent.txt
            fi
            cd ..
            #Increment INDEX
            let INDEX=${INDEX}+1
done


