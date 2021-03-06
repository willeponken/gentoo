# Copyright 1999-2018 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

inherit autotools

DESCRIPTION="A lightweight and flexible command-line JSON processor"
HOMEPAGE="https://stedolan.github.com/jq/"
SRC_URI="https://github.com/stedolan/jq/releases/download/${P}/${P}.tar.gz"

LICENSE="MIT CC-BY-3.0"
SLOT="0"
KEYWORDS="~alpha ~amd64 ~arm ~ia64 ~ppc ~ppc64 ~x86 ~amd64-linux ~x64-macos"
IUSE="oniguruma static-libs"

DEPEND="
	>=sys-devel/bison-3.0
	sys-devel/flex
	oniguruma? ( dev-libs/oniguruma:=[static-libs?] )
"
RDEPEND="
	!static-libs? (
		oniguruma? ( dev-libs/oniguruma[static-libs?] )
	)
"

src_prepare() {
	local PATCHES=(
		"${FILESDIR}"/jq-1.6-never-bundle-oniguruma.patch
		"${FILESDIR}"/jq-1.6-runpath.patch
		"${FILESDIR}"/jq-1.6-segfault-fix.patch
	)
	use oniguruma || { sed -i 's:tests/onigtest::' Makefile.am || die; }
	sed -i '/^dist_doc_DATA/d' Makefile.am || die
	sed -i -r "s:(m4_define\(\[jq_version\],) .+\):\1 \[${PV}\]):" \
		configure.ac || die

	default
	eautoreconf
}

src_configure() {
	local econfargs=(
		# don't try to rebuild docs
		--disable-docs
		--disable-valgrind
		--disable-maintainer-mode
		--enable-rpathhack
		$(use_enable static-libs static)
		$(use_with oniguruma)
	)
	econf "${econfargs[@]}"
}

src_install() {
	local DOCS=( AUTHORS README.md )
	default

	use static-libs || { find "${D}" -name '*.la' -delete || die; }
}
