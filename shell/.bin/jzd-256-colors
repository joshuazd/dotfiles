#!/bin/bash
for fgbg in 38 48 ; do #Foreground/Background
    for color in {0..15} ; do #Colors
        #Display the color
        echo -en "\e[${fgbg};5;${color}m ${color} \t\e[0m"
        #Display 8 colors per lines
        if [ $((($color + 1) % 8)) == 0 ] ; then
            echo #New line
        fi
    done
    for color in {16..255} ; do #Colors
        #Display the color
        echo -en "\e[${fgbg};5;${color}m ${color} \t\e[0m"
        #Display 6 colors per lines
        if [ $((($color - 15) % 6)) == 0 ] ; then
            echo #New line
        fi
    done
    echo #New line
done
exit 0
