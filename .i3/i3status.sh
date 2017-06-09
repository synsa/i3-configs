#!/bin/zsh

/usr/bin/i3status -c $HOME/.i3status.conf | while :
do
    # Read input
    read line

    # cd into ~/.i3
    cd $HOME/.i3

    ##########################################################################################
    ######################################## RAM #############################################
    ##########################################################################################
    RAM=`free -kh | grep Mem | awk '{print $3}'`
    TOTR=$(cat /proc/meminfo | grep MemT | sed 's/.*\://g' | sed 's/ *//g' | sed 's/kB//g')
    TOT=$(/usr/local/bin/ram $TOTR | sed 's/$/G/g' )

    ##########################################################################################
    ####################################### Uptime ###########################################
    ##########################################################################################
    uptime=$(cat /proc/uptime | cut -d ' ' -f 1)
    uptime=$(octave --eval "round($uptime)" | sed 's/ans \= *//g') 
    hour=$(octave --eval "fix($uptime/3600)" | sed 's/ans \= *//g')
    min=$(octave --eval "fix($uptime/60-$hour*60)" | sed 's/ans \= *//g')
    sec=$(octave --eval "fix($uptime-$hour*3600-$min*60)" | sed 's/ans \= *//g')
    if ! [[ $hour == 0 ]]; then
         UP="${hour}h ${min}m ${sec}s"
    else
         UP="${min}m ${sec}s"
    fi

    ##########################################################################################
    ###################################### CPU Usage #########################################
    ##########################################################################################
    CPU=$(/usr/local/bin/cpu)

    ##########################################################################################
    #################################### Date Transfer #######################################
    ##########################################################################################
    # Download rate
    DOWN=$(./download.sh)
    # Upload rate
    UPL=$(./upload.sh)

    ##########################################################################################
    ###################################### CPU Temp ##########################################
    ##########################################################################################
    function temp {
         K=$(cat /sys/devices/platform/coretemp.0/hwmon/hwmon0/temp$1_input)
         let K=K/1000
         printf "$K°"
    }

    # Temp of core 1
    TEMP0=$(temp 1)

    # Temp of core 2
    TEMP1=$(temp 2)

    # Temp of core 3
    TEMP2=$(temp 3)

    # Temp of core 4
    TEMP3=$(temp 4)

    # Temp of core 5
    TEMP4=$(temp 5)

    # Date
    DATE=$(date +"%l:%M:%S %p, %a %d %b %y")

    ##########################################################################################
    ###################################### CPU Load ##########################################
    ##########################################################################################
    function load {
         uptime | cut -d ':' -f "$1" | cut -d ',' -f "$2" | grep "[0-9]" | sed 's/ //g'
    }

    loadcheck=$(load 4 2)
    if [[ $hour -ge "1.0" ]]; then
         LOAD=$(load 5 1)
    elif [[ $loadcheck -gt "0.05" ]]; then
         LOAD=$(load 4 1)
    else
         LOAD=$(load 4 1)
    fi

    ##########################################################################################
    ##################################### Weather ############################################
    ##########################################################################################
    #WEATH=$(curl -sL wttr.in/townsville)
    #function weathd {
    #     printf $WEATH | head -n "$1" | tail -n 1 | sed 's|[-\.\ \:\_\;]||g'
    #}

    #temp=$(weathd 4)
    #cond=$(weathd 3)

    ##########################################################################################
    ###################################### Status ############################################
    ##########################################################################################
    printf "%s\n" "Up: $UP | ↓ $DOWN kB/s ↑ $UPL kB/s | CPU: $CPU% | RAM: $RAM/$TOT | Load: $LOAD | $TEMP0 | $TEMP1 | $TEMP2 | $TEMP3 | $TEMP4 | $DATE"
done
