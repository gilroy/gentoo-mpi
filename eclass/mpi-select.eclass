# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-select.eclass
# @MAINTAINER:
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Allow mpi software to select mpi implementation of choice.

EXPORT_FUNCTIONS src_configure src_compile src_test src_install

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

# @ECLASS-VARIABLE: MPI_DIR
# @INTERNAL
# @DESCRIPTION:
# Location in which mpi software should be installed
MPI_DIR="/usr/$(get_libdir)/mpi"

# @ECLASS-FUNCTION: mpi-select_implementation_install
# @DESCRIPTION:
# Install MPI software with arbitrary implementations
mpi-select_implementation_install (){
    local installed=mpi-select_detect_installs
    for implementation in "$@"
    do
        if [[ "${installed}" == *"${implementation}"* ]]; then
            # go through src_[phase]
        else
            die "invalid implementation"
        fi
    done
}
# @ECLASS-FUNCTION: mpi-select_detect_installs
# @DESCRIPTION:
# See what MPI software is installed on the system
mpi-select_detect_installs (){
    for dir in "${MPI_DIR}"/*
    do
        INSTALLED_IMPLEMENTATIONS="${INSTALLED_IMPLEMENTATIONS} ${dir}"
    done

    echo "${INSTALLED_IMPLEMENTATIONS}"
}

mpi-select_src_configure (){
    default
}

mpi-select_src_compile (){
    default
}

mpi-select_src_test (){
    default
}

mpi-select_src_install (){
    default
}
