# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-select.eclass
# @MAINTAINER:
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Allow mpi software to select mpi implementation of choice.

case ${EAPI:-0} in
  6) ;;
  5) ;;
  *) die "mpi-select.eclass does not support EAPI ${EAPI}"
esac

# @ECLASS-VARIABLE: IMPLEMENTATION_LIST
# @INTERNAL
# @DESCRIPTION:
# List of used MPI implementation
IMPLEMENTATION_LIST="mpich mpich2 openmpi openib-mvapich2"

# @ECLASS-FUNCTION: mpi-select_implementation_install
# @DESCRIPTION:
# Install MPI software with arbitrary implementations
mpi-select_implementation_install (){
    for implementation in "$@"
    do
        if [[ "${IMPLEMENTATION_LIST}" == *"${implementation}"* ]]; then
            # go through src_[phase]
        else
            die "invalid implementation"
        fi
    done
}
