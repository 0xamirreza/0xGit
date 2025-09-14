#!/bin/bash

# 0xgit Installer Script
# Creates a global SSH/GitHub key manager accessible via '0xgit' command

SCRIPT_NAME="0xgit"
INSTALL_DIR="$HOME/.local/bin"
SCRIPT_PATH="$INSTALL_DIR/$SCRIPT_NAME"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_banner() {
    clear
    echo
    echo -e "${CYAN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC}        ${BOLD}0xgit SSH/GitHub Manager${NC}           ${CYAN}║${NC}"
    echo -e "${CYAN}║${NC}              ${YELLOW}Installation Script${NC}              ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════╝${NC}"
    echo
}

check_dependencies() {
    echo -e "${BLUE}🔍 Checking dependencies...${NC}"

    # Check if git is installed
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git is not installed. Please install git first.${NC}"
        exit 1
    fi

    # Check if ssh-keygen is installed
    if ! command -v ssh-keygen &> /dev/null; then
        echo -e "${RED}❌ ssh-keygen is not installed. Please install openssh-client.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Dependencies check passed${NC}"
}

create_install_directory() {
    echo -e "${BLUE}📁 Creating installation directory...${NC}"
    mkdir -p "$INSTALL_DIR"

    if [[ ! -d "$INSTALL_DIR" ]]; then
        echo -e "${RED}❌ Failed to create directory: $INSTALL_DIR${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Directory created: $INSTALL_DIR${NC}"
}

install_script() {
    echo -e "${BLUE}📥 Installing 0xgit script...${NC}"

    # Create the main script
    cat << 'SCRIPT_CONTENT' > "$SCRIPT_PATH"
#!/bin/bash

SSH_DIR="$HOME/.ssh"
CONFIG_FILE="$SSH_DIR/config"

# 1. بررسی نصب gh - Updated with OS detection and correct package names
check_install_gh() {
    echo "🔍 Checking for GitHub CLI (gh)..."

    if command -v gh &>/dev/null; then
        GH_VER=$(gh --version | head -n1)
        echo -e "\e[1;32m✅ GH CLI is already installed:\e[0m $GH_VER"
        return
    fi

    echo -e "\e[1;33m⚠️ GH CLI not found. Installing...\e[0m"

    if command -v apt &>/dev/null; then
        echo "📦 Using apt (Debian/Ubuntu)..."
        sudo apt update
        sudo apt install gh -y

    elif command -v dnf &>/dev/null; then
        echo "📦 Using dnf (Fedora)..."
        sudo dnf install gh -y

    elif command -v yum &>/dev/null; then
        echo "📦 Using yum (RHEL/CentOS)..."
        sudo yum install gh -y

    elif command -v pacman &>/dev/null; then
        echo "📦 Using pacman (Arch Linux)..."
        sudo pacman -S github-cli --noconfirm

    elif command -v zypper &>/dev/null; then
        echo "📦 Using zypper (openSUSE)..."
        sudo zypper install gh -y

    elif command -v brew &>/dev/null; then
        echo "📦 Using Homebrew (macOS/Linux)..."
        brew install gh

    elif command -v apk &>/dev/null; then
        echo "📦 Using apk (Alpine Linux)..."
        sudo apk add github-cli

    elif command -v emerge &>/dev/null; then
        echo "📦 Using emerge (Gentoo)..."
        sudo emerge dev-util/github-cli

    elif command -v xbps-install &>/dev/null; then
        echo "📦 Using xbps (Void Linux)..."
        sudo xbps-install -S github-cli

    elif command -v nix-env &>/dev/null; then
        echo "📦 Using nix (NixOS)..."
        nix-env -iA nixpkgs.github-cli

    else
        echo -e "\e[1;31m❌ Could not detect package manager.\e[0m"
        echo "Please install GH CLI manually from: https://cli.github.com/manual/installation"
        echo
        echo "Common manual installation methods:"
        echo "• Download from: https://github.com/cli/cli/releases"
        echo "• Arch Linux: sudo pacman -S github-cli"
        echo "• Or use curl: curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg"
        read -p "⏎ Press Enter to continue without GH CLI (some features may not work)..."
        return 1
    fi

    # Verify installation
    if command -v gh &>/dev/null; then
        GH_VER=$(gh --version | head -n1)
        echo -e "\e[1;32m✅ GH installed successfully:\e[0m $GH_VER"
    else
        echo -e "\e[1;31m❌ GH installation failed.\e[0m"
        echo "Please install manually from: https://cli.github.com/manual/installation"
        echo "For Arch Linux: sudo pacman -S github-cli"
        read -p "⏎ Press Enter to continue without GH CLI (some features may not work)..."
        return 1
    fi

    sleep 1
}

# 2. مدیریت بخش github.com در ssh/config
add_to_config() {
    KEY_NAME="$1"
    # بخش موردنظر اگر هست، فقط IdentityFile را تغییر بده
    if grep -q "^Host github.com$" "$CONFIG_FILE" 2>/dev/null; then
        # تغییر یا افزودن IdentityFile
        if grep -A 3 "^Host github.com$" "$CONFIG_FILE" | grep -q "IdentityFile "; then
            # جایگزین IdentityFile فعلی با جدید
            sed -i "/^Host github.com$/,/^Host / s|^\s*IdentityFile .*|    IdentityFile ~/.ssh/${KEY_NAME}|" "$CONFIG_FILE"
        else
            # اگر IdentityFile نبود، اضافه کن بعد Host github.com
            sed -i "/^Host github.com$/a \    IdentityFile ~/.ssh/${KEY_NAME}" "$CONFIG_FILE"
        fi
        echo "✅ Updated 'IdentityFile' in github.com section of config"
    else
        # اگر نبود، کل بخش را بساز
        cat <<EOF >> "$CONFIG_FILE"

Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/${KEY_NAME}
EOF
        echo "✅ Added section for github.com in config"
    fi
}

remove_from_config() {
    KEY_NAME="$1"
    # پیدا کن که آیا این کلید فعلی در IdentityFile هست
    if grep -q "IdentityFile ~/.ssh/${KEY_NAME}" "$CONFIG_FILE" 2>/dev/null; then
        # فقط خط IdentityFile موردنظر را حذف کن
        sed -i "/^Host github.com$/,/^Host / s|^\s*IdentityFile ~/.ssh/${KEY_NAME}||" "$CONFIG_FILE"
        echo "✅ Removed 'IdentityFile ~/.ssh/${KEY_NAME}' from github.com config"
    fi
}

# لیست کاربران بر اساس public key
list_key_users() {
    for PUB in "$SSH_DIR"/*.pub; do
        if [[ -f "$PUB" ]]; then
            name=$(basename "$PUB" .pub)
            email=$(grep "@" "$PUB" | awk '{print $3}')
            echo -e "[$name]  $email"
        fi
    done
}

banner() {
    clear
    echo
    echo -e "============[ 🔑 \e[1;32mSSH/GitHub Key Manager\e[0m ]============"
    echo "──────────────────────────────────────────────────────────────"
}

# منوی اصلی
while true; do
    banner
    echo -e "A) Check/Install GH CLI"
    echo -e "1) Generate new key"
    echo -e "2) List keys"
    echo -e "3) Delete key"
    echo -e "4) GH Auth (gh auth login + SSH test)"
    echo -e "5) Set Git User (name/email)"
    echo -e "6) Show Git User"
    echo -e "7) Change User (switch key/user/email/ssh test)"
    echo -e "0) Exit"
    echo "──────────────────────────────────────────────────────────────"
    read -p "➡️  Enter your choice [A/1/2/3/4/5/6/7/0]: " ACTION
    echo

    case "$ACTION" in

    [aA])
        check_install_gh
        read -p "⏎ Press Enter to return to menu...";;

    1)
        read -p "📧 GitHub email: " GIT_EMAIL
        read -p "📝 Key name (Example: id_ed25519_github): " KEY_NAME

        if [[ -z "$KEY_NAME" || "$KEY_NAME" =~ [^a-zA-Z0-9._-] ]]; then
            echo "❌ Invalid key name!"
            sleep 1; continue
        fi

        KEY_PATH="$SSH_DIR/$KEY_NAME"
        if [[ -f "$KEY_PATH" ]]; then
            echo "⚠️ Key already exists: $KEY_PATH"
            read -p "Overwrite? (y/N): " OVERWRITE
            [[ "$OVERWRITE" != [yY] ]] && echo "❌ Aborted." && sleep 1 && continue
        fi

        ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$KEY_PATH" -N ""
        eval "$(ssh-agent -s)"
        ssh-add "$KEY_PATH"
        add_to_config "$KEY_NAME"
        echo "🔒 Never share the private key: $KEY_PATH"
        echo -e "\n✅ Public key (add to GitHub):\n─────────────────────────────────"
        cat "$KEY_PATH.pub"
        echo "──────────────────────────────────────────────────────────────"
        echo "📌 Github: Settings → SSH keys → New → Paste above key"
        read -p "⏎ Press Enter to return to menu..."
        ;;

    2)
        # لیست کلیدها
        while true; do
            echo "🔑 Existing public keys:"
            echo "──────────────────────────────────────────────────────────────"
            find "$SSH_DIR" -maxdepth 1 -type f -name "*.pub" -exec basename {} \;
            echo "──────────────────────────────────────────────────────────────"
            echo "b) Back to main menu"
            read -p "👀 Enter key name to show content (leave empty for back): " KEY_TO_SHOW
            [[ -z "$KEY_TO_SHOW" || "$KEY_TO_SHOW" == "b" ]] && break
            if [[ "$KEY_TO_SHOW" == *.pub ]]; then
                KEY_FILE="$SSH_DIR/$KEY_TO_SHOW"
            else
                KEY_FILE="$SSH_DIR/$KEY_TO_SHOW.pub"
            fi
            if [[ -f "$KEY_FILE" ]]; then
                echo "──────────────────────────────────────────────────────────────"
                cat "$KEY_FILE"
                echo "──────────────────────────────────────────────────────────────"
            else
                echo "❌ Key not found."
            fi
            read -p "⏎ Press Enter to continue..."
            clear
        done
        ;;

    3)
        # حذف کلید با حذف IdentityFile
        while true; do
            echo "🔑 Existing keys:"
            find "$SSH_DIR" -maxdepth 1 -type f -name "*.pub" -exec basename {} \;
            echo "b) Back to main menu"
            read -p "🗑️ Enter key name to delete (without .pub, or b for back): " KEY_TO_DELETE
            [[ -z "$KEY_TO_DELETE" || "$KEY_TO_DELETE" == "b" ]] && break
            [[ "$KEY_TO_DELETE" == *.pub ]] && KEY_TO_DELETE="${KEY_TO_DELETE%.pub}"
            if [[ -f "$SSH_DIR/$KEY_TO_DELETE" || -f "$SSH_DIR/$KEY_TO_DELETE.pub" ]]; then
                read -p "⚠️ Really delete '$KEY_TO_DELETE' and '$KEY_TO_DELETE.pub'? (y/N): " DEL
                if [[ "$DEL" == [yY] ]]; then
                    rm -f "$SSH_DIR/$KEY_TO_DELETE" "$SSH_DIR/$KEY_TO_DELETE.pub"
                    remove_from_config "$KEY_TO_DELETE"
                    echo "✅ Key '$KEY_TO_DELETE' deleted and config updated."
                else
                    echo "❌ Aborted."
                fi
            else
                echo "❌ Key not found."
            fi
            read -p "⏎ Press Enter to continue..."
            clear
        done
        ;;

    4)
        # GH AUTH
        check_install_gh
        if command -v gh &>/dev/null; then
            echo -e "\e[1;36m🔗 Starting GH auth login ...\e[0m"
            gh auth login
            echo -e "\n🔎 Checking SSH connection to GitHub ..."
            ssh -T git@github.com
        else
            echo -e "\e[1;31m❌ GH CLI is not available. Please install it first using option A.\e[0m"
        fi
        read -p "⏎ Press Enter to return to menu..."
        ;;

    5)
        read -p "📝 Enter new user.name: " NEW_NAME
        read -p "📧 Enter new user.email: " NEW_EMAIL
        git config --global user.name "$NEW_NAME"
        git config --global user.email "$NEW_EMAIL"
        echo "✅ User info set."
        git config --global user.name
        git config --global user.email
        read -p "⏎ Press Enter to return to menu..."
        ;;

    6)
        echo "Current git global user.name & user.email:"
        git config --list --show-origin | grep -E "user.name|user.email"
        read -p "⏎ Press Enter to return to menu..."
        ;;

    7)
        echo "Available Users and keys:"
        list_key_users
        read -p "Enter key name for switch (without .pub): " SWITCH_KEY
        [[ "$SWITCH_KEY" == *.pub ]] && SWITCH_KEY="${SWITCH_KEY%.pub}"
        if [[ -f "$SSH_DIR/$SWITCH_KEY.pub" ]]; then
            SWITCH_EMAIL=$(grep "@" "$SSH_DIR/$SWITCH_KEY.pub" | awk '{print $3}')
            if [[ -z "$SWITCH_EMAIL" ]]; then
                read -p "Enter email for this key: " SWITCH_EMAIL
            fi
            git config --global user.name "$SWITCH_KEY"
            git config --global user.email "$SWITCH_EMAIL"
            add_to_config "$SWITCH_KEY"
            echo "✅ Switched git user and SSH config to: $SWITCH_KEY [$SWITCH_EMAIL]"

            # ===== New: run SSH test with new key =====
            echo -e "\n🔎 Testing SSH connection with the switched key..."
            # Ensure ssh uses the agent and config; run verbose test but quiet known_hosts prompt
            ssh -T git@github.com 2>&1 | sed -n '1,200p'
            SSH_EXIT=${PIPESTATUS[0]}
            if [[ $SSH_EXIT -eq 1 || $SSH_EXIT -eq 255 ]]; then
                echo -e "\n⚠️ SSH test returned non-zero exit ($SSH_EXIT). If you see 'Permission denied' or 'Agent admitted failure', ensure the key is added to ssh-agent and the public key is in your GitHub account."
            fi
            # =========================================

            git config --global user.name
            git config --global user.email
        else
            echo "❌ Key not found."
        fi
        read -p "⏎ Press Enter to return to menu..."
        ;;

    0)
        echo -e "👋 Exiting..."; exit 0
        ;;

    *)
        echo "❌ Invalid option!"
        sleep 1
        ;;
    esac
done
SCRIPT_CONTENT

    # Make the script executable
    chmod +x "$SCRIPT_PATH"

    if [[ -f "$SCRIPT_PATH" && -x "$SCRIPT_PATH" ]]; then
        echo -e "${GREEN}✅ Script installed successfully: $SCRIPT_PATH${NC}"
    else
        echo -e "${RED}❌ Failed to install script${NC}"
        exit 1
    fi
}

setup_path() {
    echo -e "${BLUE}🔧 Setting up PATH...${NC}"

    # Check if the directory is already in PATH
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        # Determine which shell config file to use
        SHELL_CONFIG=""
        if [[ "$SHELL" == */zsh ]]; then
            SHELL_CONFIG="$HOME/.zshrc"
        elif [[ "$SHELL" == */bash ]]; then
            if [[ -f "$HOME/.bashrc" ]]; then
                SHELL_CONFIG="$HOME/.bashrc"
            else
                SHELL_CONFIG="$HOME/.bash_profile"
            fi
        elif [[ -f "$HOME/.profile" ]]; then
            SHELL_CONFIG="$HOME/.profile"
        fi

        if [[ -n "$SHELL_CONFIG" ]]; then
            echo -e "${BLUE}📝 Adding $INSTALL_DIR to PATH in $SHELL_CONFIG${NC}"
            echo "" >> "$SHELL_CONFIG"
            echo "# Added by 0xgit installer" >> "$SHELL_CONFIG"
            echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_CONFIG"
            echo -e "${GREEN}✅ PATH updated in $SHELL_CONFIG${NC}"
            echo -e "${YELLOW}⚠️  Please run 'source $SHELL_CONFIG' or restart your terminal${NC}"
        else
            echo -e "${YELLOW}⚠️  Could not determine shell config file. Please manually add $INSTALL_DIR to your PATH${NC}"
        fi
    else
        echo -e "${GREEN}✅ $INSTALL_DIR is already in PATH${NC}"
    fi
}

create_ssh_directory() {
    echo -e "${BLUE}📁 Ensuring SSH directory exists...${NC}"
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    echo -e "${GREEN}✅ SSH directory ready${NC}"
}

show_completion_message() {
    echo
    echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║${NC}            ${BOLD}Installation Complete!${NC}             ${GREEN}║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
    echo
    echo -e "${CYAN}📋 What was installed:${NC}"
    echo -e "   • 0xgit script: ${BOLD}$SCRIPT_PATH${NC}"
    echo -e "   • PATH configuration updated"
    echo -e "   • SSH directory prepared"
    echo
    echo -e "${CYAN}🚀 How to use:${NC}"
    echo -e "   1. Restart your terminal or run: ${BOLD}source ~/.bashrc${NC} (or ~/.zshrc)"
    echo -e "   2. Type: ${BOLD}0xgit${NC}"
    echo -e "   3. Enjoy managing your SSH keys and GitHub accounts!"
    echo
    echo -e "${CYAN}🔧 Features:${NC}"
    echo -e "   • Generate SSH keys"
    echo -e "   • Manage multiple GitHub accounts"
    echo -e "   • Switch between different users"
    echo -e "   • GitHub CLI integration with OS detection"
    echo -e "   • SSH connection testing"
    echo
    echo -e "${YELLOW}💡 Tip: Run '0xgit' from anywhere in your system!${NC}"
    echo
}

# Main installation process
main() {
    print_banner

    echo -e "${CYAN}This installer will set up 0xgit SSH/GitHub Manager on your system.${NC}"
    echo -e "${CYAN}The tool will be accessible globally via the '0xgit' command.${NC}"
    echo
    read -p "$(echo -e ${YELLOW}Continue with installation? [Y/n]:${NC} )" -n 1 -r
    echo

    if [[ $REPLY =~ ^[Nn]$ ]]; then
        echo -e "${RED}Installation cancelled.${NC}"
        exit 0
    fi

    echo
    echo -e "${BOLD}Starting installation...${NC}"
    echo

    check_dependencies
    create_install_directory
    create_ssh_directory
    install_script
    setup_path

    show_completion_message
}

# Run the installer
main "$@"
