#!/bin/bash

read nick buff word

function call { $(echo "$1" |grep -P "$2" > /dev/null) ; }
function output { echo "PRIVMSG $1 :$2" ; }

if   call "$word" "\bjokebot: joke\b"\|"\!joke" ;  then
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

    joke=$(sed -n "${lineNum}p" jokes.txt)
    awns=$(sed -n "${lineNum}p" awnsers.txt)
    
    output $buff "$nick: $lineNum: $joke"
    output $buff "$nick: $lineNum: $awns"

elif call "$word" "\bjokebot: newJoke\b" ; then
    jokeLine="$(wc -l < newJoke.txt)"
    punchLine="$(wc -l < newPunch.txt)"

    if [ $jokeLine == $punchLine ] ; then    


        cut1="$(echo $word | cut -d "#" -f2)"
        if $(echo $cut1 | grep "/" > /dev/null) ; then
            punch="$(echo $cut1 | cut -d "/" -f2)"
            cut2="$(echo $cut1 | cut -d "/" -f1)"
            joke="$(echo $cut2 | cut -d " " -f 4-100)"

        
            output $buff "$joke"
            output $buff "$punch"
            output $buff "$nick: This is how your joke will look, if this isn't correct please, use \"oops\" to remove that joke (It really just removes the last inputted joke so be careful)"
            echo $joke>>newJoke.txt
            echo $punch>>newPunch.txt

            jokeLine="$(wc -l < newJoke.txt)"
            num=3
            echo $jokeLine
            echo $num
            if [ $jokeLine == $num ] ; then
                cat newJoke.txt>>jokes.txt
                cat newPunch.txt>>awnsers.txt
                cat newJoke.txt>>jokes2.txt
                catnewJoke.txt>>awnsers2.txt
                jokeNum="$(wc -l < newJoke.txt)"
                output $buff "NEW JOKES :D (last joke was $jokeNum)"
                >newJoke.txt
                >newPunch.txt
            fi



         else
             output $buff "$nick Sorry I can't accept this, please use a \"/\" to seperate the setup and punchline"
         fi
    else
        output $buff "$nick: Sorry seems something is wrong right now and I'm not taking jokes, I'll PM punz to fix me."
        output "punz" "temporary joke files have different line counts"
    fi
    
#    jokeLine="$(wc -l < newJoke.txt)"
#    echo $jokeLine
#    if [ $jokeLine==10 ] ; then 
#         cat newJoke.txt>>temp.txt
#         cat newPunch.txt>>temp2.txt
#      
#         output $buff "NEW JOKES :D"
#         >newJoke.txt
#         >newPunch.txt
#    fi


    #elif call "$word" "\bjokebot: newpunchline\b" ; then
    #   cut1="$(echo $word | cut -f2 -d "#" )"
    #  newpunch="$(echo $cut1 | cut -d " " -f 4-1000)"
    # output $buff "$newpunch"
    # jokeline=$(wc -l newjoke.txt 
    # echo $newpunch>>newpunch.txt
    

elif call "$word" "\bjokebot: oops\b" ; then
    lines="$(wc -l < newJoke.txt)"
    #let "lines++"
    joke=$(sed -n "${lines}p" newJoke.txt)
    punch=$(sed -n "${lines}p" newPunch.txt)
    sed -i "${lines} d" newJoke.txt
    sed -i "${lines} d" newPunch.txt
    output $buff "$nick: \"$joke/$punch\" has been removed"

elif call "$word" "\bjokebot: purge\b" ; then
    cut1="$(echo $word | cut -d "#" -f2)"
    num="$(echo $cut1 | cut -d " " -f 4)"
    joke=$(sed -n "${num}p" jokes.txt)
    punch=$(sed -n "${num}p" awnsers.txt)
    sed -i "${num} d" jokes.txt
    sed -i "${num} d" awnsers.txt
    output $buff "$nick: \"$num:$joke/$punch\" has been removed"
    output "punz" "$nick has removed \"$num:$joke:$punch\""

elif call "$word" "\bjokebot: jokehelp\b" ; then
    output $buff "To add a joke you must use the command newJoke, followed by your joke divided by a /"
    output $buff "example \" jokebot: newJoke setup/punchline \", if you mess up just say jokebot: oops"
    output $buff "to remove a joke use purge followed by the number of the joke"
    output $buff "example \"jokebot: purge 91\""
    
elif call "$word" "\bjokebot: ba dum\b" ; then
    output $buff "tss"

elif call "$word" "\bjokebot: hi\b"\|"jokebot: Hi" ; then
     output $buff "Hi $nick"


elif call "$word" "\bjokebot: info\b" ; then
    output $buff "Hi I'm jokebot! I tell jokes(good or bad is up to you). My main command is \"joke\" but you can also use \"!joke\", I'll only listen if your talking to me(through jokebot: <command>). For a list of commands use \"commands\". To add a joke use \"jokehelp\". I'm a work in progress so if you have any questions, PM punz."


elif call "$word" "\bjokebot: commands\b"\|"jokebot: command" ; then
    output $buff "$nick: joke, Hi, info, commands, jokenum, bad one, good one, jokehelp, newJoke, purge, oops. You can also just use "!joke" to get the same affect as joke"

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
    echo "PART #dadjokes"
    echo "PART #robots"

elif call "$nick" "\bpunz\b" && call "$word" "jokebot: reconnect" ; then
    echo "JOIN #dadjokes catsonly"
    echo "JOIN #robots catsonly"

fi
