#!/usr/bin/env bash

shopt -s extglob

usage() {
	local prog=${0##*/}
	cat <<-EOF
	Usage: $prog [ on | off ]

	Examples:
	  # Set output(s)
	  $prog off # disables nvidia card
	  $prog on # enables nvidia card
	  $prog # shows current setting
	EOF
}

CALL="/proc/acpi/bbswitch"

case "$1" in
	off) sudo tee $CALL <<< OFF;;
	on) sudo tee $CALL <<< ON;;

	''|get) cat $CALL;;

	-h|help) usage;;
	*) usage >&2; exit 1;;
esac

