def width: 70;

.[]
| (.title
   | gsub("\\s*\\[sc-[0-9]+\\]\\s*|^sc-[0-9]+:?\\s+"; " ")
   | ltrimstr(" ") | rtrimstr(" ")
   | if length > width then .[0:width - 1] + "…" else . end) as $t
| "\(.url)\t\(.number)\t\($t + (" " * (width - ($t | length))))\t\(.author.login)"
