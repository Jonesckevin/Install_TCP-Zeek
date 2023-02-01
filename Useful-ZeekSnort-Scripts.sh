#!/bin/bash
echo '#####################################################################################################################'
echo '##################################~~~~~~Some Snort And Zeek Scripts ~~~~~############################################'
echo '#####################################################################################################################'
cd ~/Desktop

#Zeek File Extract
	#zeek -Cr ../proxy.pcap frameworks/files/extract-all-files.zeek

#!/bin/bash
# ------------------------------------------------------------------
# [Author] Kevin C. Jones
#          Description: This script is hopefully to compile and make using command line for 
#                       snort and zeek something closer to a one liner for basic consumtion 
#                       to start analysing sooner.
# ------------------------------------------------------------------

VERSION=0.3.0 - Experimental
SUBJECT=some-unique-id
USAGE="Usage: command -z or -s args to specify zeek or snort usage."
SNORTALERT=$(sudo snort -c snort.conf -r ""${2}"" -A console > Alert.txt)
SNORTPRISORT=$(grep -i -E "Priority: (0|1|2|3|4|5)" ./Alert.txt | cut -d " " -f 4- | rev | cut -d " " -f 4- | rev | sort | uniq -c | sort -n > Final_Alert.log)
SNORTPRISORTCHOICE=$(grep -i -E 'Priority: ("$3")' Alert.txt | cut -d " " -f 4- | rev | cut -d " " -f 4- | rev | sort | uniq -c | sort -n > 'Priority-"$3".log')
# --- Options processing -------------------------------------------
if [ $# == 0 ] ; then
    echo $USAGE
    exit 1;
fi

while getopts ":i:vh" optname
  do
    case "$optname" in
      "v")
        echo "Version $VERSION"
        exit 0;
        ;;
      "i")
        echo "-i argument: Does Nothing ATM"
        ;;
      "h")
        echo "Usage: `basename $0` [-h]"
        echo $USAGE
        exit 0;
        ;;
      "s")
        echo "This will create an Alert.txt File in your current directory"
        echo "See 'cat ./Alert.txt'"
        echo "Activating: $SNORTALERT"
        $SNORTALERT
        echo "I will now defaultily, sort this into what I will call the Final-Alert.txt which will sort, group, unique all Priority 0-5 so that the Alert.txt is less messy. You can keep the Alert so that you can reference individuals with their time."
        echo "Activating '$SNORTPRISORT'"
        echo "See 'cat ./Final-Alert.log"
        $SNORTPRISORT
        if [ $# == 3 ]; then
          echo 'Activating "$SNORTPRISORTCHOICE"'
          echo "Hopefully $3 is a priority number or regex Or Statement
		      $SNORTPRISORTCHOICE
          
	    	else
	      	echo 'Something Went Wrong on -s Snort and Snort Choice'
	      	echo 'Exiting...'
          exit 1
	    	fi
        exit 0;
        ;;
      "z")
        if [ $1 == -z ]; then
		      zeek -Cr './"${2}"'frameworks/files/extract-all-files.zeek local
	    	else
	      	echo 'Might have a Mistake? zeek1 <file spot <../the.pcap>> -e'
	      	echo 'Or type it out as: zeek -Cr "../"${2}"" frameworks/files/extract-all-files.zeek'
	    	fi
	    	if [ $1 == -h ]; then
		    	echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
	    		echo "~~~~~~~  ~~~~~       ToGenerate Zeek-OutPut     ~~~~~~  ~~~~~~~~~ "
			    echo " "
			    echo '   zeek1 <Inputfile.pcap> or zeek -Cr "../<File> frameworks/files/extract-all-files.zeek"'
			    echo " 		Example: zeek1 Capture.pcap"
			    echo ""
			    echo "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
			    exit 0
		    else
		    	if [[ ":$PATH:" == *":/opt/bro/bin:"* || ":$PATH:" == *":/usr/local/zeek/bin:"* ]] && [[ "$2" == *[".pcap"]* ]]; 			then
			    	mkdir ./zeek-output || exit
			      cd ./zeek-output
			      if [ $2 == -e ]; then
				  	  zeek -Cr "../"${2}"" frameworks/files/extract-all-files.zeek local
				  	  cd ..
				  	  echo " I made it here1" 
			  	  else
				  	  zeek -Cr "../"${2}"" local
				  	  cd ..
				  	  echo " I made it here2" 
					exit 0
				    fi
		  	else
			  	export PATH=$PATH:/opt/bro/bin >> ~/.bashrc
			  	echo "Your path 'was' missing /opt/bro/bin, It was added in hopes you do have it installed. -- Try Again --"
			  	echo ""
			  	echo "Usage: `basename $0` [-h] or try again"
				exit 0
			    fi
		    fi
        exit 0;
        ;;
      *)
        echo "Unknown error. Please Try Again or Insert Another Quarter"
        echo "If you are unsure:"
        echo "Is this your PCAP?: --> $2"
        echo "For Snort // Is this your Priority you want filteres? eg. 3|5 or 3: --> "$3""
        exit 0;
        ;;
    esac
  done

# --- Locks -------------------------------------------------------
LOCK_FILE=/tmp/$SUBJECT.lock
if [ -f "$LOCK_FILE" ]; then
   echo "Script is already running"
   exit
fi

trap "rm -f $LOCK_FILE" EXIT
touch $LOCK_FILE
