# 0xGit - SSH/GitHub Key Manager

## Overview

`0xgit` is a simple command-line tool for managing multiple SSH keys and GitHub accounts. It allows you to easily generate and switch between SSH keys, integrate with GitHub CLI (`gh`), and manage your Git configuration.

This tool is ideal for developers working with multiple GitHub accounts and SSH keys, simplifying the management process.

## Features

- **Generate SSH keys**: Easily create SSH keys for GitHub.
- **Manage multiple GitHub accounts**: Switch between different GitHub accounts and SSH keys.
- **GitHub CLI integration**: Automatically installs GitHub CLI if it's not found.
- **SSH connection testing**: Test your SSH connection to GitHub.
- **Global accessibility**: Once installed, `0xgit` is available from anywhere in your terminal.
- **Cross-platform compatibility**: Works on various Linux distributions and macOS.

## Installation

### Prerequisites

Make sure you have the following installed:
- **Git**: Version control system used by GitHub.
- **ssh-keygen**: Command to generate SSH keys.

### Install 0xgit

1. Download and run the `0xgit.sh` installer script.

   ```bash
   curl -sSL https://raw.githubusercontent.com/0xamirreza/0xGit/master/0xgit.sh -o 0xgit.sh && bash 0xgit.sh
   ```

2. The script will:
   - Check for dependencies (`git` and `ssh-keygen`)
   - Create the installation directory
   - Install the `0xgit` script
   - Set up your `PATH` environment variable for global accessibility

3. Once the installation is complete, restart your terminal or run `source ~/.bashrc` (or `source ~/.zshrc` or equivalent for your shell)

4. Run `0xgit` from anywhere in your terminal

## Compatibility

0xgit has been tested and works on the following operating systems:
- ✅ Debian/Ubuntu (apt-based systems)
- ✅ Fedora (dnf-based systems)
- ✅ RHEL/CentOS (yum-based systems)
- ✅ Arch Linux (pacman-based systems)
- ✅ openSUSE (zypper-based systems)
- ✅ macOS (with Homebrew or native tools)
- ✅ Alpine Linux (apk-based systems)
- ✅ Gentoo (emerge-based systems)
- ✅ Void Linux (xbps-based systems)
- ✅ NixOS (nix-based systems)

## Usage

After installation, you can use the `0xgit` command to manage your SSH keys and GitHub accounts.

### Available Commands

- **Check/Install GitHub CLI**: Ensure GitHub CLI is installed
- **Generate new key**: Create a new SSH key for GitHub
- **List keys**: List existing SSH keys
- **Delete key**: Delete an existing SSH key
- **GitHub Auth**: Authenticate with GitHub and test SSH connection
- **Set Git User**: Set or update your global Git user name and email
- **Show Git User**: Display your current Git user configuration
- **Switch User**: Switch between GitHub users and SSH keys

### 0xGit Usage

To start the manager, simply run:

```bash
0xgit
```

## Troubleshooting

If you encounter issues:

1. Ensure all dependencies are installed for your specific OS
2. Verify that `~/.local/bin` is in your PATH
3. Check that the script has execute permissions: `chmod +x ~/.local/bin/0xgit`
4. For SSH issues, verify your SSH agent is running: `eval "$(ssh-agent -s)"`

## Uninstallation

To uninstall `0xgit`, simply delete the installed script and the associated directory:

```bash
rm -f ~/.local/bin/0xgit
```

Additionally, you can remove the line added to your shell configuration (`~/.bashrc`, `~/.zshrc`, or equivalent) to remove the `0xgit` command from your PATH.

```bash
# Edit the appropriate file
nano ~/.bashrc # or nano ~/.zshrc or your shell's config file

# Remove the line that was added by the installer:
# export PATH="$HOME/.local/bin:$PATH"

# Save and close the file, then run:
source ~/.bashrc # or source ~/.zshrc or equivalent
```

## Contributing

Contributions are welcome! Feel free to submit issues, feature requests, or pull requests to the [GitHub repository](https://github.com/0xamirreza/0xGit).

## License

This project is licensed under the MIT License.
