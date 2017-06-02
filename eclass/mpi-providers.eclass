# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: gentoo-mpi.eclass
# @MAINTAINER: 
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Functions for providing varied mpi builds.

case ${EAPI:-0} in
  6) ;;
  *) die "gentoo-mpi.eclass does not support EAPI ${EAPI}"
esac

SLOT="${PVR}"

# @ECLASS-FUNCTION: mpi-providers_safe_mv
# @USAGE: $mpi-providers_save_mv < installation directory (usually EPREFIX)>
mpi-providers_safe_mv() {
    DEST="$1/etc/"
    if [[ ! -d "$DEST" ]]; then
        mkdir "$DEST" || die
    fi

    mv "$1/*" "$DEST/$PN-$PVR/." || die
}
