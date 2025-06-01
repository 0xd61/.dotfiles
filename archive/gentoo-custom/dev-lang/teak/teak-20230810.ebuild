# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A small scripting language to replace Unix shell scripts."

HOMEPAGE="https://github.com/nakst/teak"

PATCHES=(
	"${FILESDIR}"/commit-version.patch
)

SRC_REV="b258ee8df6fce699612797804f9acb1f28da5bf9"
SRC_URI="https://github.com/nakst/${PN}/archive/${SRC_REV}.tar.gz"

S="${WORKDIR}/teak-${SRC_REV}"

SLOT="0"

LICENSE="MIT"

KEYWORDS="amd64 ~x86 ~arm"

IUSE="X"

src_configure() {
	if ! use X; then
		rm -rf ${S}/modules/luigi
	fi
}

src_compile() {
	gcc -o teak teak.c -pthread -ldl
	./teak build.teak || die "Compilation failed!"
}

src_install() {
	dobin teak
	dodir /usr/share/teak
	exeinto /usr/share/teak
	doexe *.so

	dodoc -r README.md help examples
}
