function __fish_vimed --description 'Open the current command output in vim'
    fish_commandline_append " | vim -"
end
