#!/bin/bash

# Ensure the script runs as root
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root (use sudo)."
    exit 1
fi

# Check for -y flag to install all without prompts
AUTO_CONFIRM=false
if [[ "$1" == "-y" ]]; then
    AUTO_CONFIRM=true
fi

# Function to prompt user for confirmation
confirm_install() {
    if [ "$AUTO_CONFIRM" = true ]; then
        return 0
    fi
    read -p "Do you want to install $1? (y/N) " response
    case "$response" in
        [yY][eE][sS]|[yY])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Update system
confirm_install "system update" && sudo dnf update -y

# Enable COPR repository for LazyGit
if ! sudo dnf copr list | grep -q "atim/lazygit"; then
    confirm_install "Enable LazyGit COPR repo" && sudo dnf copr enable atim/lazygit -y
else
    echo "COPR repository for LazyGit is already enabled. Skipping."
fi

# List of packages to install
PACKAGES=(
    fzf
    zsh
    btop
    lazygit
    lsd
    neovim
    lua
    git
    curl
    wget
    unzip
    tar
    tmux
    ripgrep
    bat
    postgresql
    dnf-plugins-core
)

# Install packages
for pkg in "${PACKAGES[@]}"; do
    if ! command -v "$pkg" &> /dev/null; then
        confirm_install "$pkg" && sudo dnf install -y "$pkg"
    else
        echo "$pkg is already installed. Skipping."
    fi
done

# Install Docker
confirm_install "Docker" && sudo dnf -y install dnf-plugins-core && \
    sudo dnf-3 config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo && \
    sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin && \
    sudo systemctl enable --now docker

# Install Brave Browser
confirm_install "Brave Browser" && sudo dnf config-manager --add-repo --from-repofile=https://brave-browser-rpm-release.s3.brave.com/brave-browser.repo && \
    sudo dnf install -y brave-browser

# Install Rust and Cargo
if ! command -v cargo &> /dev/null; then
    confirm_install "Rust" && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y && source "$HOME/.cargo/env"
else
    echo "Rust is already installed. Skipping."
fi

# Install Yazi using Cargo
if ! command -v yazi &> /dev/null; then
    confirm_install "Yazi" && cargo install --locked yazi-fm yazi-cli
else
    echo "Yazi is already installed. Skipping."
fi

# Install Yazi packages using Yazi package manager
if command -v yazi &> /dev/null; then
    confirm_install "Yazi flavors" && ya pack -a dangooddd/kanagawa
    confirm_install "Yazi plugins" && ya pack -a yazi-rs/plugins:full-border && ya pack -a yazi-rs/plugins:git && ya pack -a yazi-rs/plugins:mount
else
    echo "Yazi is not installed. Skipping Yazi package installation."
fi

# Install Alacritty using Cargo
if ! command -v alacritty &> /dev/null; then
    confirm_install "Alacritty" && cargo install alacritty
else
    echo "Alacritty is already installed. Skipping."
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    confirm_install "Oh My Zsh" && RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "Oh My Zsh is already installed. Skipping."
fi

# Install Zinit
if [ ! -d "$HOME/.zinit" ]; then
    confirm_install "Zinit" && bash -c "$(curl --fail --show-error --silent --location https://raw.githubusercontent.com/zdharma-continuum/zinit/HEAD/scripts/install.sh)"
else
    echo "Zinit is already installed. Skipping."
fi

# Ensure existing dotfiles are not altered, only updating missing configurations
DOTFILES=(
    "$HOME/.zshrc"
    "$HOME/update.sh"
    "$HOME/.config"
)

for file in "${DOTFILES[@]}"; do
    if [ -e "$file" ]; then
        echo "$file already exists. Skipping."
    else
        echo "$file is missing. Please ensure your dotfiles repository is properly cloned."
    fi
done

# Install FiraCode Nerd Font
FONTS_DIR="$HOME/.local/share/fonts"
FIRA_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
mkdir -p "$FONTS_DIR"
if [ ! -d "$FONTS_DIR/FiraCodeNerdFont" ]; then
    confirm_install "FiraCode Nerd Font" && wget -O /tmp/FiraCode.zip "$FIRA_FONT_URL" && unzip -o /tmp/FiraCode.zip -d "$FONTS_DIR/FiraCodeNerdFont" && fc-cache -fv
    echo "FiraCode Nerd Font installed successfully."
else
    echo "FiraCode Nerd Font is already installed. Skipping."
fi

# Change default shell to zsh
if [[ "$SHELL" != "$(which zsh)" ]]; then
    confirm_install "Change default shell to Zsh" && chsh -s "$(which zsh)"
else
    echo "Zsh is already the default shell. Skipping."
fi

# Cleanup
confirm_install "Cleanup unused packages" && sudo dnf autoremove -y

echo "Installation completed successfully. Restart your terminal for changes to take effect."

