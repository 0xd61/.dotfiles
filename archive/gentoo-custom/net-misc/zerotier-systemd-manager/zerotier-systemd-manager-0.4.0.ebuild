# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Manages systemd per-interface DNS resolution for zeronsd."

HOMEPAGE="https://github.com/zerotier/zerotier-systemd-manager"

SRC_URI=" \
	https://github.com/zerotier/${PN}/archive/refs/tags/v${PV}.tar.gz \
	https://cdn.dgl.com.py/gentoo/pkg-deps/${P}-vendor.tar.xz \
"

S="${WORKDIR}/${P}"

LICENSE="BSD"

KEYWORDS="amd64 ~x86 ~arm"

PATCHES=(
	"${FILESDIR}/${PV}-zerotier-service-name.patch"
)

inherit go-module systemd

BDEPEND=">=dev-lang/go-1.16"
RDEPEND="sys-apps/systemd"

SLOT="0"

src_configure() {
	echo "nothing to configure"
}

src_compile() {
	ego build
}

src_install() {
	dobin zerotier-systemd-manager
	systemd_dounit contrib/${PN}.{service,timer}
	dodoc README.md
	default
}

