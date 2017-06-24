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
# Safely moves installation directory to /usr/lib/mpi/$PN-PVR. Documentation is stored in the usual location.
mpi-providers_safe_mv() {

	## MOVE EVERYTHING BUT DOCS TO /usr/lib/mpi/${PN}-${PVR}
	## MOVE REMAINING CONTENTS FROM /etc/* TO /etc/${PN}-${PVR}

	local mpi_root="${ED}/usr/$(get_libdir)/mpi/${PN}-${PVR}"
	
	# move to temp directory
	mv "${ED}/usr/share/doc" "${T}/DOCS" || die "mv failed"
	mv "${ED}" "${T}/install" || die "mv failed"
	mkdir -p "${mpi_root}"
	# move from temp to final destination
	mv "${T}/install" "${mpi_root}" || die "mv failed"

	mkdir -p "${ED}/usr/share/doc"
	mv "${T}/DOCS" "${ED}/usr/share/doc" ||die "mv failed"

	local i
	for i in ${D}/etc/*; do
    	[ "${i}" == "${D}/etc/${PN}-${PVR}" ] && continue
    	mv ${i} ${D}/etc/${PN}-${PVR} || die
	done
}

# @ECLASS-FUNCTION: mpi-providers_sysconfdir
# @DESCRIPTION:
# Sets --syconfdir econf flag to a directory in /etc unique to that particular MPI build
mpi-providers_sysconfdir() {
    echo "${EPREFIX}/etc/${PN}-${PVR}"
}
