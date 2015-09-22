render_message() 
{
    prompt_needed=$1
    message_type=$2
    text=$3
    
    get_color $message_type
    
    if [ $prompt_needed = "1" ]
    then
        # prompt needed
        echo -n -e "$color$text \e[0m "
    elif [ $prompt_needed = "0" ]
    then
        # prompt not needed
        echo -e "$color$text \e[0m "
    fi
}

get_color()
{
   message_type=$1
   if [ $message_type = 'heading' ]
   then
        #blue       
        color="\e[96m"
   elif [ $message_type = 'input' ] 
   then
        #yellow       
        color="\e[93m" 
   elif [ $message_type = 'status' ] 
   then
        #green       
        color="\e[92m" 
   fi
}
