function! clip#osc52() abort
  let buffer=system('base64 -w0', @0)
  let buffer=substitute(buffer, "\n$", '', '')
  let buffer='\e]52;c;'.buffer.'\x07'
  silent exe '!echo -ne '.shellescape(buffer).' > '.shellescape('/dev/tty')
endfunction
