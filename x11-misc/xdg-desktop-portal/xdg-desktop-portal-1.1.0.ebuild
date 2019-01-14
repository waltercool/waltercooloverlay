# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit systemd autotools

DESCRIPTION="Desktop integration portal"
HOMEPAGE="https://flatpak.org/ https://github.com/flatpak/xdg-desktop-portal"
SRC_URI="https://github.com/flatpak/${PN}/releases/download/${PV}/${P}.tar.xz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE="doc geoclue"

RDEPEND="
	dev-libs/glib:2[dbus]
	sys-fs/fuse
"
DEPEND="${RDEPEND}"
BDEPEND="
	dev-util/gdbus-codegen
	sys-devel/gettext
	virtual/pkgconfig
	geoclue? ( app-misc/geoclue:2.0 )
	doc? (
		app-text/xmlto
		app-text/docbook-xml-dtd:4.3
	)
"

PATCHES=(
	"${FILESDIR}/${P}-removeflatpack.patch"
)

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	local myeconfargs=(
		--disable-pipewire
		$(use_enable doc docbook-docs)
		$(use_enable geoclue)
		--with-systemduserunitdir="$(systemd_get_userunitdir)"
	)
	econf "${myeconfargs[@]}"
}

