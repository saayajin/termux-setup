#!/bin/bash

# variables
termuxsetupr="https://github.com/saayajin/termux-setup.git"
termuxmotdr="https://github.com/saayajin/termux-motd.git"
scriptsr="https://github.com/saayajin/scripts.git"

#################
# INITIAL SETUP #
#################

# check storage permission
[ -d "$HOME/storage/downloads" ] || {
  echo "Run termux-setup-storage first."
  exit 1
}

# update
pkg update -y

# install packages
pkg in -y aria2 exiftool ffmpeg figlet ghostscript git imagemagick openssh python rclone rust shellcheck sshpass sqlite termux-api termux-services tmux vim wget zsh

# install pip packages
pip install csvkit gallery_dl mutagen yt-dlp

# create dirs
mkdir -p "$HOME/storage/downloads/Termux"/{Aria2,downloads,GalleryDL,Git,Music,Videos,Websites,Wget}

######################################################
# TERMUX-URL-OPENER + TERMUX-FILE-EDITOR + SHORTCUTS #
######################################################

# remove old repo dir
rm -rf "$HOME/.termux-setup"

# clone repo
git clone --single-branch --branch main "$termuxsetupr" "$HOME/.termux-setup"

# copy home dir
cp -rf "$HOME/.termux-setup/home" "/data/data/com.termux/files"

# symlink
ln -sfn "$HOME/storage/downloads/Termux/downloads" "$HOME/downloads"

# make executable
chmod u+x "$HOME"/.shortcuts/*
chmod u+x "$HOME/bin/termux-file-editor"
chmod u+x "$HOME/bin/termux-url-opener"

#############
# OH-MY-ZSH #
#############

# remove old repo dir
rm -rf "$HOME/.oh-my-zsh"

# clone repo
git clone --single-branch --branch master https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"

# copy template
cp -f "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"

# change theme
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/' "$HOME/.zshrc"

# add prompt context
echo -e 'prompt_context() {\n  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then\n    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER"\n  fi\n}\n' >> "$HOME/.zshrc"

# change shell
chsh -s zsh

#########
# ALIAS #
#########

# set update alias
echo -e 'alias updateall="pkg update && pkg upgrade -y && pkg clean && pip install --upgrade csvkit gallery-dl mutagen yt-dlp"\n' >> "$HOME/.zshrc"

##########
# REWIND #
##########

# get rewind
wget --no-check-certificate "https://raw.githubusercontent.com/laraib07/TermuxBackupTools/master/rewind"

# change backup export dir
sed -i 's+storage/emulated/0/Termux/Backup+storage/emulated/0/backups/Termux+' rewind

# make executable
chmod u+x rewind

# move to bin
mv rewind "$PREFIX/bin/"

###############
# TERMUX-MOTD #
###############

# remove old repo dir
rm -rf "$HOME/.motd"

# clone repo
git clone --single-branch --branch main "$termuxmotdr" "$HOME/.motd"

# make executable
chmod +x "$HOME/.motd/init.sh"

# run init.sh on login
echo "$HOME/.motd/init.sh" > "$HOME/.zprofile"

# clear default motd
echo "" > "/data/data/com.termux/files/usr/etc/motd"

##################
# VIM SHELLCHECK #
##################

# remove old repo dir
rm -rf "$HOME/.vim/pack/shellcheck"

# clone repo
git clone --single-branch --branch master "https://github.com/itspriddle/vim-shellcheck.git" "$HOME/.vim/pack/shellcheck/start/vim-shellcheck"

# set helptag
vim -u NONE -c "helptags $HOME/.vim/pack/shellcheck/start/vim-shellcheck/doc" -c q

#############
# BOOKMARKS #
#############

# remove old dir
rm -rf "$HOME/bookmarks"

# remake dir
mkdir "$HOME/bookmarks"

# add to cdpath
echo -e 'export CDPATH=$HOME/bookmarks\n' >> "$HOME/.zshrc"

# make symlink
ln -s "$HOME/storage/shared/Documents/git" "$HOME/bookmarks"

##########
# OXIPNG #
##########

# remove old repo dir
rm -rf "$HOME/.oxipng"

# clone repo
git clone --single-branch --branch master "https://github.com/shssoichiro/oxipng.git" "$HOME/.oxipng"

# change working dir
cd "$HOME/.oxipng" || exit 1

# build
cargo build --release

# copy to bin
cp -f "$HOME/.oxipng/target/release/oxipng" "$PREFIX/bin"

# remove leftovers
pkg un -y rust
rm -rf "$HOME/.cargo"
rm -rf "$HOME/.oxipng"

###########
# SCRIPTS #
###########

# remove old repo dir
rm -rf "$HOME/.scripts"

# clone repo
git clone --single-branch --branch main "$scriptsr" "$HOME/.scripts"

# change working dir
cd "$HOME/.scripts/termux" || exit 1

# make executable
chmod u+x *

# scripts aliases block variables
BEGIN_MARKER="# === SCRIPTS ALIASES - BEGIN ==="
END_MARKER="# === SCRIPTS ALIASES - END ==="

# delete old block
sed -i "/$BEGIN_MARKER/,/$END_MARKER/d" "$HOME/.zshrc"

# generate new block beginning
echo "" >> "$HOME/.zshrc"
echo "$BEGIN_MARKER" >> "$HOME/.zshrc"
echo "" >> "$HOME/.zshrc"

# make alias for each script
for i in *.sh; do
  echo -e "alias ${i%.sh}='. $HOME/.scripts/termux/$i'" >> "$HOME/.zshrc"
done

# close block
echo "" >> "$HOME/.zshrc"
echo "$END_MARKER" >> "$HOME/.zshrc"
echo "" >> "$HOME/.zshrc"

##########
# FINISH #
##########

# return to home
cd $HOME || exit 1

# clear pkg cache
pkg clean

# send toast
termux-toast -g top -b white -c black Setup done

# echo
echo "Setup done."
read -n 1 -r -s
