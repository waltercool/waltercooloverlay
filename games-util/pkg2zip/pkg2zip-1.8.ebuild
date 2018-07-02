# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

DESCRIPTION="Utility that decrypts PlayStation Vita pkg file and creates zip package."
HOMEPAGE="https://github.com/mmozeiko/pkg2zip"
SRC_URI="https://github.com/mmozeiko/${PN}/archive/v${PV}.tar.gz"

LICENSE=""
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_install() {
	dobin "pkg2zip"
}
