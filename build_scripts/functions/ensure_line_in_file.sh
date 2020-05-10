ensure_line_in_file () {
	grep -qF "$1" "$2" || ( echo "$1" >> "$2" && return 10 )
}
