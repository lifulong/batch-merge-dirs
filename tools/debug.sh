
function DEBUG() {
	if [ "$DEBUG" = "true" ]; then
		$@
	fi
}

function INFO() {
	if [ "$INFO" = "true" ]; then
		$@
	fi
}

function ERROR() {
	if [ "$ERROR" = "true" ]; then
		$@
	fi
}

