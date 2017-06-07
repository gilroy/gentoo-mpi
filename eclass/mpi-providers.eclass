# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gentoo-mpi.eclass
# @MAINTAINER: 
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Functions for providing varied mpi builds.

case ${EAPI:-0} in
  6) ;;
  5) ;;
  *) die "gentoo-mpi.eclass does not support EAPI ${EAPI}"
esac

SLOT="${PVR}"

alias econf='econf --sysconfdir="${EPREFIX}"/etc/"${PN}"-"${PVR}"'

# @ECLASS-FUNCTION: mpi-providers_safe_mv
# @DESCRIPTION: 
# $mpi-providers_save_mv < installation directory (usually EPREFIX)>
mpi-providers_safe_mv() {

	# MOVE EVERYTHING BUT DOCS TO /usr/lib/${PN}-${PVR}
	# move docs to tmp folder
    mkdir -p /tmp/"${PVR}"/DOCS
	rsync --remove-source-files -a "${ED}"usr/share/doc/* \
		/tmp/"${PVR}"/DOCS/. || die
	rsync --remove-source-files -a "${ED}"* \
		/tmp/"${PVR}"/. || die

	# move docs from tmp, move everything else to /usr/lib/mpi/${PN}-${PVR}
	mkdir -p "${ED}"usr/lib/mpi/"${PN}"-"${PVR}"
	mkdir -p "${ED}"usr/share/doc || die
	rsync --remove-source-files -a /tmp/"${PVR}"/DOCS/* \
		"${ED}"/usr/share/doc/. || die
	rsync --remove-source-files -a /tmp/"${PVR}"/* \
		"${ED}"usr/lib/mpi/"${PN}"-"${PVR}"/. || die

	# clean up
	rm -rf /tmp/"${PVR}"
}
