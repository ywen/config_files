function! ToggleSymbolString()
  ruby << EOF
  str = case str = VIM::evaluate("expand(\"<cWORD>\")")
    when /\A["'](\w+)["']\z/ then ":" + $1
    when /\A:(\w+)\z/ then '"' + $1 + '"'
    else str
  end

  VIM::command("normal diW")
  VIM::command("normal i#{str}")
EOF
endfunction

map <D-)> <ESC>:call ToggleSymbolString()<CR>
