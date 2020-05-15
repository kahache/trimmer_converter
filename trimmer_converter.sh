#!/bin/bash
#__author__ = "Ka Hache a.k.a. The One & Only Javi"
#__version__ = "2.0.0"
#__start_date__ = "25 July 2018"
#__end_date__ = "25 October 2018""
#__maintainer__ = "me myself & I"
#__email__ = "little_kh@hotmail.com"
#__requirements__ = ""
#__status__ = "Production"
#__description__ = "This script identifies if there are video recordings higher from 1 hour and puts them in other place. Then it trims the files"
#It's useful to change from an EPG trimming and avoid big files
#__Origniality stands alone!!_


#We declare variables. In this case is the input and output folder
INPUT_FOLDER=/home/user/encoder_output1
OUTPUT_FOLDER=/home/user/video1/processed
#testing purposes OUTPUT_FOLDER=/var/tmp
BIGGER1H_FOLDER=/home/user/video1/bigger1h
KEYNAME="encoder_video_output1"
EXTENSION="mp4"
LOG=/var/log/trimmer_converter.log

#Logging function
function to_log(){
        echo "$1" | logger -t trimmer_converter.sh -i
        echo "[`date`]: $1" >> $LOG
        echo "$1"
}


#We need to cut files longer than 1 hour due to Vericast matching reasons. We process it:
for FILE in $INPUT_FOLDER/*.mp4;  do 
	DURATION=`ffmpeg -i $FILE  2>&1 | grep Duration |  awk '{print $2}' | cut -d ":" -f 1` 
	if [ "$DURATION" == "00" ]
	then
		to_log "$FILE It can be processed"
		mv $FILE $OUTPUT_FOLDER >> $LOG
	else
	
		to_log "$FILE Can't be processed"
		mv $FILE $BIGGER1H_FOLDER >> $LOG
	fi
done


#Then we go with the trim of the files that were bigger than 1 hour
for FILE in $BIGGER1H_FOLDER/*.mp4;  do
	 to_log "Starting $FILE trim"
	 DURATION=`ffmpeg -i $FILE  2>&1 | grep Duration |  awk '{print $2}' | cut -d ":" -f 1` >> $LOG
         COUNTER=0
         while [ $COUNTER -le ${DURATION} ] 
	        do
			to_log "Starting with counter $COUNTER"
                	FILE_DATE=`echo $FILE | cut -d "_" -f 3`
	                FILE_TIME=`echo $FILE | cut -d "_" -f 4 | cut -d "." -f 1 `
        	        to_log "Original hour for $FILE is $FILE_DATE $FILE_TIME"
        	       	NEW_DATE_TIME=`date -d "$FILE_DATE ${FILE_TIME:0:2}:${FILE_TIME:2:2}:${FILE_TIME:4:2} ${COUNTER} hours" +'%Y%m%d_%H%M%S'`
                	to_log "New hour of $FILE is $NEW_DATE_TIME"
			to_log "Starting process ffmpeg -i $FILE -ss ${COUNTER}:00:00 -t 3600 $OUTPUT_FOLDER/${KEYNAME}_`hostname`_$NEW_DATE_TIME.${EXTENSION}"  
			ffmpeg -i $FILE -ss ${COUNTER}:00:00 -t 3600 $OUTPUT_FOLDER/${KEYNAME}_`hostname`_$NEW_DATE_TIME.${EXTENSION}
			chown user:user $OUTPUT_FOLDER/${KEYNAME}_`hostname`_$NEW_DATE_TIME.${EXTENSION}
			to_log "File ${KEYNAME}_`hostname`_$NEW_DATE_TIME.${EXTENSION} processed"
	                let COUNTER=COUNTER+1
        	        to_log "New counter is $COUNTER"
	        #       rm $FILE
        	done
done

#TO_DOS
#Convert the both bucles into functions
#-Work only with closed files, not operate the processed one
#-Redirect text info of 00 or 01 to /dev/null 
