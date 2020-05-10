copy () {
	src="$1"
	dest="$2"
	if [ -f "$src" ]; then
		cp --interactive --backup=numbered "$src" "$dest"
	elif [ -d "$src" ]; then
		src="$src/."
		if [ -e "$dest" ]; then
			echo "\n$dest exists."
			read -n 3 -p "Enter 1 to replace all, 2 for update, 3 for interactive update or anything else to skip: " user_response
			if [ "$user_response" == "1" ]; then
				cp -Rf "$src" "$dest"
			elif [ "$user_response" == "2" ]; then
				cp -R --update "$src" "$dest"
			elif [ "$user_response" == "3" ]; then
				cp -R --update --interactive "$src" "$dest"
			fi
		else
			mkdir -p "$dest"
			cp -R "$src" "$dest"
		fi
	fi
}
