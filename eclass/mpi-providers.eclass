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

# @ECLASS-VARIABLE: IMPLEMENTATION_LIST
# @INTERNAL
# @DESCRIPTION:
# Every MPI Implementation
IMPLEMENTATION_LIST="mpich mpich2 openmpi lam-mpi openlib-mvapich2 hpl"

SLOT="${PVR}"

export EPREFIX="${EPREFIX}/usr/lib/mpi/${PF}"