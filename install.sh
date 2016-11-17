#!/bin/sh

# Installs dependencies for using mscmgmt
#
# 1. RVM -> to control Ruby versions.
# 2. .yadr -> for easier command line usage
# 3. FFMPEG
# 4. imagemagick
# 5. postgresql-9.6 -> Database
# 6. 

# 1.
if [ ! -d "$HOME/.rvm" ]; then
    echo "Installing RVM master branch"
    gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
    \curl -sSL https://get.rvm.io | bash -s master --ruby=2.3.2
    echo "RVM is Installed using $RUBY_VERSION"
    source $HOME/.rvm/scripts/rvm
else
    echo "RVM is installed"
fi

gem install rake
gem install bundler

if [ ! -d "$HOME/.yadr" ]; then
    echo "Installing YADR for the first time"
    git clone --depth=1 https://github.com/CromonMS/dotfiles.git "$HOME/.yadr"
    cd "$HOME/.yadr"
    [ "$1" = "ask" ] && export ASK="true"
    rake install
else
    echo "YADR is already installed"
fi

