set -e

# Function to install package if not present
install_if_missing() {
    if ! command -v "$1" &> /dev/null; then
        echo "Installing $1..."
        sudo apt-get install -y "$2"
    else
        echo "$1 is already installed"
    fi
}

# Update package lists
echo "Updating package lists..."
sudo apt-get update -y

# Install build dependencies
echo "Installing build dependencies..."
sudo apt-get install -y build-essential zlib1g-dev libncurses5-dev libgdbm-dev \
    libnss3-dev libssl-dev libreadline-dev libffi-dev libsqlite3-dev \
    libbz2-dev python3-tk tk-dev liblzma-dev

# Install basic tools
install_if_missing zsh zsh
install_if_missing git git

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    echo "Installing Zsh plugins..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Update plugins list in .zshrc
    sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc
fi

# Install Starship and Nerd Fonts
if ! command -v starship &> /dev/null; then
    echo "Installing Starship and Nerd Fonts..."
    version='3.3.0'
    fonts_dir="${HOME}/.local/share/fonts"
    mkdir -p "$fonts_dir"
    
    zip_file="FiraCode.zip"
    download_url="https://github.com/ryanoasis/nerd-fonts/releases/download/v${version}/${zip_file}"
    echo "Downloading Nerd Fonts from $download_url"
    wget "$download_url"
    unzip "$zip_file" -d "$fonts_dir"
    rm "$zip_file"
    fc-cache -fv

    echo "Installing Starship prompt..."
    curl -fsSL https://starship.rs/install.sh | sh

    if ! grep -q "starship init zsh" "$HOME/.zshrc"; then
        echo 'eval "$(starship init zsh)"' >> "$HOME/.zshrc"
    fi
fi

# Install pyenv
if ! command -v pyenv &> /dev/null; then
    echo "Installing pyenv..."
    curl https://pyenv.run | bash
    
    if ! grep -q "PYENV_ROOT" "$HOME/.zshrc"; then
        {
            echo 'export PYENV_ROOT="$HOME/.pyenv"'
            echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"'
            echo 'eval "$(pyenv init -)"'
            echo 'eval "$(pyenv virtualenv-init -)"'
        } >> "$HOME/.zshrc"
    fi
    
    # Source the updated configuration
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
    
    echo "Installing Python 3.12..."
    pyenv install 3.12
fi

# Add git aliases if they don't exist
if ! grep -q "# Git aliases" "$HOME/.zshrc"; then
    echo "Adding git aliases..."
    {
        echo '# Git aliases'
        echo 'alias gs="git status"'
        echo 'alias ga="git add"'
        echo 'alias gaa="git add --all"'
        echo 'alias gc="git commit -m"'
        echo 'alias gp="git push"'
        echo 'alias gpl="git pull"'
        echo 'alias gb="git branch"'
        echo 'alias gco="git checkout"'
        echo 'alias gd="git diff"'
        echo 'alias gl="git log --oneline"'
        echo 'alias grh="git reset --hard"'
        echo 'alias grs="git reset --soft"'
        echo 'alias gst="git stash"'
        echo 'alias gstp="git stash pop"'
        echo 'alias gm="git merge"'
    } >> "$HOME/.zshrc"
fi

echo "Setup completed successfully!"



