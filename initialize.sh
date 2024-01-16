#!/bin/bash

echo "--------------------------------"
echo "Starting Configuration..."
echo "Detected OS: $(uname)"
echo "--------------------------------"

# Detect the Operating System
OS="$(uname)"

# Array of software common to both Linux and MacOS
common_software=("zsh" "htop" "mc" "zip" "git" "jq" "wget" "curl" "cmatrix" "speedtest-cli")

# Add your desired npm packages to this array
npm_packages=("@0x4447/grapes") # Replace with actual package names

# Indexed arrays for MacOS specific software and their respective installation paths
macos_software=("iterm2" "brave-browser" "github" "visual-studio-code" "slack" "obs" "obsidian")
macos_software_paths=("/Applications/iTerm.app" "/Applications/Brave Browser.app" "/Applications/GitHub Desktop.app" "/Applications/Visual Studio Code.app" "/Applications/Slack.app" "/Applications/OBS.app" "/Applications/Obsidian.app")

# Function to determine the package manager (apt or yum)
detect_package_manager() {
    if command -v apt >/dev/null 2>&1; then
        PACKAGE_MANAGER="apt"
    elif command -v yum >/dev/null 2>&1; then
        PACKAGE_MANAGER="yum"
    else
        echo "No supported package manager found. Exiting..."
        exit 1
    fi
}

# Function to check if a software is installed
is_installed() 
{
    if [ "$OS" = "Darwin" ]; then
        for i in "${!macos_software[@]}"; do
            if [ "${macos_software[$i]}" = "$1" ]; then
                [ -d "${macos_software_paths[$i]}" ] && return 0
            fi
        done
    fi
    command -v $1 >/dev/null 2>&1
}

# Function to check if an npm package is installed globally
is_npm_package_installed() 
{
    npm list -g "$1" >/dev/null 2>&1
}

# Function to install software
install_software() {
    for software in "$@"; do
        if is_installed $software; then
            echo "$software is already installed."
        else
            echo "Installing $software..."
            if [ "$OS" = "Linux" ]; then
                if [ "$PACKAGE_MANAGER" = "apt" ]; then
                    sudo apt-get install -y $software
                elif [ "$PACKAGE_MANAGER" = "yum" ]; then
                    sudo yum install -y $software
                fi
            elif [ "$OS" = "Darwin" ]; then
                if [[ " ${macos_software[@]} " =~ " ${software} " ]]; then
                    brew install --cask $software
                else
                    brew install $software
                fi
            fi
        fi
    done
}

# Function to install npm packages globally
install_npm_packages() 
{
    echo "Installing global npm packages..."
    for package in "${npm_packages[@]}"; do
        if is_npm_package_installed $package; then
            echo "$package is already installed."
        else
            echo "Installing $package..."
            npm install -g $package
        fi
    done
}

# Function to install nvm and Node.js
install_node_nvm() 
{
    echo "Installing Node.js using nvm..."

    # Check if nvm is installed and source it
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        echo "nvm is already installed. Sourcing nvm..."
        . "$HOME/.nvm/nvm.sh"
    else
        echo "Installing nvm..."
        curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
        . "$HOME/.nvm/nvm.sh"
    fi

    # Check if the latest version of Node.js is already installed
    local latest_version="$(nvm ls-remote --lts | tail -1 | awk '{print $1}')"
    if [ "$(nvm current)" != "$latest_version" ]; then
        nvm install node # This installs the latest version of Node.js
    else
        echo "Latest Node.js ($latest_version) is already installed."
    fi
}

# Function to install Oh My Zsh
install_oh_my_zsh() 
{    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        echo "Oh My Zsh is already installed."
    else
        echo "Downloading and installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
}

#
#   Border
#

echo "Installing CLI Tools..."

# Install common software
install_software "${common_software[@]}"

echo "--------------------------------"
echo "Installing Desktop Applications..."

# Install MacOS specific software
if [ "$OS" = "Darwin" ]; then
    install_software "${macos_software[@]}"
fi

echo "--------------------------------"
echo "Setting up Node.js and NPM Packages..."

install_node_nvm
install_npm_packages

echo "--------------------------------"
echo "Installing Oh My Zsh..."

install_oh_my_zsh

echo "--------------------------------"
echo "Configuration Completed."
echo "--------------------------------"
