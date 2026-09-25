fish_add_path /opt/homebrew/bin

# Flutter / FVM
if test -d $HOME/fvm/default/bin
    fish_add_path $HOME/fvm/default/bin
end

# Standard Flutter (if not using FVM)
if test -d /opt/homebrew/Caskroom/flutter/latest/flutter/bin
    fish_add_path /opt/homebrew/Caskroom/flutter/latest/flutter/bin
end
