# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-providers.eclass
# @MAINTAINER: 
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Functions for providing varied mpi builds.

case ${EAPI:-0} in
  6) ;;
  5) ;;
  *) die "mpi-providers.eclass does not support EAPI ${EAPI}"
esac

SLOT="${PVR}"

# @ECLASS-FUNCTION: mpi-providers_safe_mv
# @DESCRIPTION: 
# $mpi-providers_save_mv < installation directory (usually EPREFIX)>
mpi-providers_safe_mv() {

	## MOVE EVERYTHING BUT DOCS TO /usr/lib/mpi/${PN}-${PVR}
	## MOVE REMAINING CONTENTS FROM /etc/* TO /etc/${PN}-${PVR}

	local TMP="${T}"/"${PN}"

	# move anything remaining in /etc to /etc/${PN}-${PVR}
	mkdir -p "${TMP}"/etc
	mkdir -p "${ED}"/etc/"${PN}"-"${PVR}"
	rsync --remove-source-files -a "${ED}"/etc/* \
		"${TMP}"/etc/. || die "rsync failed"
	rsync --remove-source-files -a "${TMP}"/etc/* \
		"${ED}"/etc/"${PN}"-"${PVR}" || die "rsync failed"

	# move /usr/share/doc to temporary docs directory
	mkdir -p "${T}"/"${PN}"/DOCS
	local DOCS="${ED}"/usr/share/doc
	rsync --remove-source-files -a "${DOCS}"/* \
		"${TMP}"/DOCS/. || die "rsync failed"
	rsync --remove-source-files -a "${ED}"/* \
		"${TMP}"/. || die "rsync failed"
	
	# move docs from tmp, everything else to /usr/lib/mpi/${PN}-${PVR}
	mkdir -p "${ED}"/usr/$(get_libdir)/mpi/"${PN}"-"${PVR}"
	local MPI_DIR="${ED}"/usr/$(get_libdir)/mpi/"${PN}"-"${PVR}"
	mkdir -p "${DOCS}"
	rsync --remove-source-files -a "${TMP}"/DOCS/* \
		"${DOCS}"/. || die "rsync failed"
	rsync --remove-source-files -a "${TMP}"/* \
		"${MPI_DIR}"/. || die "rsync failed"

	# clean up
	rm -rf "${TMP}"
}

# @ECLASS-FUNCTION: mpi-providers_sysconfdir
# @DESCRIPTION:
# Sets --syconfdir econf flag to a directory in /etc unique to that particular MPI build
mpi-providers_sysconfdir() {
    echo "${EPREFIX}"/etc/"${PN}"-"${PVR}"
}
