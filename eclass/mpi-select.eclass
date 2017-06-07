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


