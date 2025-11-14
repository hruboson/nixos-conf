# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

alias lg="lazygit"
alias nosleep="systemd-inhibit --what=handle-lid-switch sleep 90m"
alias ls="ls -la"
alias cls="clear"

# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
	for rc in ~/.bashrc.d/*; do
		if [ -f "$rc" ]; then
			. "$rc"
		fi
	done
fi

unset rc

# Fetch
if  [[ $- == *i* ]]; then # ensures scp works
	macchina
fi
