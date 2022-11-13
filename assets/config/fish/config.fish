if status is-interactive
    # Commands to run in interactive sessions can go here
    if [ "$FISH_CONFIGURED" != true ]
        fish_config_default >/dev/null
        set -U FISH_CONFIGURED true
    end
    bind \e\; begin-selection
    bind \e\' end-selection
    bind \cx 'fish_clipboard_copy; commandline -f end-selection'
    bind \ev __fish_vimed
    fzf_configure_bindings --variables=\e\cv
    
    functions load_nvm >/dev/null
    . "$HOME"/.config/fish/colorman.fish
    starship init fish | source
end
