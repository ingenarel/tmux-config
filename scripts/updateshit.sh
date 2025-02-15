#!/usr/bin/bash

update_stuff() {
    eval $1 &&
    {
        timeout --kill-after=4 --signal=TERM 4\
            notify-send -u critical "$2" || hyprctl notify 1 10000 "rgb(ff1ea3)" "fontsize:30 $2"
        timeout --kill-after=4 --signal=TERM 4\
            paplay $HOME/.config/tmux/sounds/notif.mp3
    } ||
    {
        timeout --kill-after=4 --signal=TERM\
            notify-send -u critical "$2 failed!" "Updating $3..."
        timeout --kill-after=4 --signal=TERM\
            paplay $HOME/.config/tmux/sounds/error.mp3
    }
}

if [[ $(grep -E -i "gentoo" /etc/os-release) ]]; then
    update_stuff "sudo emerge --sync"                                                                           "Synced repositories; updating system packages..."
    update_stuff "eix-update"
    update_stuff "sudo emerge --ask --verbose --update --deep --newuse @world --keep-going"                     "Updated system packages; updating live ebuilds..."
    update_stuff "sudo smart-live-rebuild"                                                                      "Updated live ebuilds; updating yazi plugins..."
elif [[ $(grep -E -i "arch" /etc/os-release) ]]; then
    update_stuff "paru"
fi
update_stuff "ya pack --upgrade"                                                                            "Updated yazi plugins; updating zsh plugins..."
update_stuff "zsh -c \"source $HOME/.local/share/zinit/zinit.git/zinit.zsh && zinit update --all\""                    "Updated zsh plugins; updating cargo packages..."
update_stuff "cargo install-update -a"                                                                      "Updated cargo packages; updating tmux plugins..."
update_stuff "$HOME/.tmux/plugins/tpm/bin/clean_plugins && $HOME/.tmux/plugins/tpm/bin/update_plugins all"  "Updated tmux plugins; updating neovim plugins..."
update_stuff "nvim --headless '+Lazy! clean' '+Lazy! update' '+MasonUpdate' +qa"                            "Updated neovim plugins; updating neovim-mason's packages..."
update_stuff "nvim -c Mason"                                                                                "Updated neovim-mason's packages"
