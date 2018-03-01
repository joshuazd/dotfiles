if exists('g:loaded_sneak_plugin') && g:loaded_sneak_plugin == 1

    " 1-character enhanced 'f'
    nmap f <Plug>Sneak_f
    nmap F <Plug>Sneak_F
    " visual-mode
    xmap f <Plug>Sneak_f
    xmap F <Plug>Sneak_F
    " operator-pending-mode
    omap f <Plug>Sneak_f
    omap F <Plug>Sneak_F

    " 1-character enhanced 't'
    nmap t <Plug>Sneak_t
    nmap T <Plug>Sneak_T
    " visual-mode
    xmap t <Plug>Sneak_t
    xmap T <Plug>Sneak_T
    " operator-pending-mode
    omap t <Plug>Sneak_t
    omap T <Plug>Sneak_T

endif


