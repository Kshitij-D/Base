#!/usr/bin/env bash

# Exit immediately on error, treat unset variables as errors, print commands, fail on pipeline errors
set -euxo pipefail

# Trap any errors and print debug info
trap 'echo "ERROR at line $LINENO: Command \`$BASH_COMMAND\` exited with status $?"' ERR

echo "Starting setup script..."

# --- 3. Append tmux configuration to ~/.tmux.conf ---
echo "Appending to ~/.tmux.conf..."
cat <<EOF >>~/.tmux.conf

# --- Added by setup.sh ---
set-option -sg escape-time 10
set-option -a terminal-features 'xterm:RGB'
set-option -g focus-events on
set -g status-position top
set -o mode-keys vi
set -g mouse on
set-option -g history-limit 50000
EOF

# --- 4. Append customizations to ~/.bashrc ---
echo "Appending to ~/.bashrc..."
cat <<'EOF' >>~/.bashrc
# --- Added by setup.sh ---
eval "$(fzf --bash)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

auto_tmux() {
  if [ -z "$TMUX" ]; then
    tmux attach || tmux
  fi
}
auto_tmux

random_cowsay_fortune() {
  local cowfiles=($(cowsay -l | tail -n +2 | tr ' ' '\n')) # Get list of cows
  local random_cow=${cowfiles[$RANDOM % ${#cowfiles[@]}]}  # Select random cow
  fortune | cowsay -f "$random_cow"                        # Pipe fortune to random cowsay
}
random_cowsay_fortune

export VLLM_CONFIGURE_LOGGING=0
export NCCL_DEBUG=CRITICAL
export NCCL_DEBUG_SUBSYS=ALL
export NCCL_LAUNCH_MODE=PARALLEL
cd /home/t-ksdubey/
EOF

echo "Sourcing ~/.bashrc from ~/.bash_profile..."
echo -e "\n# --- Added by setup.sh ---\nsource ~/.bashrc" >>~/.bash_profile

echo "Cloning LazyVim starter config..."
git clone https://github.com/LazyVim/starter ~/.config/nvim

echo "Adding custom Neovim config..."
cat <<EOF >>~/.config/nvim/lua/config/options.lua
-- Added by setup.sh
vim.g.lazyvim_python_lsp = "basedpyright"
EOF

echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
echo "Installing packages with brew..."
brew install neovim htop nvtop fzf ripgrep fd fortune cowsay node tmux fastfetch jq

echo "Setup complete! Open a new shell or source your profile to pick up the changes."
