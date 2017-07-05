# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-select.eclass
# @MAINTAINER:
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Allow mpi software to select mpi implementation of choice.

inherit multilib

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

# @ECLASS-VARIABLE: INSTALLED_IMPLEMENTATIONS
# @INTERNAL
# @DESCRIPTION:
# List of used MPI implementation
INSTALLED_IMPLEMENTATIONS=get_all_implementations

# @ECLASS-VARIABLE: MPI_DIR
# @INTERNAL
# @DESCRIPTION:
# Location in which mpi software should be installed
MPI_DIR="/usr/$(get_libdir)/mpi"

# @ECLASS-FUNCTION: mpi-select_detect_installs
# @DESCRIPTION:
# See what MPI software is installed on the system
get_all_implemenetations()
{
    for dir in "${MPI_DIR}"/*
    do
        INSTALLED_IMPLEMENTATIONS="${INSTALLED_IMPLEMENTATIONS} ${dir}"
    done

    echo "${INSTALLED_IMPLEMENTATIONS}"
}

# @ECLASS-FUNCTION: mpi_foreach_implementation
# @DESCRIPTION:
# Iterates through each given implementation and repeats commands for each implementation
mpi_foreach_implementation()
{
	debug-print-function ${FUNCNAME} "${@}"	

	# [[ -z "${INSTALLED_IMPLEMENTATIONS}" ]] \
	#			die "No mpi implementations detected"

	local status=0

	export BUILD_DIR="${PF}-${ABI}"

	for implementation in "${@}"
	do
		# iterate through implementations, repeat same commands for each variant
		if [[ "${IMPLEMENTATION_LIST}" == *"${implementation}"* ]]; then
			local BUILD_DIR="${WORKDIR}/build"
			einfo ${BUILD_DIR}
			
			# modeling after multibuild for testing & learning
			_mpi_run()
			{
				local i=1
				while [[ ${!1} == _* ]];do
					i+=1
				done

				[[ ${i} -le ${#} ]]
				einfo ${@}
				echo ${@}
			}

			_mpi_run "${@}"
		else
			die "invalid implementation!"
		fi

	
	done

	echo "${status}"
}

mpi-select_get_implementation()
{
	echo "${PN}"
}

mpi-select_bindir()
{
	echo "${D}/usr/bin/${PF}/"
}

mpi-select_libdir()
{
	echo "${D}/usr/$(get_libdir)/${PF}/"
}

mpi-select_etcdir()
{
	echo "${D}/etc/${PF}/"
}

mpi_src_configure()
{
	# hmmm how to handle econf flags....
	default
}

mpi_src_compile()
{
	local imp=$(mpi-select_get_implementation)

	if [[ "${imp}" == "mpich" ]]; then
		einfo "hit mpich"
	elif [[ "${imp}" == "openmpi" ]]; then
		einfo "hit openmpi"
	fi
}

mpi_src_test()
{
	default
}

mpi_src_install()
{
	emake DESTDIR="${D}" install

	dodir $(mpi-select_bindir)
	mv "${D}"/usr/bin/* $(mpi-select_bindir)

	dodir $(mpi-select_libdir)
	mv "${D}"/usr/$(get_libdir)/* $(mpi-select_libdir)

	dodir $(mpi-select_etcdir)
	local i
	for i in "${D}/etc/"*; do
		[ "${i}" == $(mpi-select_etcdir) ] && continue
		mv "${i}" $(mpi-select_etcdir)
	done

	find . -type d -empty -delete || die "could not delete empty directories"
}
