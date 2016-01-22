#!/bin/bash

read nick buff word

key="$(cat notakey.txt)"
function call { $(echo "$1" |grep -P "$2" > /dev/null) ; }
function output { echo "PRIVMSG $1 :$2" ; }
function nameTestAdd {
    ##This function is used to test if the user is in the name text file
    ##If the users name is in the text file it will first store the liine the user is on
    ##See how many jokes are in the jokefile
    ##the line the user name and last joke number is on
    ##append with username and new jokenum
    ##if user is not found just append with username and new joke num

    if grep -q "$nick" names.txt ; then
        lineNum="$(grep -n "$nick" names.txt | cut -f1 -d:)"
        #jokeNum=$(sed -n "${lineNum}p" names.txt | cut -f2 -d:)
        jokeNum=$(wc -l < jokes.txt)
        sed -i "${lineNum} d" names.txt
        echo "$nick:$jokeNum">>names.txt

    else
        jokeTot=$(wc -l < jokes.txt)
        echo "$nick:$jokeTot">>names.txt

    fi
    
}
function oops {
    ##this function is used to remove the last joke inputted by a user
    ##It checks a file for the users name goes from there
    ##If there it takes the line that it is located. takes the text from that line, and cuts that line for the number
    ##this number is used to remove and output what the removed joke was
    ##the user and their number is then removed from the file
    ## if the user is not inn the file the program only oupts a simple phrase


    if grep -q "$nick" names.txt ; then
        lineNum="$(grep -n "$nick" names.txt | cut -f1 -d:)"
        echo "lineNum $lineNum"
        jokeNum=$(sed -n "${lineNum}p" names.txt | cut -f2 -d:)

        joke=$(sed -n "${jokeNum}p" jokes.txt)
        punch=$(sed -n "${jokeNum}p" awnsers.txt)

        sed -i "${jokeNum} d" jokes.txt
        sed -i "${jokeNum} d" awnsers.txt
        sed -i "${lineNum} d" names.txt
        output $buff "$nick: Your joke \"$joke/$punch\" has been removed"


    else 
        output $buff "You removed your last joke already"
    fi
    
}
function tellJoke {
    ## This this system makes sure that the same joke is never told twice
    ## It also is semi random
    ## Every time the function is called the the joke number whill always increase by three and randomly increase from 0-3
    ## The joke is then pulled from the file using sed and is sent to the buffer where the joke command was used
    
    batchNum=$(sed -n "1p" counter.txt)
    jokeNum="$(wc -l < jokes.txt)"
    (( batches = $jokeNum / 3 ))
    >counter.txt
    let "batchNum++"
    if [ $batchNum == $batches ]; then
        batchNum=0
        echo "$batchNum" >> counter.txt
    else
        echo "$batchNum" >> counter.txt
    fi
    
    batchOne=$(($RANDOM%3))
    batchTen=$((3 * $batchNum))

    lineNum=$(($batchTen + $batchOne))
    let "lineNum++"
    
    if [[ $lineNum -gt $jokeNum ]] ; then
         joke=$(sed -n "${jokeNum}p" jokes.txt)
         awns=$(sed -n "${jokeNum}p" awnsers.txt)
           
         output $buff "$nick: $jokeNum: $joke"
         output $buff "$nick: $jokeNum: $awns"

     elif [[ $jokeNum -gt $lineNum ]] ; then
        joke=$(sed -n "${lineNum}p" jokes.txt)
        awns=$(sed -n "${lineNum}p" awnsers.txt)

        output $buff "$nick: $lineNum: $joke"
        output $buff "$nick: $lineNum: $awns"

    fi

    }
#function addJoke {}

if   call "$word" "\bjokebot: joke\b"\|"\!joke" ;  then
   
    ## This checks whether when the person uses the joke command if theres a number after it indicating they want a specific numbered joke
    ## Because there are multiple ways to call the joke function we cut the message multiple and check each cut\
    ## If there is a number, it will pull the text from that line number out of the files and display them
    ## If there is no number it will call the tellJoke function

   buffmsg="$(echo $word | cut -d "#" -f2)"
   msg="$(echo $buffmsg | cut -d ":" -f 2-3)"
   num1="$(echo $msg | cut -d "e" -f3)"
   num2="$(echo $msg | cut -d "e" -f2)"

    if [[ $num1 = *[[:digit:]]* ]] ; then
        joke=$(sed -n "${num1}p" jokes.txt)
        awns=$(sed -n "${num1}p" awnsers.txt)

        output $buff "$nick: $num1: $joke"
        output $buff "$nick: $num1: $awns"

    elif [[ $num2 = *[[:digit:]]* ]] ; then
         joke=$(sed -n "${num2}p" jokes.txt)
         awns=$(sed -n "${num2}p" awnsers.txt)
         output $buff "$nick: $num2: $joke"
         output $buff "$nick: $num2: $awns"

    else
        tellJoke
    fi

    
     


elif call "$word" "\bjokebot: newJoke\b"\|"\bjokebot: newjoke\b"\|"\bjokebot: addjoke\b"\|"\bjokebot: addJoke\b" ; then
    
    ## This allows for users to add their own jokes    

    
        
    jokeLine="$(wc -l < newJoke.txt)"
    punchLine="$(wc -l < newPunch.txt)"
    if [ $jokeLine == $punchLine ] ; then    
        
        
        
        cut1="$(echo $word | cut -d "#" -f2)"
        if $(echo $cut1 | grep "/" > /dev/null) ; then
            punch="$(echo $cut1 | cut -d "/" -f2)"
            cut2="$(echo $cut1 | cut -d "/" -f1)"
            joke="$(echo $cut2 | cut -d " " -f 4-100)"

            
            echo $joke>>jokes.txt
            echo $punch>>awnsers.txt
            jokeLine="$(wc -l < jokes.txt)"
            output $buff "$joke"
            output $buff "$punch"
            output $buff "$nick: your joke is number $jokeLine, use \"oops\" to remove your last inputted joke"
            output "punz" "$joke/$punch"
            #echo $joke>>newJoke.txt
            #echo $punch>>newPunch.txt
            nameTestAdd
            #jokeLine="$(wc -l < newJoke.txt)"
            #num=3
            #echo $jokeLine
            #echo $num
            #if [ $jokeLine == $num ] ; then
            #    cat newJoke.txt>>jokes.txt
            #    cat newPunch.txt>>awnsers.txt
            #    cat newJoke.txt>>jokes2.txt
            #    catnewJoke.txt>>awnsers2.txt
            #    jokeNum="$(wc -l < jokes.txt)"
            #    output $buff "NEW JOKES :D (last joke was $jokeNum)"
            #    >newJoke.txt
            #    >newPunch.txt
            #fi



         else
             output $buff "$nick Sorry I can't accept this, please use a \"/\" to seperate the setup and punchline"
         fi
    else
        output $buff "$nick: Sorry seems something is wrong right now and I'm not taking jokes, I'll PM punz to fix me."
        output "punz" "temporary joke files have different line counts"
    fi

elif call "$word" "\bjokebot: oops\b"\|"\bjokebot: remove\b" ; then
    oops

elif call "$word" "\bjokebot: purge\b"\|"\bjokebot: Purge\b" ; then
    cut1="$(echo $word | cut -d "#" -f2)"
    num="$(echo $cut1 | cut -d " " -f 4)"
    joke=$(sed -n "${num}p" jokes.txt)
    punch=$(sed -n "${num}p" awnsers.txt)
    sed -i "${num} d" jokes.txt
    sed -i "${num} d" awnsers.txt
    output $buff "$nick: \"$num:$joke/$punch\" has been removed"
    output "punz" "$nick has removed \"$num:$joke:$punch\""

elif call "$word" "\bjokebot: jokehelp\b" ; then
    output $buff "Use the command \"newJoke\" followed by your joke divided by a \"/\" to add a joke."
    output $buff "example \" jokebot: newJoke setup/punchline \", if you mess up just say jokebot: oops"
    output $buff "Use jokebot: purge followed by a number to remove a specific joke"
    output $buff "example \"jokebot: purge 91\""
    
elif call "$word" "\bjokebot: ba dum\b" ; then
    output $buff "tss"

elif call "$word" "\bjokebot: hi\b"\|"jokebot: Hi" ; then
     output $buff "Hi $nick"


elif call "$word" "\bjokebot: info\b"\|"\bjokebot: help\b"\|"\bjokebot: Help\b"\|"\bjokebot: Info\b" ; then
    output $buff "Hi I'm jokebot! I tell jokes(good or bad is up to you). My main command is \"joke\" but you can also use \"!joke\", I'll only listen if your talking to me(through jokebot: <command>). For a list of commands use \"commands\". To add a joke use \"jokehelp\". I'm a work in progress so if you have any questions, PM punz."


elif call "$word" "\bjokebot: commands\b"\|"jokebot: command" ; then
    output $buff "$nick: joke, Hi, info, commands, source, jokenum, bad one, good one, jokehelp, newJoke, purge, oops. You can also just use "!joke" to get the same affect as joke"

elif call "$word" "\bjokebot: jokenum\b" ; then
    jokeNum="$(wc -l < jokes.txt)"
    output $buff "$nick: I know $jokeNum jokes"

elif call "$word" "\bjokebot: bad one\b" ; then
    output $buff "$nick: Well I thought it was funny :D"

elif call "$word" "\bjokebot: good one\b" ; then
    output $buff "$nick: Thank you, Thank you. I'll be here forever ;D"

elif call "$word" "\bjokebot: privmsg\b" ; then
    output $nick "hi" 

elif call "$nick" "\bpunz\b" && call "$word" "jokebot: testing" ; then
    ## These can only be called(succesefullly) by me(punz)
    
    output "#robots" "Not broken just testing"
    echo "PART #dadjokes"
    echo "PART #robots"

elif call "$nick" "\bpunz\b" && call "$word" "jokebot: reconnect" ; then
    echo "JOIN #dadjokes $key"
    echo "JOIN #robots $key"

elif call "$word" "\bjokebot: source\b" ; then
    output $buff "https://github.com/slogan-punz/jokebot"

elif call "$word" "jokebot:" ; then
    output $buff "Hmm? (maybe use jokebot: help or commands)"
fi
