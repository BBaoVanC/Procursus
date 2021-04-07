#!/usr/bin/env bash

ask() {
	[ -z ${1+x} ] && exit 1
	if [ -z ${2+x} ]; then
		read -p "${1}: " rc
	else
		rc=$2
	fi
	echo "$rc"
}

checkpkg() {
	if [ -f $1.mk ]; then
		echo "$1.mk already exists."
		exit 1
	elif grep -R "^$pkg:" *.mk &> /dev/null; then
		echo "$1 already exists."
		exit 1
	fi
}

checkbuild() {
	if [ ! -f build_misc/templates/$1.mk ]; then
		echo "$1 is not a valid buildsystem"
		exit 1
	fi
}

downloadlink() {
	if echo "${1}" | rev | cut -d'/' -f1 | rev | ${SED} 's/\.tar.*//g' | ${SED} "s/${2}//g" | grep "${3}" &>/dev/null; then
		echo -e "\twget -q -nc -P\$(BUILD_SOURCE) $(${SED} "s/${2}/\$(${4}_VERSION)/g" <<< "$1")"
	else
		echo -e "\t-[ ! -f "$\(BUILD_SOURCE\)/${3}-$\(${4}_VERSION\).tar.$(rev <<< "$download" | cut -d'.' -f1 | rev)" ] \&\& \\
\t\twget -q -nc -O\$(BUILD_SOURCE)/${3}-\$(${4}_VERSION).tar.$(rev <<< "$download" | cut -d'.' -f1 | rev) \\
\t\t\t$(${SED} "s/${2}/\$(${4}_VERSION)/g" <<< "$1")"
	fi
}

main() {
	pkg="$(ask "Package Name" $1)"
	checkpkg "$pkg"
	formatpkg="$(${SED} -e 's|-|_|g' -e "s|\(.\)|\u\1|g" <<< "${pkg}")"
	build="$(ask "Build System" $2)"
	checkbuild "$build"
	ver="$(ask "Package Version" $3)"
	download="$(ask "Download Link" $4)"
	${SED} -e "s/@pkg@/${pkg}/g" \
		-e "s/@PKG@/${formatpkg}/g" \
		-e "s/@PKG_VERSION@/${ver}/g" \
		-e "s|@download@|$(downloadlink "$download" "$ver" "$pkg" "$formatpkg")|g" \
		-e "s|@compression@|$(rev <<< "$download" | cut -d'.' -f1 | rev)|g" \
		build_misc/templates/${build}.mk > ${pkg}.mk
}

if which gsed &>/dev/null; then
	SED=gsed
else
	SED=sed
fi

main $@