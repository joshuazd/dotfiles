
. "$HOME/.profile"

# Setting PATH for Python 2.7
# The original version is saved in .zprofile.pysave
# PATH="/Library/Frameworks/Python.framework/Versions/2.7/bin:${PATH}"
# export PATH

# Added by OrbStack: command-line tools and integration
# source ~/.orbstack/shell/init.zsh 2>/dev/null || :
eval "$(/opt/homebrew/bin/brew shellenv)"
eval $(/opt/homebrew/bin/brew shellenv)
eval "$(mise activate zsh)"

# AWS vars - portal Makefile depends on these being set
export AWS_PROFILE=joshua.zink-duda
export AWS_VAULT_BACKEND=keychain
export AWS_REGION=us-east-1
