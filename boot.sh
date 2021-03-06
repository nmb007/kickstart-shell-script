#!/bin/bash

source ./utils.sh

  # receiving parameters
  git_repo=$1
  database_name=$2
  db_root_password=$3

  #echo $git_repo
  #echo $database_name
  #echo $db_root_password

  current_path=$(pwd)
  #echo $current_path
  
  full_path=$current_path
  #echo $full_path
  
  # Temporary git directory
  tmp_git_dir=$current_path/temp
    
  render_message 0 "status" "Initializing Git Cloning..."
  git clone $git_repo $tmp_git_dir

  render_message 0 "status" "Initializing Submodules..."
  cd $tmp_git_dir
  git checkout develop
  git submodule update --init
  cd $tmp_git_dir/application
  git checkout develop
  git submodule update --init

  # Moving back all files from that 'temp' folder to our main working folder    
  shopt -s dotglob nullglob    # To make sure hidden files are included as well
  mv $tmp_git_dir/* $current_path/
  rm -rf $tmp_git_dir # Remove that temporary folder

  render_message 0 "status" "Creating and assigning permissions to directories..."
  cd $full_path
  sudo mkdir -p -m 0777 web/assets files/runtime web/css
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

  render_message 0 "status" "Initializing Sass Compilation, Merging Directories"
  ./yiic deploy sass merge-web gen-js mini-js

  render_message 0 "heading" "Application setup has been completed"
