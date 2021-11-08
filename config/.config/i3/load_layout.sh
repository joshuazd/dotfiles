#!/bin/bash

i3-msg "workspace 1; append_layout ~/i3chrome.json"

(chromium-browser &)

i3-msg "workspace 2; append_layout ~/i3term.json"

(urxvt &)

i3-msg "workspace 1"

