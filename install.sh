#!/usr/bin/env bash

# Colors for pretty output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print with color
print_status() {
    echo -e "${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check for required commands
check_requirements() {
    local missing_reqs=0
    
    if ! command -v tmux >/dev/null 2>&1; then
        print_error "tmux is not installed"
        missing_reqs=1
    fi
    
    if ! command -v zsh >/dev/null 2>&1; then
        print_error "zsh is not installed"
        missing_reqs=1
    fi
    
    if [ $missing_reqs -eq 1 ]; then
        exit 1
    fi
}

# Install tmux configuration
install_tmux_config() {
    print_status "Installing tmux configuration..."
    
    # Create necessary directories
    mkdir -p ~/.tmux/themes
    
    # Install theme
    cp themes/exmachina.tmux.conf ~/.tmux/themes/
    cp config/.tmux.conf ~/.tmux.conf
    
    print_success "Tmux configuration installed"
}

# Install ZSH plugins
install_zsh_plugins() {
    print_status "Installing ZSH plugins..."
    
    # Determine ZSH custom plugins directory
    local zsh_custom=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}
    mkdir -p "$zsh_custom/plugins/tmux-ex-machina"
    
    # Copy plugin files
    cp -r plugins/* "$zsh_custom/plugins/tmux-ex-machina/"
    
    print_success "ZSH plugins installed"
    print_status "Add 'tmux-ex-machina' to your plugins array in .zshrc:"
    echo "plugins=(... tmux-ex-machina)"
}

# Install Vim plugin
install_vim_plugin() {
    print_status "Installing Vim plugin..."
    
    # Install for Vim
    if [ -d ~/.vim ]; then
        mkdir -p ~/.vim/plugin
        cp plugins/pane-title/vim-pane-title.vim ~/.vim/plugin/
        print_success "Vim plugin installed"
    fi
    
    # Install for Neovim
    if [ -d ~/.config/nvim ]; then
        mkdir -p ~/.config/nvim/plugin
        cp plugins/pane-title/vim-pane-title.vim ~/.config/nvim/plugin/
        print_success "Neovim plugin installed"
    fi
}

# Backup existing configuration
backup_existing_config() {
    print_status "Backing up existing configuration..."
    
    local timestamp=$(date +%Y%m%d_%H%M%S)
    
    if [ -f ~/.tmux.conf ]; then
        mv ~/.tmux.conf ~/.tmux.conf.backup.$timestamp
        print_success "Backed up ~/.tmux.conf"
    fi
}

# Main installation
main() {
    print_status "Installing TMux Ex Machina..."
    
    check_requirements
    backup_existing_config
    install_tmux_config
    install_zsh_plugins
    install_vim_plugin
    
    print_success "Installation complete!"
    echo
    print_status "Next steps:"
    echo "1. Add 'tmux-ex-machina' to your plugins in .zshrc"
    echo "2. Restart your tmux server: tmux kill-server"
    echo "3. Start a new tmux session"
}

# Run the installer
main
