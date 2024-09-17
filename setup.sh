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
pkg in -y aria2 ffmpeg git megatools python tdl termux-api wget zsh

# install pip packages
pip install gallery_dl mutagen yt-dlp spotdl==3.9.6

# create dirs
mkdir -p ~/storage/downloads/Termux/{Aria2,GalleryDL,Git,Mega,Music,Telegram,Videos,Websites,Wget}

#################################
# TERMUX-URL-OPENER + CLIPBOARD #
#################################

# remove old repo dir
rm -rf ~/.termux-setup

# clone repo
git clone --single-branch --branch main https://github.com/saayajin/termux-setup.git ~/.termux-setup

# copy home dir
cp -rp ~/.termux-setup/home /data/data/com.termux/files

# make executable
chmod u+x ~/.shortcuts/clipboard
chmod u+x ~/bin/termux-url-opener

#############
# OH-MY-ZSH #
#############

# remove old repo dir
rm -rf ~/.oh-my-zsh

# clone repo
git clone --single-branch --branch master https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh

# copy template
cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc

# change theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' ~/.zshrc

# add prompt context
echo -e 'prompt_context() {\n  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then\n    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"\n  fi\n}\n' >> ~/.zshrc

# change shell
chsh -s zsh

# send toast
termux-toast -g top -b white -c black Setup done
