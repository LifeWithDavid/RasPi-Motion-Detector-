#!/bin/bash
# This procedure sends an email when motion is detected

# Set up GPIO 4 (Header pin 7) as an input

echo "4" > /sys/class/gpio/unexport
sleep 1
echo "4" > /sys/class/gpio/export
sleep 1
echo "in" > /sys/class/gpio/gpio4/direction
# Sends an email that the program has just started, good for quick verification or in the event of a power outage
echo "The motion detection program has just been initialized" | mail -s "Motion program initalized" youremailaddress

PRINTONCE=1

# echo "initialized"

# Loop while checking the input 4 

while [ 1 ]
do
# inputs the  motion detector state into the variable "n"
	motionCount=$(</sys/class/gpio/gpio4/value)
	if [ $motionCount = 1 ]  # The motion sensor detected motion
	then
	# Send an email alerting that motion has just been detected
		echo "Motion has just been detected in the house" | mail -s "Motion just detected" youremailaddress
#		echo "Motion just detected"
		while [ $motionCount != 0 ]
		# Now monitor for 5 minutes (10 loops of 30 seconds each)
		do
			loopCount=0
			motionCount=0
			while [ $loopCount -lt 10 ]
			do
#				echo "motionCount $motionCount , loopCount $loopCount"
				sleep 30
				motion=$(</sys/class/gpio/gpio4/value) # $motion = 1 if motion is detected
				motionCount=$(( motionCount + motion ))
				loopCount=$(( loopCount + 1 ))
				motionPC=$(( motionCount * 10 ))
#				echo "After addition -- motionCount $motionCount , loopCount $loopCount"
			done
			if [ $motionCount != 0 ]
			then
				motionPC=$(( motionCount * 10 ))
	              		echo "Motion detected $motionPC percent in the last 5 minutes" | mail -s \
	               		"Motion Report" youremailaddress

#                		echo "Motion detected $motionPC percent in the last 5 minutes"
			fi

		done

	else
#			echo "Motion not detected"
			sleep 20
	fi
# Adds a watchdog timer to send an email every 12 hours to confirm the system is still working

HOUR=$(date +%l)
# echo $HOUR, $PRINTONCE
if [ $HOUR = 12 ]
then
	if [ $PRINTONCE = 1 ]
	then
		echo "It is 12 o-clock and all is well." | mail -s "Watchdog timer" youremailaddress
		PRINTONCE=0	
	fi
else
	PRINTONCE=1
fi
done

