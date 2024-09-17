#!/bin/bash
clear

#################
# INITIAL SETUP #
#################

# setup storage
termux-setup-storage

# update
pkg update -y

# install packages
pkg in -y aria2 exiftool ffmpeg figlet ghostscript git imagemagick megatools openssh python rclone rust sshpass sqlite tdl termux-api termux-services tmux vim wget zsh

# install pip packages
pip install csvkit gallery_dl mutagen yt-dlp spotdl==3.9.6

# create dirs
mkdir -p ~/storage/downloads/Termux/{Aria2,downloads,GalleryDL,Git,Mega,Music,Telegram,Videos,Websites,Wget}

######################################################
# TERMUX-URL-OPENER + TERMUX-FILE-EDITOR + SHORTCUTS #
######################################################

# remove old repo dir
rm -rf ~/.termux-setup

# clone repo
git clone --single-branch --branch notmain https://github.com/saayajin/termux-setup.git ~/.termux-setup

# copy home dir
cp -rf ~/.termux-setup/home /data/data/com.termux/files

# symlink
ln -s ~/storage/downloads/Termux/downloads ~/

# make executable
chmod u+x ~/.shortcuts/*
chmod u+x ~/.shortcuts/tasks/*
chmod u+x ~/bin/termux-file-editor
chmod u+x ~/bin/termux-url-opener

#############
# OH-MY-ZSH #
#############

# remove old repo dir
rm -rf ~/.oh-my-zsh

# clone repo
git clone --single-branch --branch master https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# copy template
cp -f ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# change theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# add prompt context
echo -e 'prompt_context() {\n  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then\n    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"\n  fi\n}\n' >> ~/.zshrc

# change shell
chsh -s zsh

#########
# ALIAS #
#########

# set update alias
echo -e 'alias updateall="pkg update && pkg upgrade -y && pkg clean && pip install --upgrade csvkit gallery-dl mutagen yt-dlp"\n' >> ~/.zshrc

###############
# REWIND      #
# BY LARAIB07 #
###############

# get rewind
wget --no-check-certificate "https://raw.githubusercontent.com/laraib07/TermuxBackupTools/master/rewind"

# change backup export dir
sed -i 's+storage/emulated/0/Termux/Backup+storage/emulated/0/backups/Termux+' rewind

# make executable
chmod u+x rewind

# move to bin
mv rewind "$PREFIX/bin/"

################
# TERMUX-MOTD  #
# BY GENERATOR #
################

# remove old repo dir
rm -rf ~/.motd

# clone repo
git clone --single-branch --branch main https://github.com/saayajin/termux-motd.git ~/.motd

# make executable
chmod +x ~/.motd/init.sh

# run init.sh on login
echo "$HOME/.motd/init.sh" > ~/.zprofile

# clear default motd
echo "" > /data/data/com.termux/files/usr/etc/motd

#######################
# ALLOW EXTERNAL APPS #
#######################

# uncomment string
sed -i 's/# allow-external-apps/allow-external-apps/' ~/.termux/termux.properties

#############
# BOOKMARKS #
#############

# remove old dir
rm -rf ~/bookmarks

# remake dir
mkdir ~/bookmarks

# add to cdpath
echo -e 'export CDPATH=~/bookmarks\n' >> ~/.zshrc

# make symlink
ln -s ~/storage/shared/Documents/git ~/bookmarks

##########
# OXIPNG #
##########

# remove old repo dir
rm -rf ~/.oxipng

# clone repo
git clone --single-branch --branch master https://github.com/shssoichiro/oxipng.git ~/.oxipng

# change working dir
cd ~/.oxipng || exit

# build
cargo build --release

# copy to bin
cp -f ~/.oxipng/target/release/oxipng $PREFIX/bin

# remove leftovers
pkg un -y rust
rm -rf ~/.cargo
rm -rf ~/.oxipng

###########
# SCRIPTS #
###########

# remove old repo dir
rm -rf ~/.scripts

# clone repo
git clone --single-branch --branch main https://gist.github.com/a71c14d7c343cd862315e2eeffad5fed.git ~/.scripts

# change working dir
cd ~/.scripts || exit

# make executable
chmod u+x *

# make alias for each script
for file in *.sh; do 
  OLD="alias ${file%.sh}='. ~/.scripts/$file'"
  sed -i "s|$OLD|deletemepls|" ~/.zshrc
  sed -i '/deletemepls/d' ~/.zshrc
  echo -e "alias ${file%.sh}='. ~/.scripts/$file'" >> ~/.zshrc
done

##########
# FINISH #
##########

# return to home
cd ~ || exit

# clear pkg cache
pkg clean

# send toast
termux-toast -g top -b white -c black Setup done
