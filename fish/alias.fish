# vim -> nvim
alias vim='nvim'

# GitHub
alias hb="hub browse"

# Git
alias g='git'
alias ga='git add -A'
alias gc='git commit --verbose'
alias gp='git push'
alias gf='git fetch'
alias gcash='git rm -r --cached .'

# Cmd
alias ll='ls -a -l -h -p'
alias tx='tmux a'
alias tn='tmux new -s'
alias tt="bash ~/dotfiles/tmux_tpl.sh"

#Reboot shell
alias sh_reboot='exec $SHELL -l'

#Setting_dotfile
alias dotfile='git -C ~/dotfiles/ pull && code ~/dotfiles/'
alias memo='git -C ~/work/memo/ pull && code ~/work/memo/'
