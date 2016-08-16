# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="5"

DESCRIPTION="The very latest -git version of the Linux kernel"
HOMEPAGE="https://www.kernel.org"
SRC_URI=""
SLOT="0"

KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86"
IUSE=""

K_EXTRAEINFO="This kernel is not supported by Gentoo due to its unstable and
experimental nature. If you have any issues, try a matching vanilla-sources
ebuild -- if the problem is not there, please contact the upstream kernel
developers at https://bugzilla.kernel.org and on the linux-kernel mailing list to
report the problem so it can be fixed in time for the next kernel release."

RDEPEND=""
DEPEND="${RDEPEND}
	>=sys-devel/patch-2.7.4"
