# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PLOCALES="es ja fr"

PLOCALE_BACKUP=""

inherit l10n qmake-utils

DESCRIPTION="Cross-platform content manager assistant for the PS Vita"
HOMEPAGE="https://github.com/codestation/qcma"
SRC_URI="https://github.com/waltercool/${PN}/archive/v${PV}.tar.gz -> ${P}.tar.gz"

RESTRICT="mirror"

SLOT="0"
LICENSE="GPL-3"
KEYWORDS="*"
IUSE="+qt5
	kde unity"

REQUIRED_USE="kde? ( qt5 )
	unity? ( qt5 )"

RDEPEND="dev-qt/qtcore:5
	=games-util/libvitamtp-2.5.9
	sys-apps/dbus
	virtual/ffmpeg
	virtual/notification-daemon
	kde? ( kde-base/knotify )
	qt5? ( dev-qt/qtdbus:5
		dev-qt/qtgui:5 )
	unity? ( dev-libs/libappindicator )
	x11-libs/libnotify"

DEPEND="${RDEPEND}"

locale_info_cleanup() {
	sed -e "s;resources/translations/qcma_${1}.ts;;" \
		-i "${S}/${PN}.pro" || die
	sed -e "s;<file>resources/translations/qcma_${1}.qm</file>;;" \
		-i "${S}/common/translations.qrc" || die
}

src_prepare() {
	l10n_for_each_disabled_locale_do locale_info_cleanup

	use kde || sed -e "s;qcma_kdenotifier.pro;;" -i "${S}/${PN}.pro" || die
	use unity || sed -e "s;qcma_appindicator.pro;;" -i "${S}/${PN}.pro" || die

	sed -e "/^Path=/d" \
		-e "s;${PN}.png;${PN};" \
		-i "${S}/gui/resources/${PN}.desktop" || die

	if [[ $(l10n_get_locales) ]] ; then
		lrelease -silent "${PN}.pro" || die
	fi
}

src_configure() {
	eqmake5 qcma.pro
}

#src_compile() {
#	emake -j1 sub-qcma_cli-pro
#	use qt5 && emake -j1 sub-qcma_gui-pro
#}

src_install() {
	dobin "${S}/cli/${PN}_cli"

	if use qt5 ; then
		dobin "${S}/gui/${PN}"
		doicon "${S}/gui/resources/images/${PN}.png"
		domenu "${S}/gui/resources/${PN}.desktop"
	fi
}
