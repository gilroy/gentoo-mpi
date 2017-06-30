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

# TODO: write src_configure/compile/test/
mpi_src_configure()
{
	debug-print-function "${FUNCNAME}" "${@}"

	mpi-select_abi_src_configure()
	{
		debug-print-function "${FUNCNAME}" "${@}"
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f mpi_src_configure > /dev/null; then
			mpi_src_configure
		else
			default_src_configure	
		fi
		popd > /dev/null || die
	}

	mpi_foreach_implementation mpi-select_abi_src_configure
}

mpi_src_compile()
{
	debug-print-function "${FUNCNAME}" "${@}"

	mpi-select_abi_src_compile()
	{
		debug-print-function "${FUNCNAME}" "${@}"
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f mpi_src_configure > /dev/null; then
			mpi_src_compile
		else
			default_src_configure	
		fi
		popd > /dev/null || die
	}

	mpi_foreach_implementation mpi-select_abi_src_compile
}

mpi_src_test()
{
	debug-print-function "${FUNCNAME}" "${@}"

	mpi-select_abi_src_test()
	{
		debug-print-function "${FUNCNAME}" "${@}"
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f mpi_src_configure > /dev/null; then
			mpi_src_test
		else
			default_src_configure	
		fi
		popd > /dev/null || die
	}

	mpi_foreach_implementation mpi-select_abi_src_test
}

mpi_src_install()
{
	debug-print-function "${FUNCNAME}" "${@}"

	mpi-select_abi_src_install()
	{
		debug-print-function "${FUNCNAME}" "${@}"
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f mpi_src_configure > /dev/null; then
			mpi_src_install_
		else
			default_src_configure	
		fi
		popd > /dev/null || die
	}
	mpi_foreach_implementation mpi-select_abi_src_install
}
