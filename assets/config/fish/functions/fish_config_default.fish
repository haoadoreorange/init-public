function fish_config_default --description 'customized default config fish shell'
    set -L
    set -U fish_color_normal normal
    set -U fish_color_command 00ffff
    set -U fish_color_quote 00ff5f
    set -U fish_color_redirection 00ffff
    set -U fish_color_end ff87af
    set -U fish_color_error ff0000
    set -U fish_color_param ffff5f
    set -U fish_color_comment 9e9e9e
    set -U fish_color_match normal
    set -U fish_color_selection c0c0c0
    set -U fish_color_search_match ffff00
    set -U fish_color_history_current normal
    set -U fish_color_operator 00a6b2
    set -U fish_color_escape 00a6b2
    set -U fish_color_cwd 008000
    set -U fish_color_cwd_root 800000
    set -U fish_color_valid_path normal
    set -U fish_color_autosuggestion ff8787
    set -U fish_color_user 00ff00
    set -U fish_color_host normal
    set -U fish_color_cancel normal
    set -U fish_pager_color_completion normal
    set -U fish_pager_color_description B3A06D yellow
    set -U fish_pager_color_prefix normal --bold --underline
    set -U fish_pager_color_progress brwhite --background=cyan
end
