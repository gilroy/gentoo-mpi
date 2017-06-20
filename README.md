# Gentoo MPI Overlay (Google Summer of Code 2017)

## Description
A collection of tools for assisting the build process for MPI software in order to support installations of multiple MPI implementations and their respective versions. This should serve as a set of standards for MPI ebuild writers, and make it as easy as possible to write and maintain MPI ebuilds.

## mpi-providers.eclass
This is to support multiple MPI implementation's installations in parallel. Remove any "SLOT=" assignment from the ebuild, as this is handled by mpi-providers. Append 'sysconfdir="$(mpi-providers\_sysconfdir)" \' to your econf arguments. In the install phase, insert "mpi-providers\_safe\_mv" to the end of the installation function, as this will move the installation destination in such a way to support parallel installs in /usr/lib/mpi.

## mpi-select.eclass
This allows other mpi software to be built with multiple MPI implementations. For example, if you want to build HPL with mpich _and_ openmpi, mpi-select will build mpich and openmpi against HPL.
