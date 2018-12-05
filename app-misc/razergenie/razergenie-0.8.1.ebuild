# Copyright 2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION=""
HOMEPAGE=""
SRC_URI="https://github.com/z3ntu/RazerGenie/archive/v${PV}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND="app-misc/openrazer
		dev-qt/qtgui:5
"
RDEPEND="${DEPEND}"
BDEPEND=""

src_unpack() {
	default
	S=${WORKDIR}/RazerGenie-${PV}
}

src_configure() {
	cmake-utils_src_configure
}

src_install() {
	cmake-utils_src_install
}
