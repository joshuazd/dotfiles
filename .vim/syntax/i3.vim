" Vim syntax file
" Language: i3 config file
" Maintainer: Mohamed Boughaba <mohamed dot bgb at gmail dot com>
" Version: 0.3
" Last Change: 2017-10-27 23:59

" References:
" http://i3wm.org/docs/userguide.html#configuring
" http://vimdoc.sourceforge.net/htmldoc/syntax.html
"
"
" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if v:version < 600
  syn clear
elsei exists('b:current_syntax')
  fini
en

" Error
" syn match i3Error /.*/

" Todo
syn keyword i3Todo TODO FIXME XXX contained

" Comment
" Comments are started with a # and can only be used at the beginning of a line
syn match i3Comment /^\s*#.*$/ contains=Todo

" Font
" A FreeType font description is composed by:
" a font family, a style, a weight, a variant, a stretch and a size.
syn match i3FontSeparator /,/ contained
syn match i3FontSeparator /:/ contained
syn keyword i3FontKeyword font contained
syn match i3FontNamespace /\w\+:/ contained contains=i3FontSeparator
syn match i3FontContent /-\?\w\+\(-\+\|\s\+\|,\)/ contained contains=i3FontNamespace,i3FontSeparator,i3FontKeyword
syn match i3FontSize /\s\=\d\+\(px\)\?\s\?$/ contained
syn match i3Font /^\s*font\s\+.*$/ contains=i3FontContent,i3FontSeparator,i3FontSize,i3FontNamespace
"syn match i3Font /^\s*font\s\+.*\(\\\_.*\)\?$/ contains=i3FontContent,i3FontSeparator,i3FontSize,i3FontNamespace
"syn match i3Font /^\s*font\s\+.*\(\\\_.*\)\?[^\\]\+$/ contains=i3FontContent,i3FontSeparator,i3FontSize,i3FontNamespace
"syn match i3Font /^\s*font\s\+\(\(.*\\\_.*\)\|\(.*[^\\]\+$\)\)/ contains=i3FontContent,i3FontSeparator,i3FontSize,i3FontNamespace

" variables
syn match i3String /\(['"]\)\(.\{-}\)\1/ contained
syn match i3Color /#\w\{6}/ contained
syn match i3VariableModifier /+/ contained
syn match i3VariableAndModifier /+\w\+/ contained contains=i3VariableModifier
syn match i3Variable /\$\w\+\(\(-\w\+\)\+\)\?\(\s\|+\)\?/ contains=i3VariableModifier,i3VariableAndModifier
syn keyword i3InitializeKeyword set contained
syn match i3Initialize /^\s*set\s\+.*$/ contains=i3Variable,i3InitializeKeyword,i3Color,i3String

" Keyboard bindings
syn keyword i3Action toggle fullscreen restart key import kill shrink grow contained
syn keyword i3Action focus move split layout resize restore reload mute unmute exit contained
syn match i3Modifier /\w\++\w\+\(\(+\w\+\)\+\)\?/ contained contains=VariableModifier
syn match i3Number /\d\+/ contained
syn keyword i3BindKeyword bindsym bindcode exec contained
syn match i3BindArgument /--\w\+\(\(-\w\+\)\+\)\?\s/ contained
syn match i3Bind /^\s*\(bindsym\|bindcode\)\s\+.*$/ contains=i3Variable,i3BindKeyword,i3VariableAndModifier,i3BindArgument,i3Number,i3Modifier,i3Action,i3String

" Floating
syn keyword i3SizeSpecial x contained
syn match i3NegativeSize /-/ contained
syn match i3Size /-\?\d\+\s\?x\s\?-\?\d\+/ contained contains=i3SizeSpecial,i3Number,i3NegativeSize
syn match i3Floating /^\s*floating_modifier\s\+\$\w\+\d\?/ contains=i3Variable
syn match i3Floating /^\s*floating_\(maximum\|minimum\)_size\s\+-\?\d\+\s\?x\s\?-\?\d\+/ contains=i3Size

" Orientation
syn keyword i3OrientationKeyword vertical horizontal auto contained
syn match i3Orientation /^\s*default_orientation\s\+\(vertical\|horizontal\|auto\)\s\?$/ contains=i3OrientationKeyword

" Layout
syn keyword i3LayoutKeyword default stacking tabbed contained
syn match i3Layout /^\s*workspace_layout\s\+\(default\|stacking\|tabbed\)\s\?$/ contains=i3LayoutKeyword

" Border style
syn keyword i3BorderStyleKeyword none normal pixel contained
syn match i3BorderStyle /^\s*\(new_window\|new_float\)\s\+\(none\|\(normal\|pixel\)\(\s\+\d\+\)\?\)\s\?$/ contains=i3BorderStyleKeyword,i3number

" Hide borders and edges
syn keyword i3EdgeKeyword none vertical horizontal both contained
syn match i3Edge /^\s*hide_edge_borders\s\+\(none\|vertical\|horizontal\|both\)\s\?$/ contains=i3EdgeKeyword

" Arbitrary commands for specific windows (for_window)
syn keyword i3CommandKeyword for_window contained
syn region i3WindowStringSpecial start=+"+  skip=+\\"+  end=+"+ contained contains=i3String
syn region i3WindowCommandSpecial start="\[" end="\]" contained contains=i3WindowStringSpacial,i3String
syn match i3ArbitraryCommand /^\s*for_window\s\+.*$/ contains=i3WindowCommandSpecial,i3CommandKeyword,i3BorderStyleKeyword,i3LayoutKeyword,i3OrientationKeyword,i3Size,i3Number

" Gaps
syn keyword i3Gaps gaps nextgroup=i3GapsOption
syn match i3GapsOption +\s\+.*+ contains=i3Number,i3number

" Disable focus open opening
syn keyword i3NoFocusKeyword no_focus contained
syn match i3DisableFocus /^\s*no_focus\s\+.*$/ contains=i3WindowCommandSpecial,i3NoFocusKeyword

" Move client to specific workspace automatically
syn keyword i3AssignKeyword assign contained
syn match i3AssignSpecial /→/ contained
syn match i3Assign /^\s*assign\s\+.*$/ contains=i3AssignKeyword,i3WindowCommandSpecial,i3AssignSpecial

" X resources
syn keyword i3ResourceKeyword set_from_resource contained
syn match i3Resource /^\s*set_from_resource\s\+.*$/ contains=i3ResourceKeyword,i3WindowCommandSpecial,i3Color,i3Variable

" Auto start applications
syn keyword i3ExecKeyword exec exec_always contained
syn match i3NoStartupId /--no-startup-id/ contained " We are not using BindArgument as only no-startup-id is supported here
syn match i3Exec /^\s*exec\(_always\)\?\s\+.*$/ contains=i3ExecKeyword,i3NoStartupId,i3String

" Automatically putting workspaces on specific screens
syn keyword i3WorkspaceKeyword workspace contained
syn keyword i3Output output contained
syn match i3Workspace /^\s*workspace\s\+.*$/ contains=i3WorkspaceKeyword,i3Number,i3String,i3Output

" Changing colors
syn keyword i3ClientColorKeyword client focused focused_inactive unfocused urgent placeholder background contained
syn match i3ClientColor /^\s*client.\w\+\s\+.*$/ contains=i3ClientColorKeyword,i3Color,i3Variable

" Interprocess communication
syn match i3InterprocessKeyword /ipc-socket/ contained
syn match i3Interprocess /^\s*ipc-socket\s\+.*$/ contains=i3InterprocessKeyword

" Focus follows mouse
syn keyword i3MouseWarpingKeyword mouse_warping contained
syn keyword i3MouseWarpingType output none contained
syn match i3MouseWarping /^\s*mouse_warping\s\+\(output\|none\)\s\?$/ contains=i3MouseWarpingKeyword,i3MouseWarpingType

" Popups during fullscreen mode
syn keyword i3PopupOnFullscreenKeyword popup_during_fullscreen contained
syn keyword i3PopuponFullscreenType smart ignore leave_fullscreen contained
syn match i3PopupOnFullscreen /^\s*popup_during_fullscreen\s\+\w\+\s\?$/ contains=i3PopupOnFullscreenKeyword,i3PopupOnFullscreenType

" Focus wrapping
syn keyword i3FocusWrappingKeyword force_focus_wrapping contained
syn keyword i3FocusWrappingType yes no contained
syn match i3FocusWrapping /^\s*force_focus_wrapping\s\+\(yes\|no\)\s\?$/ contains=i3FocusWrappingType,i3FocusWrappingKeyword

" Forcing Xinerama
syn keyword i3ForceXineramaKeyword force_xinerama contained
syn match i3ForceXinerama /^\s*force_xinerama\s\+\(yes\|no\)\s\?$/ contains=i3FocusWrappingType,i3ForceXineramaKeyword

" Automatic back-and-forth when switching to the current workspace
syn keyword i3AutomaticSwitchKeyword workspace_auto_back_and_forth contained
syn match i3AutomaticSwitch /^\s*workspace_auto_back_and_forth\s\+\(yes\|no\)\s\?$/ contains=i3FocusWrappingType,i3AutomaticSwitchKeyword

" Delay urgency hint
syn keyword i3TimeUnit ms contained
syn keyword i3DelayUrgencyKeyword force_display_urgency_hint contained
syn match i3DelayUrgency /^\s*force_display_urgency_hint\s\+\d\+\s\+ms\s\?$/ contains=i3FocusWrappingType,i3DelayUrgencyKeyword,i3Number,i3TimeUnit

" Focus on window activation
syn keyword i3FocusOnActivationKeyword focus_on_window_activation contained
syn keyword i3FocusOnActivationType smart urgent focus none contained
syn match i3FocusOnActivation /^\s*focus_on_window_activation\s\+\(smart\|urgent\|focus\|none\)\s\?$/  contains=i3FocusOnActivationKeyword,i3FocusOnActivationType

" Automatic back-and-forth when switching to the current workspace
syn keyword i3DrawingMarksKeyword show_marks contained
syn match i3DrawingMarks /^\s*show_marks\s\+\(yes\|no\)\s\?$/ contains=i3FocusWrappingType,i3DrawingMarksKeyword

" Group mode/bar
syn keyword i3BlockKeyword mode bar colors i3bar_command status_command position exec mode hidden_state modifier id position output background statusline tray_output tray_padding separator separator_symbol workspace_buttons strip_workspace_numbers binding_mode_indicator focused_workspace active_workspace inactive_workspace urgent_workspace binding_mode contained
syn region i3Block start=+.*s\?{$+ end=+^}$+ contains=i3BlockKeyword,i3String,i3Bind,i3Comment,i3Font,i3FocusWrappingType,i3Color,i3Variable keepend

" Line continuation
" TODO: This is not the easiest thing to do. I am keeping it for another time.

" Define the highlighting.
hi! def link i3Error                    Error
hi! def link i3Todo                     Todo
hi! def link i3Comment                  Comment
hi! def link i3FontContent              Type
hi! def link i3FocusOnActivationType    Type
hi! def link i3PopupOnFullscreenType    Type
hi! def link i3OrientationKeyword       Type
hi! def link i3MouseWarpingType         Type
hi! def link i3LayoutKeyword            Type
hi! def link i3BorderStyleKeyword       Type
hi! def link i3EdgeKeyword              Type
hi! def link i3Action                   Type
hi! def link i3Command                  Type
hi! def link i3Output                   Type
hi! def link i3WindowCommandSpecial     Type
hi! def link i3FocusWrappingType        Type
hi! def link i3FontSize                 Constant
hi! def link i3Color                    Constant
hi! def link i3Number                   Constant
hi! def link i3VariableAndModifier      Constant
hi! def link i3TimeUnit                 Constant
hi! def link i3Modifier                 Constant
hi! def link i3String                   String
hi! def link i3NegativeSize             Constant
hi! def link i3FontSeparator            Special
hi! def link i3VariableModifier         Special
hi! def link i3SizeSpecial              Special
hi! def link i3WindowSpecial            Special
hi! def link i3AssignSpecial            Special
hi! def link i3FontNamespace            PreProc
hi! def link i3BindArgument             PreProc
hi! def link i3NoStartupId              PreProc
hi! def link i3Gaps                     Identifier
hi! def link i3FontKeyword              Identifier
hi! def link i3BindKeyword              Identifier
hi! def link i3Orientation              Identifier
hi! def link i3Layout                   Identifier
hi! def link i3BorderStyle              Identifier
hi! def link i3Edge                     Identifier
hi! def link i3Floating                 Identifier
hi! def link i3CommandKeyword           Identifier
hi! def link i3NoFocusKeyword           Identifier
hi! def link i3InitializeKeyword        Identifier
hi! def link i3AssignKeyword            Identifier
hi! def link i3ResourceKeyword          Identifier
hi! def link i3ExecKeyword              Identifier
hi! def link i3WorkspaceKeyword         Identifier
hi! def link i3ClientColorKeyword       Identifier
hi! def link i3InterprocessKeyword      Identifier
hi! def link i3MouseWarpingKeyword      Identifier
hi! def link i3PopupOnFullscreenKeyword Identifier
hi! def link i3FocusWrappingKeyword     Identifier
hi! def link i3ForceXineramaKeyword     Identifier
hi! def link i3AutomaticSwitchKeyword   Identifier
hi! def link i3DelayUrgencyKeyword      Identifier
hi! def link i3FocusOnActivationKeyword Identifier
hi! def link i3DrawingMarksKeyword      Identifier
hi! def link i3BlockKeyword             Identifier
hi! def link i3Variable                 Statement
hi! def link i3ArbitraryCommand         Statement

let b:current_syntax = 'i3'

