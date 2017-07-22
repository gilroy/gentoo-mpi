# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

# @ECLASS: mpi-select.eclass
# @MAINTAINER:
# Michael Gilroy <michael.gilroy24@gmail.com>
# @BLURB: Allow mpi software to select mpi implementation of choice.

inherit multilib multilib-minimal flag-o-matic

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

# @ECLASS-VARIABLE: MPI_TARGETS
# @INTERNAL
# @DESCRIPTION:
# List of implementations in make.conf.
MPI_TARGETS="${MPI_TARGETS}"

# @FUNCTION: mpi_dependencies
# Grabs $MPI_TARGETS to add to RDEPEND
mpi_dependencies()
{
	local impl ret

	for impl in "${MPI_TARGETS}"; do
		if has_version ">=sys-cluster/${impl}"; then
			ret="${ret} >=sys-cluster/${impl}"	
		fi
	done

	echo "${ret}"
}

# @FUNCTION: get_mpicc
# @DESCRIPTION:
# Fetches most recent version of mpicc installed
get_mpicc()
{
	echo "$(ls -dv /usr/$(get_libdir)/mpi/mpich-* | tail -n 1)" || die "could not get mpicc"
}

# @FUNCTION : mpi_pkg_cc
# @DESCRIPTION :
# Get location of C compiler from /usr/
mpi_pkg_cc()
{
	mpi_pkg_compiler "cc"
}

# @FUNCTION: mpi_pkg_compiler
# @DESCRIPTION :
# Returns correct path for the compiler
mpi_pkg_compiler
{
	local args
	for args in "${1}"; do
		if [ -f "/usr/lib64/mpi/mpich-3.2/install/usr/bin" ]; then
			die "hit!!"
			echo "$(get_mpicc)/install/usr/bin/mpi${args}"
			break
		fi
	done
}

# @FUNCTION: mpi_root
# @DESCRIPTION:
# Return installation root
mpi_root()
{
	echo "/usr/$(get_libdir)/mpi/${PN}"	
}

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

# @ECLASS-FUNCTION: mpi_wrapper
# @DESCRIPTION:
# Helper function for setting up environment
mpi_wrapper()
{
	export BUILD_DIR="${PF}-${ABI}"

	export LD_LIBRARY_PATH="/usr/$(get_libdir)/mpi/mpich-3.2/install/usr/bin:${LD_LIBRARY_PATH}"

	echo ${impl}

}

# @ECLASS-FUNCTION: mpi-select_get_implementation
# @DESCRIPTION:
# Helper function for getting the current implementation in use
mpi-select_get_implementation()
{
	echo "${PN}"
}

# @ECLASS-FUNCTION: mpi-select_bindir
# @DESCRIPTION:
# Helper function for getting the directory for binaries to be installed to
mpi-select_bindir()
{
	echo "${D}/usr/bin/${PF}/"
}

# @ECLASS-FUNCTION: mpi-select_libdir
# @DESCRIPTION:
# Helper function for getting the directory for libraries to be installed to
mpi-select_libdir()
{
	echo "${D}/usr/$(get_libdir)/mpi/${PF}/"
}

# @ECLASS-FUNCTION: mpi-select_etcdir
# @DESCRIPTION:
# Helper function for getting the directory for /etc* to be installed to
mpi-select_etcdir()
{
	echo "${D}/etc/${PF}/"
}

###########################
# MPI SRC PHASE FUNCTIONS #
###########################

mpi-select_src_configure()
{
	append-cflags -std=gnu89

	mpi_wrapper

	if [[ "${imp}" == "mpich" ]]; then
		einfo "hit mpich"
	elif [[ "${imp}" == "openmpi" ]]; then
		einfo "hit openmpi"
	fi

	mpi-select_src_configure()
	{
		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f multilib_src_configure > /dev/null ; then
			multilib_src_configure
		else
			default_src_configure
		fi

		popd > /dev/null || die
	}

	multilib_foreach_variant mpi-select_src_configure
}

mpi-select_src_compile()
{
	local imp=$(mpi-select_get_implementation)

	if [[ "${imp}" == "mpich" ]]; then
		einfo "hit mpich"
	elif [[ "${imp}" == "openmpi" ]]; then
		einfo "hit openmpi"
	fi

	mpi-select_src_compile()
	{
		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f multilib_src_compile > /dev/null ; then
			multilib_src_compile
		else
			default_src_compile
		fi

		popd > /dev/null || die
	}

	multilib_foreach_variant mpi-select_src_compile
}

mpi-select_src_test()
{
	emake -j1 check

	mpi-select_src_test()
	{
		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f multilib_src_test > /dev/null ; then
			multilib_src_test
		else
			default_src_test
		fi

		popd > /dev/null || die
	}

	multilib_foreach_variant mpi-select_src_test
}

mpi-select_src_install()
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
		mv "${i}" $(mpi-select_etcdir) || die "failed to mv"
	done

	find . -type d -empty -delete || die "could not delete empty directories"

	mpi-select_src_install()
	{
		mkdir -p "${BUILD_DIR}" || die
		pushd "${BUILD_DIR}" > /dev/null || die
		if declare -f multilib_src_test > /dev/null ; then
			multilib_src_install
		else
			default_src_test
		fi
		
		popd > /dev/null || die
	}

	multilib_foreach_variant mpi-select_src_install

	
	# TODO: proper conditional for einstalldocs
	einstalldocs
}
