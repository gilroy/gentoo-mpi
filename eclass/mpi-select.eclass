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
			ret="${ret} =sys-cluster/${impl}"	
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
# Sets the root directory for the mpi pkg install
mpi_root
{
	echo "/usr/$(get_libdir)/mpi/${PF}"	
}

# @FUNCTION: mpi_foreach_implementation
# @DESCRIPTION:
# Iterates through each implementation and executes src_* commands
mpi_foreach_implementation()
{
	debug-print-function ${FUNCNAME} "${@}"

	# [[ -z "${INSTALLED_IMPLEMENTATIONS}" ]] \
	#			die "No mpi implementations detected"

	local status=0

	for implementation in "${MPI_TARGETS}"
	do
		# iterate through implementations, repeat same commands for each variant
		if [[ "${IMPLEMENTATION_LIST}" ~= *"${implementation}"* ]]
			local BUILD_DIR="${WORKDIR}/build"

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
		else
			die "invalid implementation!"
		fi


	done

	echo "${status}"
}

# @FUNCTION: _mpi_do
# @DESCRIPTION:
# mpi-sepecific build functions to be called from mpi pkg ebuilds
_mpi_do()
{
	local rc prefix d
	local cmd=${1}
	local ran=1
	local slash=/
	local mdir="$(mpi_root)"

	shift


	if [ "${cmd#do}" != "${cmd}" ]; then
		prefix="do"; cmd=${cmd#do}
	elif [ "${cmd#new}" != "${cmd}" ]; then
		prefix="new"; cmd=${cmd#new}
	else
		die "Unknown command passed to _mpi_do: ${cmd}"
	fi

	case ${cmd} in
		bin|lib|lib.a|lib.so|sbin)
			DESTTREE="${mdir}usr" ${prefix}${cmd} $*
			rc=$?
			;;
		doc)
			_E_DOCDESTTREE_="../../../../${mdir}usr/share/doc/${PF}/${_E_DOCDESTTREE_}" \
				${prefix}${cmd} $*
			rc=$?
			for d in "/share/doc/${P}" "/share/doc" "/share"; do
				rmdir ${D}/usr${d} &>/dev/null
			done
			;;
		html)
			_E_DOCDESTTREE_="../../../../${mdir}usr/share/doc/${PF}/www/${_E_DOCDESTTREE_}" \
			${prefix}${cmd} $*
			rc=$?
			for d in "/share/doc/${P}/html" "/share/doc/${P}" "/share/doc" "/share"; do
				rmdir ${D}/usr${d} &>/dev/null
			done
			;;
		exe)
			_E_EXEDESTTREE_="${mdir}${_E_EXEDESTTREE_}" ${prefix}${cmd} $*
			rc=$?
			;;
		man|info)
			"${D}"usr/share/${cmd} ] && mv "${D}"usr/share/${cmd}{,-orig}
			[ ! -d "${D}"${mdir}usr/share/${cmd} ] \
				&& install -d "${D}"${mdir}usr/share/${cmd}
			[ ! -d "${D}"usr/share ] \
				&& install -d "${D}"usr/share

			ln -snf ../../${mdir}usr/share/${cmd} ${D}usr/share/${cmd}
			${prefix}${cmd} $*
			rc=$?
			rm "${D}"usr/share/${cmd}
			[ -d "${D}"usr/share/${cmd}-orig ] \
				&& mv "${D}"usr/share/${cmd}{-orig,}
			[ "$(find "${D}"usr/share/)" == "${D}usr/share/" ] \
			rmdir "${D}usr/share"
			;;
		dir)
			dodir "${@/#${slash}/${mdir}${slash}}"; rc=$?
			;;
		hard|sym)
			${prefix}${cmd} "${mdir}$1" "${mdir}/$2"; rc=$?
			;;
		ins)
			INSDESTTREE="${mdir}${INSTREE}" ${prefix}${cmd} $*; rc=$?
			;;
		*)
			rc=0
			;;
	esac

	[[ ${ran} -eq 0 ]] && die "mpi_do passed unknown command: ${cmd}"
	return ${rc}
}

mpi_dobin()     { _mpi_do "dobin"        $*; }
mpi_newbin()    { _mpi_do "newbin"       $*; }
mpi_dodoc()     { _mpi_do "dodoc"        $*; }
mpi_newdoc()    { _mpi_do "newdoc"       $*; }
mpi_doexe()     { _mpi_do "doexe"        $*; }
mpi_newexe()    { _mpi_do "newexe"       $*; }
mpi_dohtml()    { _mpi_do "dohtml"       $*; }
mpi_dolib()     { _mpi_do "dolib"        $*; }
mpi_dolib.a()   { _mpi_do "dolib.a"      $*; }
mpi_newlib.a()  { _mpi_do "newlib.a"     $*; }
mpi_dolib.so()  { _mpi_do "dolib.so"     $*; }
mpi_newlib.so() { _mpi_do "newlib.so"    $*; }
mpi_dosbin()    { _mpi_do "dosbin"       $*; }
mpi_newsbin()   { _mpi_do "newsbin"      $*; }
mpi_doman()     { _mpi_do "doman"        $*; }
mpi_newman()    { _mpi_do "newman"       $*; }
mpi_doinfo()    { _mpi_do "doinfo"       $*; }
mpi_dodir()     { _mpi_do "dodir"        $*; }
mpi_dohard()    { _mpi_do "dohard"       $*; }
mpi_doins()     { _mpi_do "doins"        $*; }
mpi_dosym()     { _mpi_do "dosym"        $*; }


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

# @FUCNTION: mpi-select_mpi_pkg_set_env
# @DESCRIPTION:
# Set environment variables specificly for mpi
mpi-select_mpi_pkg_set_env()
{
	_mpi_oCC=${CC}
	_mpi_oCXX=${CXX}
	_mpi_oF77=${FF}
	_mpi_oFC=${FC}
	_mpi_oPCP=${PKG_CONFIG_PATH}
	_mpi_oLLP=${LD_LIBRARY_PATH}
	export CC=$(mpi_pkg_cc)
	export CXX=$(mpi_pkg_cxx)
	export F77=$(mpi_pkg_f77)
	export FC=$(mpi_pkg_fc)
	export PKG_CONFIG_PATH="$(mpi_root)$(get_libdir)/pkgconfig:${PKG_CONFIG_PATH}"
	export LD_LIBRARY_PATH="/usr/$(get_libdir)/mpi/mpich-3.2/install/usr/bin:${LD_LIBRARY_PATH}"
}

# @FUCNTION: mpi-select_mpi_pkg_restore_env
# @DESCRIPTION:
# Set envrionment variables to what they were before mpi_pkg_set_env
mpi-select_mpi_pkg_set_env()
{
	export CC=${_mpi_oCC}
	export CXX=$_mpi_oCXX
	export F77=$_mpi_oF77
	export FC=$_mpi_oFC
	export PKG_CONFIG_PATH=${_mpi_oPCP}
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
