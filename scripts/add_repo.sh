#!/bin/sh

set -eu

gen_is_my() {
	local name="$1"
	shift

	eval "is_my_$name() {	\
case "\$1" in	\
$*) return 0 ;;	\
*)  return 1 ;;	\
esac		\
}"
}

is_mine() {
	local name="$1" x= pat=

	for x; do
		pat="${pat:+$pat|}$x/*"
	done

	gen_is_my "$name" "$pat"
}

is_mine github \
	"$USER" \
	sancus-project \
	justprintit \
	krong-project \
	goshop-project \
	darvaza-proxy \
	;

is_mine gitlab \
	"mnemoc" \
	gootools \
	licensly \
	;

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
	x=$(echo "$x" | sed -e 's,^\(ssh\|http\|https\)://\([^/@]\+@\)\?,,')
	add_repo "$x"
done
