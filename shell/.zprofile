####################################
# ZSH PROFILE - LOGIN SHELL
####################################
# Sourced by login zsh shells
# Sources .profile for environment, then sets up zsh-specific tools

. "$HOME/.profile"

# Homebrew environment (macOS)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Mise (polyglot runtime manager)
eval "$(mise activate zsh)"

####################################
# AWS CONFIGURATION
####################################
# Portal Makefile depends on these being set

export AWS_PROFILE=joshua.zink-duda
export AWS_VAULT_BACKEND=keychain
export AWS_REGION=us-east-1
