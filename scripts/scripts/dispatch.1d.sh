#!/bin/bash
#
# SwiftBar plugin — dispatch the current Chrome tab to the right workflow.
#
# Shows ⚡ in the menu bar. Clicking "Dispatch current Chrome tab" calls
# dispatch-from-chrome, which routes Shortcut story URLs to shortcut-implement
# and GitHub PR URLs to gh-review, all inside the most recently active tmux
# session via iTerm2.
#
# Installation:
#   Symlink this file into your SwiftBar plugins directory, e.g.:
#     ln -s ~/scripts/dispatch.1d.sh \
#       ~/Library/Application\ Support/SwiftBar/Plugins/dispatch.1d.sh
#
#   Or open SwiftBar → Preferences to find/change your plugins folder.

# <swiftbar.hideAbout>true</swiftbar.hideAbout>
# <swiftbar.hideQuit>true</swiftbar.hideQuit>
# <swiftbar.hideRunInTerminal>true</swiftbar.hideRunInTerminal>
# <swiftbar.hideLastUpdated>true</swiftbar.hideLastUpdated>
# <swiftbar.refreshOnOpen>true</swiftbar.refreshOnOpen>

echo "⚡"
echo "---"
echo "Dispatch current Chrome tab | bash=${HOME}/scripts/dispatch-from-chrome terminal=false"
