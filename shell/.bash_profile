####################################
# BASH PROFILE - LOGIN SHELL
####################################
# Sourced by login bash shells
# Sources .profile for environment, then .bashrc for interactive config

. "$HOME/.profile"
[[ $- != *i* ]] || . "$HOME/.bashrc"
