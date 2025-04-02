# Dotfiles Setup

This repository contains my personal dotfiles, managed with [GNU Stow](https://www.gnu.org/software/stow/). Follow these steps to set up your environment.

## Installation

### 1. Clone the Repository

```sh
# Clone into the home directory or another location
cd ~
git clone https://github.com/Rusteee16/dotfiles.git
```

### 2. Install GNU Stow

If you don’t have Stow installed, install it with:

```sh
# On Fedora
sudo dnf install stow

# On Ubuntu/Debian
sudo apt install stow

# On Arch Linux
sudo pacman -S stow
```

### 3. Move into the Dotfiles Repository

```sh
cd ~/dotfiles
```

### 4. Stow Dotfiles

Run the following commands to symlink the configurations:

```sh
stow alias
stow lazygit
stow nvim
stow yazi
stow zsh
```--adopt <package>  # Take ownership of existing files
```

### 5. Reload the Shell

Once the setup is complete, restart your terminal.

