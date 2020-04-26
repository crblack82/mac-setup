#!/bin/zsh

#
# BEGIN HOMEBREW INSTALLATION
#

# Install Homebrew
which -s brew
if [[ $? != 0 ]] ; then
    xcode-select --install
    echo "Enter your password to accept the license agreement for Xcode CLI"
    sudo xcodebuild -license accept

    echo "Installing Homebrew"
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > /tmp/homebrew-install.log
else
    brew update && brew upgrade
fi

# Disable gatekeeper
echo "Disabling gatekeeper"
sudo spctl --master-disable

# Install Homebrew apps first since the Xcode CLI requires license acceptance
echo "Installing brew bundle"
brew bundle --file=brew-apps.txt

# Accept the license
echo "Enter your password to accept the license agreement for Xcode CLI"
sudo xcodebuild -license accept

# Install Homebrew taps
echo "Installing brew taps"
brew bundle --file=brew-taps.txt

# Install Homebrew casks
echo "Installing brew casks"
brew bundle --file=brew-casks.txt

# Install Homebrew cmds
echo "Installing brew cmds"
brew bundle --file=brew-cmds.txt

# Enable gatekeeper
echo "Enabling gatekeeper"
sudo spctl --master-enable

#
# BEGIN SHELL CUSTOMIZATIONS
#

# Make Homebrew zsh default shell
chsh -s /usr/local/bin/zsh

# Configure zsh/bash profile
[ ! -f ~/.bash_profile ] && echo 'export PATH="/usr/local/bin:/usr/local/opt/python/libexec/bin:$PATH"' > ~/.bash_profile && source ~/.bash_profile

if [ ! -f ~/.zprofile ]; then
	# Setup .zprofile
	echo 'export PATH="/usr/local/bin:/usr/local/opt/python/libexec/bin:$PATH"' > ~/.zprofile && source ~/.zprofile

	# Setup .zshrc file
	echo '# History
	[ -z "$HISTFILE" ] && HISTFILE="$HOME/.zsh_history"' >> ~/.zshrc

	# Setup .zshrc
	echo "source <(antibody init)
	antibody bundle <~/.zsh_plugins.txt

	HISTSIZE=50000
	SAVEHIST=10000
	setopt extended_history
	setopt hist_expire_dups_first
	setopt hist_ignore_dups
	setopt hist_ignore_space
	setopt inc_append_history
	setopt share_history

	# Changing directories
	setopt auto_cd
	setopt auto_pushd
	unsetopt pushd_ignore_dups
	setopt pushdminus

	# Completion
	setopt auto_menu
	setopt always_to_end
	setopt complete_in_word
	unsetopt flow_control
	unsetopt menu_complete
	zstyle ':completion:*:*:*:*:*' menu select
	zstyle ':completion:*' matcher-list 'm:{a-zA-Z-_}={A-Za-z_-}' 'r:|=*' 'l:|=* r:|=*'
	zstyle ':completion::complete:*' use-cache 1
	zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR
	zstyle ':completion:*' list-colors ''
	zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

	# Other
	setopt prompt_subst

	# zsh-history-substring-search key bindings
	bindkey '^[[A' history-substring-search-up
	bindkey '^[[B' history-substring-search-down

 	# Set aliases
	alias burp='brew update && brew upgrade && brew cu -a' " >> ~/.zshrc
fi

if [ ! -f ~/.zsh_plugins.txt ]; then
	# Setup .zsh_plugins.txt file
	echo 'zsh-users/zsh-autosuggestions
	zsh-users/zsh-completions
	zsh-users/zsh-history-substring-search
	zsh-users/zsh-syntax-highlighting
	romkatv/powerlevel10k' >> ~/.zsh_plugins.txt
fi

if [ ! -f ~/.zsh_plugins.txt ]; then
	# Setup .zsh_plugins.sh file
	# must be run again any time a change is made to ~/.zsh_plugins.txt
	antibody bundle < ~/.zsh_plugins.txt > ~/.zsh_plugins.sh
	echo 'source ~/.zsh_plugins.sh' >> ~/.zshrc
fi

if [ ! -d Fonts ]; then
	# Download fonts from https://github.com/romkatv/powerlevel10k#meslo-nerd-font-patched-for-powerlevel10k
	mkdir Fonts
	wget -LqP Fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
	wget -LqP Fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
	wget -LqP Fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
	wget -LqP Fonts https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf
fi

# Link sublime text
ln -sf /Applications/Sublime\ Text.app/Contents/SharedSupport/bin/subl /usr/local/bin/subl

# Link iCloud to home directory
ln -sf $HOME/Library/Mobile\ Documents/com~apple~CloudDocs/ $HOME/iCloud

# Improve dock performance
defaults write com.apple.Dock autohide-delay -float 0
defaults write com.apple.dock autohide-time-modifier -float 0.3;killall Dock