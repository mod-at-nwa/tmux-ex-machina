#!/usr/bin/env zsh

# status.plugin.zsh
# Plugin for managing tmux window titles and powerlevel10k status messages

# Ensure we're running in zsh
if [[ -n "${ZSH_VERSION}" ]]; then

    # Define the main status function
    function status() {
        local status_msg="$1"
        
        # Validate input
        if [[ -z "$status_msg" ]]; then
            echo "Usage: status \"your status message\""
            return 1
        fi
        
        # Set p10k right-side status message if powerlevel10k is active
        if [[ -n "$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" ]]; then
            # Remove any existing custom_status to prevent duplication
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${(@)POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#custom_status}")
            # Add new custom status
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS+=(custom_status)
            POWERLEVEL9K_CUSTOM_STATUS="echo -n 'status: $status_msg'"
        fi

        # Update tmux window title if in tmux session
        if [[ -n "$TMUX" ]]; then
            # Store the original automatic-rename setting
            local auto_rename=$(tmux show-window-options -v automatic-rename)
            # Disable automatic renaming
            tmux set-window-option automatic-rename off
            # Set the window name
            tmux rename-window "$status_msg"
            # Store the status message for restoration after commands
            export TMUX_CUSTOM_STATUS="$status_msg"
        fi
    }

    # Function to clear the status
    function clear_status() {
        # Clear p10k custom status if it exists
        if [[ -n "$POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS" ]]; then
            POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=("${(@)POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS:#custom_status}")
            unset POWERLEVEL9K_CUSTOM_STATUS
        fi

        # Reset tmux window title if in tmux
        if [[ -n "$TMUX" ]]; then
            unset TMUX_CUSTOM_STATUS
            tmux set-window-option automatic-rename on
        fi
    }

    # Cleanup function for shell exit
    function _cleanup_status() {
        clear_status
    }

    # Function to restore status after command execution
    function _restore_status() {
        if [[ -n "$TMUX_CUSTOM_STATUS" && -n "$TMUX" ]]; then
            tmux rename-window "$TMUX_CUSTOM_STATUS"
        fi
    }

    # Hook into zsh events
    autoload -Uz add-zsh-hook
    add-zsh-hook zshexit _cleanup_status
    add-zsh-hook precmd _restore_status

    # Export the functions for use in other scripts
    # export -f status
    # export -f clear_status
fi
