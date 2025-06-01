# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="A GDB frontend for Linux."

HOMEPAGE="https://github.com/nakst/gf"

SRC_REV="4190211d63c1e5378a9e841d22fa2b96a1099e68"
SRC_URI="https://github.com/nakst/${PN}/archive/${SRC_REV}.tar.gz"

S="${WORKDIR}/gf-${SRC_REV}"

LICENSE="MIT"

IUSE="truetype"

KEYWORDS="amd64 ~x86 ~arm"

RDEPEND="sys-devel/gdb
		 truetype? ( media-libs/freetype )"

DEPEND="${RDEPEND}"

SLOT="0"

src_configure() {
	echo "nothing to configure"
}

src_compile() {
	./build.sh || die "Compilation failed!"
}

src_install() {
	dobin gf2
	dodoc README.md
}
