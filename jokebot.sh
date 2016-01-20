#!/bin/bash

function talk {
    echo "-> $1"
    echo "$1" >> .jokefile
}

rm .jokefile
mkfifo .jokefile
#openssl s_client -connect irc.cat.pdx.edu:6697
tail -f .jokefile | openssl s_client -connect irc.cat.pdx.edu:6697 | while true ; do
    if [[ -z $started ]] ; then
        talk "NICK jokebot"
        talk "USER jokebot jokebot jokebot jokebot"
        talk "JOIN #robots catsonly"
        talk "JOIN #dadjokes catsonly"
        talk "JOIN #LHStest"
        started="yes"
    fi
    read irc
    #raw=$(echo $irc)
    echo "<- $irc"
    if $(echo $irc | cut -d ' ' -f 1 | grep PING > /dev/null) ; then 
        talk "PONG"
    
    
    elif  $(echo $irc | grep PRIVMSG > /dev/null)  ; then
        if $(echo $irc | cut -d ' ' -f 4 |  grep "jokebot:\|!joke" > /dev/null) ; then
            buff=$(echo $irc |cut -d ' ' -f 3)
            raw="testing"
            switch=$(echo $irc | cut -d ' ' -f 1-3)
            word=$(echo $irc##$switch :}|tr -d "\r\n")
            nick="${irc%%!*}"; nick="${nick#:}"
            
            stuff=$(echo "$nick" "$buff" "$word" "$raw" | ./command.sh)
            
            if [[ ! -z $stuff ]] ; then
                talk "$stuff"
            fi
            
        fi
    fi
done    
