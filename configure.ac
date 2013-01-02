AC_INIT(protoc-gen-vala, 0.0.1)
AM_INIT_AUTOMAKE([1.11 no-dist-gzip dist-xz foreign])
AM_SILENT_RULES([yes])
AM_MAINTAINER_MODE
GNOME_MAINTAINER_MODE_DEFINES

AM_PROG_VALAC([0.16.0])
AM_PROG_CC_C_O

PKG_CHECK_MODULES(PROTOC_GEN_VALA, [
  gobject-2.0
  glib-2.0
])

AC_OUTPUT([
Makefile
src/Makefile
])
