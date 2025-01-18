# pane_title_update.plugin.zsh
# Dynamically updates tmux pane titles based on current command/program

# Check if we're running inside tmux
function _is_tmux() {
    [[ -n "$TMUX" ]]
}

# Get the current program name
function _get_current_program() {
    local current_program

    # Try getting the current process name
    current_program=$(ps -p $$ -o comm=)

    # If we're in vim/nvim, try to get the current file
    if [[ "$current_program" =~ "vim" ]]; then
        if [[ -n "$VIM" ]]; then
            local vim_file="${$(basename "${vim_file_name:-}"):-vim}"
            current_program="vim: $vim_file"
        fi
    fi

    # If we're in a git repository, append the current branch
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local branch=$(git symbolic-ref --short HEAD 2>/dev/null)
        if [[ -n "$branch" ]]; then
            current_program="$current_program [$branch]"
        fi
    fi

    echo "$current_program"
}

# Update pane title before executing a command
function _update_pane_title_preexec() {
    if _is_tmux; then
        local cmd="$1"
        # Truncate command if too long
        if [[ ${#cmd} -gt 30 ]]; then
            cmd="${cmd:0:27}..."
        fi
        tmux select-pane -T "$cmd"
    fi
}

# Update pane title after command completion
function _update_pane_title_precmd() {
    if _is_tmux; then
        local current_program=$(_get_current_program)
        tmux select-pane -T "$current_program"
    fi
}

# Set up the hooks
autoload -Uz add-zsh-hook
add-zsh-hook preexec _update_pane_title_preexec
add-zsh-hook precmd _update_pane_title_precmd

# Initial title update
_update_pane_title_precmd
