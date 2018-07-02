# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit cmake-utils

DESCRIPTION="Set of tools that let you decrypt, extract, and repack Vita CMA backup images"
HOMEPAGE="https://github.com/yifanlu/psvimgtools"
SRC_URI="https://github.com/yifanlu/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="MIT"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

src_configure() {
	cmake-utils_src_configure
}

src_compile() {
    cmake-utils_src_compile
}
