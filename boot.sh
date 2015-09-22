#!/bin/bash

source ./utils.sh

welcome=`cat ascii`
echo "$welcome"

render_message 1 "heading" "This will start the initial process for setting up your project, Are you sure you want to continue? (y/n)"
read answer

if echo "$answer" | grep -iq "^y" ;then
  
    render_message 1 "input" "1. Project directory name without any spaces: (example: motosport):"
    read answer
    directory_name=${answer}
    #echo $directory_name

    current_path=$(pwd)
    #echo $current_path
        
    render_message 1 "input" "2. Git repository (example: git@git.company.com:project/name):"
    read answer
    git_repo=${answer}
    #echo $git_repo

    render_message 1 "input" "3. MySQL database name:"
    read answer
    database_name=${answer}
    #echo $database_name

    render_message 1 "input" "4. MySQL user (root) password:"
    read answer
    db_root_password=${answer}
    #echo $db_root_password    

    full_path=$current_path/$directory_name
    #echo $full_path
    
    render_message 0 "status" "Initializing Git Cloning..."
    git clone $git_repo $full_path

    render_message 0 "status" "Initializing Submodules..."
    cd $full_path
    git checkout develop
    git submodule update --init
    cd $full_path/application
    git checkout develop
    git submodule update --init

    render_message 0 "status" "Creating and assigning permissions to directories..."
    cd $full_path
    sudo mkdir -p -m 0777 web/assets files/runtime
    sudo chmod 0777 files web
    sudo chown -R $USER:www-data web files

    render_message 0 "status" "Initializing Yiic Deploy Tool..."
    cd $full_path/application
    ./yiic deploy first-steps

    # Replacing older lines in main.php with new ones
    bin_paths="'params'=>array('convertPath'=>'/usr/bin/convert','compositePath'=>'/usr/bin/composite','gsPath'=>'/usr/bin/gs','rainbowPath'=>'/usr/bin/rainbow','gitPath'=>'/usr/bin/git',),"

    sudo sed -i '6 c\ "connectionString" => "mysql:host=localhost;dbname='$database_name'",' $full_path/customer/sites/_this_/main.php
    sudo sed -i '7 c\ "username" => "root",' $full_path/customer/sites/_this_/main.php
    sudo sed -i '8 c\ "password" => "'$db_root_password'",' $full_path/customer/sites/_this_/main.php
    sudo sed -i '19 c\ "binaryPath" => "/usr/bin/prince",' $full_path/customer/sites/_this_/main.php
    sudo sed -i '21 c\ ), \r\n' $full_path/customer/sites/_this_/main.php
    sudo sed -i '22 c\ '$bin_paths $full_path/customer/sites/_this_/main.php
    
    render_message 0 "status" "Initializing Database Setup..."
    cd $full_path/application
    ./yiic deploy init-db
    
    render_message 0 "status" "Initializing Database Migrations..."
    ./yiic deploy migrate

    render_message 0 "status" "Initializing Sass Compilation, Merging Dir, Flushing Caches..."
    ./yiic deploy sass merge-web gen-js mini-js flush-cache

    render_message 0 "heading" "Setup is now completed"

else
    render_message 0 "heading" "GoodBye!"
fi
