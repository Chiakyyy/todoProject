#!/bin/sh

echo "\n\n-------------- todo dashboard --------------"

if [ $# -eq 0 ]; then
	CURRENT_DATE=$(date +%d-%m-%Y)
	echo "\n\nCompleted tasks:"
	awk -v date="$CURRENT_DATE" -v string="completed" '$5 == date && $7 == string' tasks.txt
	echo "\nIncompleted tasks:"
	awk -v date="$CURRENT_DATE" -v string="incompleted" '$5 == date && $7 == string' tasks.txt
fi

while true; do

echo "\n\n1. Create a task\n2. Update a task\n3. Delete a task\n4. Show all information about your tasks\n5. List tasks of a given day\n6. Search for a task\n7. Exit\n\n"

echo "Your choice:"
read CHOICE

if [ -n "$CHOICE" ] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le 7 ]; then
	if [ $CHOICE -eq 1 ]; then
		if [ -e tasks.txt ]; then
			echo "\nEnter the title,  a description, a location, a due date (YYYY-MM-DD) and time (HH:mm):"
			#read ID
			read TITLE
			read DESC
				if [ -z "$DESC" ]; then 
					DESC="null"
				fi
			read LOCATION
				if [ -z "$LOCATION" ]; then 
					LOCATION="null"
				fi
			read DATE
			read TIME
			COMPLETION="incompleted"
			ID=$(($(awk 'END {print $1}' tasks.txt) + 1))
			FORMATTED_DATE=$(date -d "$DATE" +'%d-%m-%Y' 2>/dev/null)
			#CHECK=$(awk -v title="$TITLE" '$2 == title {print $1}' tasks.txt)
			
			if [ -n "$TITLE" ] && [ -n "$DATE" ] && [ -n "$TIME" ]; then
				if [ -n "$FORMATTED_DATE" ]; then
					echo "$ID\t$TITLE\t$DESC\t$LOCATION\t$FORMATTED_DATE\t$TIME\t$COMPLETION" >> tasks.txt
					echo "\nTask added successfully."
				else
		   			echo "\nError: Invalid date format. Please enter the date in YYYY-MM-DD format."
				fi
			else
				echo "\n\nError: The title, due date and time are required"
			fi
		else
			touch tasks.txt
			echo "\ntasks file created\n"
		fi
	fi

	if [ $CHOICE -eq 2 ]; then
		echo "\n"
		awk 'BEGIN {FS=OFS="\t"} {if ($3 == "null") $3 = ""; if ($4 == "null") $4 = ""} 1' tasks.txt
		echo "\nEnter the id of the task you want to change: "
		read ID
		echo "\nWhat do you want to change ?(2. the title, 3. the description, 4. the location, 5. the due date, 6. the due time, 7. Mark task as completed): "
		read UPDATE
		
		if [ -n "$ID" ] && [ -n "$UPDATE" ] && [ "$UPDATE" -ge 2 ] && [ "$UPDATE" -le 7 ]; then
			if [ $UPDATE -eq 7 ]; then
				awk -v id="$ID" 'BEGIN {FS=OFS="\t"} NR==id {$7="completed"} 1' tasks.txt > temp && mv temp tasks.txt
				echo "\nTask updated successfully."
			else		
				echo "\nEnter the new content: "
				read NEW_CONTENT
				awk -v id="$ID" -v col="$UPDATE" -v new="$NEW_CONTENT" 'BEGIN {FS=OFS="\t"} NR==id {$col=new} 1' tasks.txt > temp && mv temp tasks.txt
				echo "\nTask updated successfully."
			fi
		else
			echo "\nError: Invalid entries"
		fi
	fi

	if [ $CHOICE -eq 3 ]; then
		echo "\n"
		awk 'BEGIN {FS=OFS="\t"} {if ($3 == "null") $3 = ""; if ($4 == "null") $4 = ""} 1' tasks.txt
		echo "\nEnter the id of the task you want to delete:"
		read DELETE
		if [ -n "$DELETE" ]; then
			#ID=$(awk -v title="$DELETE" '$2 == title {print $1}' tasks.txt)
			awk -v line="$DELETE" 'BEGIN {FS=OFS="\t"} {
						    if ($1 == line) {
							next;
						    } else if ($1 > line) {
							$1--;
						    }
						    print $0;
						}' tasks.txt > temp && mv temp tasks.txt
			echo "\nDeletion successful"
		else
			echo "\nError: Invalid entry"
		fi
	fi
	if [ $CHOICE -eq 4 ]; then
		echo "\n"
		#cat tasks.txt
		awk 'BEGIN {FS=OFS="\t"} {if ($3 == "null") $3 = ""; if ($4 == "null") $4 = ""} 1' tasks.txt
		#echo "\n"
		#awk '{print $6}' tasks.txt
	fi

	if [ $CHOICE -eq 5 ]; then
		echo "\nEnter the desired day (YYYY-MM-DD):"
		read DATE
		echo "\nEnter the desired time (HH:mm) (optional):"
		read TIME
		if [ -n "$DATE" ]; then
			FORMATTED_DATE=$(date -d "$DATE" +'%d-%m-%Y' 2>/dev/null)
			
			if [ -n "$FORMATTED_DATE" ]; then
				if [ -z "$TIME" ]; then
					echo "\nCompleted tasks:"
					awk -v date="$FORMATTED_DATE" -v string="completed" '$5 == date && $7 == string' tasks.txt
					echo "\nIncompleted tasks:"
					awk -v date="$FORMATTED_DATE" -v string="incompleted" '$5 == date && $7 == string' tasks.txt
				else
					echo "\nCompleted tasks:"
					awk -v date="$FORMATTED_DATE" -v time="$TIME" -v string="completed" '$5 == date && $6 == time && $7 == string' tasks.txt
					echo "\nIncompleted tasks:"
					awk -v date="$FORMATTED_DATE" -v time="$TIME" -v string="incompleted" '$5 == date && $6 == time && $7 == string' tasks.txt
				fi
			else
		   		echo "\nError: Invalid date format. Please enter the date in YYYY-MM-DD format."
			fi
		else
			echo "\nError: Invalid entry"
		fi
	fi

	if [ $CHOICE -eq 6 ]; then
		echo "\nEnter the title of the task:"
		read TITLE
		
		if [ -n "$TITLE" ]; then
			echo "\n"
			awk -v title="$TITLE" '$2 == title' tasks.txt
		else
			echo "\nInvalid entry"
		fi
	fi

	if [ $CHOICE -eq 7 ]; then
		exit 0
	fi
else
	echo "\nError: Invalid choice"
fi

done
