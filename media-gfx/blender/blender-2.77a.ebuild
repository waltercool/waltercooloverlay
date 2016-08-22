# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI=6
PYTHON_COMPAT=( python3_5 )

inherit fdo-mime gnome2-utils cmake-utils python-single-r1 \
	flag-o-matic toolchain-funcs pax-utils check-reqs versionator

DESCRIPTION="3D Creation/Animation/Publishing System"
HOMEPAGE="http://www.blender.org"

SRC_URI="http://download.blender.org/source/${P}.tar.gz"

# Blender can have letters in the version string,
# so strip of the letter if it exists.
MY_PV="$(get_version_component_range 1-2)"

SLOT="0"
LICENSE="|| ( GPL-2 BL )"
KEYWORDS="~amd64 ~x86"
IUSE="+boost +bullet +dds +elbeem +game-engine +openexr collada colorio \
	cuda cycles debug doc ffmpeg fftw headless jack jemalloc jpeg2k libav \
	llvm man ndof nls openal opencl openimageio openmp opensubdiv openvdb \
	openvdb-compression osl player sdl sndfile test tiff valgrind \
	cpu_flags_x86_sse cpu_flags_x86_sse2"

# CUDA and nVidia performance is rubbish with Blender
# If you have nVidia, use CUDA.
REQUIRED_USE="${PYTHON_REQUIRED_USE}
	player? ( game-engine !headless )
	cuda? ( cycles !opencl )
	cycles? ( boost openexr tiff openimageio )
	colorio? ( boost )
	openvdb? ( boost )
	opensubdiv? ( cuda )
	nls? ( boost )
	openal? ( boost )
	opencl? ( cycles )
	osl? ( cycles llvm )
	game-engine? ( boost )
	?? ( ffmpeg libav )"

# Since not using OpenCL with nVidia, depend on ATI binary
# blobs as Cycles with OpenCL does not work with any open
# source drivers.
OPTIONAL_DEPENDS="
	boost? ( >=dev-libs/boost-1.60[nls?,threads(+)] )
	collada? ( >=media-libs/opencollada-1.6.18 )
	colorio? ( >=media-libs/opencolorio-1.0.9-r2 )
	cuda? ( dev-util/nvidia-cuda-toolkit )
	ffmpeg? ( media-video/ffmpeg:0=[x264,mp3,encode,theora,jpeg2k?] )
	libav? ( >=media-video/libav-11.3:0=[x264,mp3,encode,theora,jpeg2k?] )
	fftw? ( sci-libs/fftw:3.0 )
	!headless? (
		x11-libs/libX11
		x11-libs/libXi
		x11-libs/libXxf86vm
	)
	jack? ( media-sound/jack-audio-connection-kit )
	jemalloc? ( dev-libs/jemalloc )
	jpeg2k? ( media-libs/openjpeg:0 )
	llvm? ( sys-devel/llvm )
	ndof? (
		app-misc/spacenavd
		dev-libs/libspnav
	)
	nls? ( virtual/libiconv )
	openal? ( media-libs/openal )
	openimageio? ( >=media-libs/openimageio-1.6.9 )
	openexr? (
		media-libs/ilmbase
		media-libs/openexr
	)
	opensubdiv? ( media-libs/opensubdiv[cuda=,opencl=] )
	openvdb? (
		media-gfx/openvdb[${PYTHON_USEDEP},openvdb-compression=]
		dev-cpp/tbb
	)
	openvdb-compression? ( >=dev-libs/c-blosc-1.5.2 )
	osl? ( media-libs/osl )
	sdl? ( media-libs/libsdl2[sound,joystick] )
	sndfile? ( media-libs/libsndfile )
	tiff? ( media-libs/tiff:0 )
	valgrind? ( dev-util/valgrind )
"

RDEPEND="${PYTHON_DEPS}
	dev-libs/lzo:2
	>=dev-python/numpy-1.10.1[${PYTHON_USEDEP}]
	dev-python/requests[${PYTHON_USEDEP}]
	media-libs/freetype
	media-libs/glew
	media-libs/libpng:0
	media-libs/libsamplerate
	sci-libs/ldl
	sys-libs/zlib
	virtual/glu
	virtual/jpeg:0
	virtual/libintl
	virtual/opengl
	${OPTIONAL_DEPENDS}
"

DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.2.8:3
	doc? (
		app-doc/doxygen[-nodot(-),dot(+),latex]
		dev-python/sphinx[latex]
	)
	nls? ( sys-devel/gettext )
"

PATCHES=(
	"${FILESDIR}"/${PN}-2.68-doxyfile.patch
	"${FILESDIR}"/${PN}-2.68-fix-install-rules.patch
	"${FILESDIR}"/${PN}-2.77-sse2.patch
	"${FILESDIR}"/${PN}-2.77-C++11-build-fix.patch
	"${FILESDIR}"/${PN}-2.77-disable-gpu.patch
)

pkg_pretend() {
	if use openmp && ! tc-has-openmp; then
		eerror "You are using gcc built without 'openmp' USE."
		eerror "Switch CXX to an OpenMP capable compiler."
		die "Need openmp"
	fi

	if use doc; then
		CHECKREQS_DISK_BUILD="4G" check-reqs_pkg_pretend
	fi
}

pkg_setup() {
	python-single-r1_pkg_setup
}

src_prepare() {
	default

	# we don't want static glew, but it's scattered across
	# thousand files
	# !!!CHECK THIS SED ON EVERY VERSION BUMP!!!
	sed -i \
		-e '/-DGLEW_STATIC/d' \
		$(find . -type f -name "CMakeLists.txt") || die
}

src_configure() {
	# FIX: forcing '-funsigned-char' fixes an anti-aliasing issue with menu
	# shadows, see bug #276338 for reference
	append-flags -funsigned-char
	append-lfs-flags
	# Makefile says not to use --as-needed as it breaks on certain distros.
	# On Gentoo it causes bug #533514 with certain versions of GLibC
	append-ldflags $(no-as-needed)

	# TODO: Turn CPP11 on when Boost switches to CPP11
	local mycmakeargs=(
		-DCMAKE_INSTALL_PREFIX=/usr
		-DPYTHON_VERSION="${EPYTHON/python/}"
		-DPYTHON_LIBRARY="$(python_get_library_path)"
		-DPYTHON_INCLUDE_DIR="$(python_get_includedir)"
		-DWITH_INSTALL_PORTABLE=OFF
		-DWITH_PYTHON_INSTALL=OFF
		-DWITH_PYTHON_INSTALL_NUMPY=OFF
		-DWITH_STATIC_LIBS=OFF
		-DWITH_SYSTEM_GLEW=ON
		-DWITH_SYSTEM_OPENJPEG=ON
		-DWITH_SYSTEM_EIGEN3=ON
		-DWITH_SYSTEM_LZO=ON
		-DWITH_BOOST=$(usex boost ON OFF )
		-DWITH_BULLET=$(usex bullet ON OFF )
		-DWITH_CODEC_FFMPEG=$(usex ffmpeg ON OFF )
		-DWITH_CODEC_SNDFILE=$(usex sndfile ON OFF )
		-DWITH_CPP11=OFF
		-DWITH_CUDA=$(usex cuda ON OFF )
		-DWITH_CYCLES=$(usex cycles ON OFF )
		-DWITH_CYCLES_OSL=$(usex osl ON OFF )
		-DWITH_FFTW3=$(usex fftw ON OFF )
		-DWITH_GAMEENGINE=$(usex game-engine ON OFF )
		-DWITH_HEADLESS=$(usex headless ON OFF )
		-DWITH_X11=$(usex headless OFF ON )
		-DWITH_IMAGE_DDS=$(usex dds ON OFF )
		-DWITH_IMAGE_OPENEXR=$(usex openexr ON OFF )
		-DWITH_IMAGE_OPENJPEG=$(usex jpeg2k ON OFF )
		-DWITH_IMAGE_TIFF=$(usex tiff ON OFF )
		-DWITH_INPUT_NDOF=$(usex ndof ON OFF )
		-DWITH_INTERNATIONAL=$(usex nls ON OFF )
		-DWITH_JACK=$(usex jack ON OFF )
		-DWITH_MOD_FLUID=$(usex elbeem ON OFF )
		-DWITH_MOD_OCEANSIM=$(usex fftw ON OFF )
		-DWITH_OPENAL=$(usex openal ON OFF )
		-DWITH_OPENCL=$(usex opencl ON OFF )
		-DWITH_OPENCOLORIO=$(usex colorio ON OFF )
		-DWITH_OPENCOLLADA=$(usex collada ON OFF )
		-DWITH_OPENIMAGEIO=$(usex openimageio ON OFF )
		-DWITH_OPENMP=$(usex openmp ON OFF )
		-DWITH_OPENSUBDIV=$(usex opensubdiv ON OFF )
		-DWITH_OPENVDB=$(usex openvdb ON OFF )
		-DWITH_OPENVDB_BLOSC=$(usex openvdb-compression ON OFF )
		-DWITH_PLAYER=$(usex player ON OFF )
		-DWITH_SDL=$(usex sdl ON OFF )
		-DWITH_RAYOPTIMIZATION=$(usex cpu_flags_x86_sse ON OFF )
		-DWITH_CPU_SSE=$(usex cpu_flags_x86_sse ON OFF )
		-DWITH_SSE2=$(usex cpu_flags_x86_sse2 ON OFF )
		-DWITH_CXX_GUARDEDALLOC=$(usex debug ON OFF )
		-DWITH_ASSERT_ABORT=$(usex debug ON OFF )
		-DWITH_GTESTS=$(usex test ON OFF )
		-DWITH_DOC_MANPAGE=$(usex man ON OFF)
		-DWITH_MEM_JEMALLOC=$(usex jemalloc ON OFF )
		-DWITH_MEM_VALGRIND=$(usex valgrind ON OFF )
	)
	cmake-utils_src_configure
}

src_compile() {
	cmake-utils_src_compile

	if use doc; then
		# Workaround for binary drivers.
		cards=( /dev/ati/card* /dev/nvidia* )
		for card in "${cards[@]}"; do addpredict "${card}"; done

		einfo "Generating Blender C/C++ API docs ..."
		cd "${CMAKE_USE_DIR}"/doc/doxygen || die
		doxygen -u Doxyfile || die
		doxygen || die "doxygen failed to build API docs."

		cd "${CMAKE_USE_DIR}" || die
		einfo "Generating (BPY) Blender Python API docs ..."
		"${BUILD_DIR}"/bin/blender --background --python doc/python_api/sphinx_doc_gen.py -noaudio || die "blender failed."

		cd "${CMAKE_USE_DIR}"/doc/python_api || die
		sphinx-build sphinx-in BPY_API || die "sphinx failed."
	fi
}

src_test() {
	if use test; then
		einfo "Running Blender Unit Tests ..."
		cd "${BUILD_DIR}"/bin/tests || die
		for f in *_test
		do
			./$f || die
		done
	fi
}

src_install() {
	local i

	# Pax mark blender for hardened support.
	pax-mark m "${CMAKE_BUILD_DIR}"/bin/blender

	if use doc; then
		docinto "html/API/python"
		dodoc -r "${CMAKE_USE_DIR}"/doc/python_api/BPY_API/*

		docinto "html/API/blender"
		dodoc -r "${CMAKE_USE_DIR}"/doc/doxygen/html/*
	fi

	# CMake will relink binary for no reason
	emake -C "${CMAKE_BUILD_DIR}" DESTDIR="${D}" install/fast

	# fix doc installdir
	docinto "html"
	dodoc "${CMAKE_USE_DIR}"/release/text/readme.html
	rm -r "${ED%/}"/usr/share/doc/blender || die

	python_fix_shebang "${ED%/}/usr/bin/blender-thumbnailer.py"
	python_optimize "${ED%/}/usr/share/blender/${MY_PV}/scripts"
}

pkg_preinst() {
	gnome2_icon_savelist
}

pkg_postinst() {
	elog
	elog "Blender uses python integration. As such, may have some"
	elog "inherit risks with running unknown python scripts."
	elog
	elog "It is recommended to change your blender temp directory"
	elog "from /tmp to /home/user/tmp or another tmp file under your"
	elog "home directory. This can be done by starting blender, then"
	elog "dragging the main menu down do display all paths."
	elog
	ewarn
	ewarn "This ebuild does not unbundle the massive amount of 3rd party"
	ewarn "libraries which are shipped with blender. Note that"
	ewarn "these have caused security issues in the past."
	ewarn "If you are concerned about security, file a bug upstream:"
	ewarn "  https://developer.blender.org/"
	ewarn
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update
}

pkg_postrm() {
	gnome2_icon_cache_update
	fdo-mime_desktop_database_update

	ewarn ""
	ewarn "You may want to remove the following directory."
	ewarn "~/.config/${PN}/${MY_PV}/cache/"
	ewarn "It may contain extra render kernels not tracked by portage"
	ewarn ""
}
