#!/bin/sh

set -eu

MY_GITHUB_PRJ=
MY_GITLAB_PRJ=

for x in \
	"$USER" \
	sancus-project \
	justprintit \
	krong-project \
	goshop-project \
	darvaza-proxy \
	; do
MY_GITHUB_PRJ="${MY_GITHUB_PRJ:+$MY_GITHUB_PRJ|}$x/*"
done

for x in \
	"mnemoc" \
	gootools \
	licensly \
	; do
MY_GITLAB_PRJ="${MY_GITLAB_PRJ:+$MY_GITLAB_PRJ|}$x/*"
done

is_my_github() {
	case "$1" in
	$MY_GITHUB_PRJ)
		return 1
		;;
	*)
		return 0
		;;
	esac
}

is_my_gitlab() {
	case "$1" in
	$MY_GITLAB_PRJ)
		return 1
		;;
	*)
		return 0
		;;
	esac
}

add_repo() {
	local repo="$1" path="src/$1" url=
	local dom=${repo%%/*}
	local prj=${repo#$dom/}
	shift

	# go-import translations
	case "$dom" in
	go.sancus.dev)
		dom="github.com"
		case "$prj" in
		file2go)
			;;
		*)
			prj="go-$prj"
			;;
		esac
		prj="sancus-project/$prj"
		repo="$dom/$prj"
		;;
	goshop.dev)
		dom="github.com"
		prj="goshop-project/$prj"
		repo="$dom/$prj"
		;;
	esac

	url="https://$repo"

	case "$dom" in
	github.com)
		if is_my_github "$prj"; then
			url="ssh://git@$repo.git"
		fi
		;;
	gitlab.com)
		if is_my_gitlab "$prj"; then
			url="ssh://git@$repo.git"
		fi
		;;
	esac

	git submodule add "$@" "$url" "$path"
}

for x; do
	add_repo "$x"
done
