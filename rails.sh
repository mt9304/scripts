#!bin/bash

#Dec 27, 2017
#This script installs Git, Ebenv, Ruby, Rails, Nodejs, and Postgresql on Ubuntu 16.04. 

#May 14, 2018
#Modified script to work in 1 go with xdotools on Ubuntu 18.04. Also updated versions of programs to install. 

#Remember to chmod u+x filename.sh

GITINSTALLED="Not Installed"
RBENVINSTALLED="Not Installed"
RUBYINSTALLED="Not Installed"
BUNDLERINSTALLED="Not Installed"
RAILSINSTALLED="Not Installed"
NODEJSINSTALLED="Not Installed"
POSTGRESQLINSTALLED="Not Installed"

echo_status() 
{
	echo "Git:        \t" $GITINSTALLED
	echo "Rbenv:      \t" $RBENVINSTALLED
	echo "Ruby:       \t" $RUBYINSTALLED
	echo "Bundler:    \t" $BUNDLERINSTALLED
	echo "Rails:      \t" $RAILSINSTALLED
	echo "Nodejs:     \t" $NODEJSINSTALLED
	echo "Postgresql: \t" $POSTGRESQLINSTALLED
}


#Update
#sudo apt-get update

#Install Git
yes | sudo apt-get install git

Check if git is installed properly. If git is a function, then ok
type git >/dev/null 2>&1 || { echo >&2 "Script requires git, but it's not installed.  Aborting."; echo_status; $SHELL; }
GITINSTALLED="Installed"


#Install rbenv dependencies
yes | sudo apt-get install autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm-dev

#Installs xdotool to automatically type commands for completing script. Workaround for not being able to source bashrc midscript. 
yes | sudo apt-get install xdotool

function source_and_rerun_rbenv
{
	xdotool type 'source ~/.bashrc'
	xdotool key Return
	xdotool type 'sh rails.sh rbenv'
	xdotool key Return
}

function source_and_rerun_ruby
{
	xdotool type'source ~/.bashrc'
	xdotool key Return
	xdotool type 'sh rails.sh rbenv ruby'
	xdotool key Return
}

#Might need to chance .bashrc to .bash_profile when sshing into aws
#Install RVM
git clone https://github.com/rbenv/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(rbenv init -)"' >> ~/.bashrc

#Check if rbenv is installed properly. If rbenv is a function, then ok
type rbenv >/dev/null 2>&1 || { echo >&2 "Script requires rbenv, but it's not installed.  Aborting. "; echo_status; echo " "; echo "Rbenv may have installed, but is not found. Reload the profile by typing source ~/.bashrc and run the script again. "; if [ "$1" != "rbenv" ] ; then source_and_rerun_rbenv; else echo "Script was re-ran after re-sourcing bashrc, but still could not find rbevv. "; fi ; }
RBENVINSTALLED="Installed"


#Install ruby-build to run rbenv install
git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build

#rbenv install -l to list version available. 2.5.1 was used at time when this was written
rbenv install 2.5.1
rbenv global 2.5.1

#Check is ruby was installed properly. If ruby exists, then ok
type ruby >/dev/null 2>&1 || { echo >&2 "Script requires ruby, but it's not installed.  Aborting."; echo_status; if [ "$2" != "ruby"] ; then source_and_rerun_ruby ; else echo "Script was re-ran after re-sourcing bashrc, but still could not find rbevv. "; fi ; }
RUBYINSTALLED="Installed"

#Disable generation of lcoal documentation after every gem
echo "gem: --no-document" > ~/.gemrc

#Install bundler gem
gem install bundler -v 1.16.0

#Check is bundler was installed properly. If bundler exists, then ok
type bundler >/dev/null 2>&1 || { echo >&2 "Script requires bundler, but it's not installed.  Aborting."; echo_status; $SHELL; }
BUNDLERINSTALLED="Installed"

#gem env home to check where gems are being installed

#Install rails
gem install rails -v 5.2.0
rbenv rehash

#Check rails. Rails 5.1.4
type rails >/dev/null 2>&1 || { echo >&2 "Script requires rails, but it's not installed.  Aborting."; echo_status; $SHELL; }
RAILSINSTALLED="Installed"

#Install NodeJS
cd /tmp
\curl -sSL https://deb.nodesource.com/setup_6.x -o nodejs.sh
#less nodejs.sh
cat /tmp/nodejs.sh | sudo -E bash -
sudo apt-get install -y nodejs

#Check if nodejs is installed properly. If nodejs is a function, then ok
type nodejs >/dev/null 2>&1 || { echo >&2 "Script requires nodejs, but it's not installed.  Aborting."; echo_status; $SHELL; }
NODEJSINSTALLED="Installed"

cd ~/.rbenv
git pull

#Install Postgres
#sudo apt-get update
cd ~
yes | sudo apt-get install postgresql postgresql-contrib libpq-dev

#Check if postgresql is installed properly. If pg is a function, then ok
type psql >/dev/null 2>&1 || { echo >&2 "Script requires postgresql, but it's not installed.  Aborting."; echo_status; $SHELL; }
POSTGRESQLINSTALLED="Installed"

echo uninstalling xdotool
yes | sudo apt-get remove xdotool

sudo apt-get update

echo_status
echo " "
echo "The installs have completed successfuly. "

#If using sqlite3 for local dev, make sure to run: 
#apt-get install libsqlite3-dev
#Otherwise creating new rails app might fail. 

$SHELL
