lib_LTLIBRARIES = libprotobuf-vala.la
libprotobuf_vala_includedir = $(includedir)/protobuf-vala
libprotobuf_vala_include_DATA = protobuf-vala.h
libprotobuf_vala_vapidir = $(datadir)/vala/vapi
libprotobuf_vala_vapi_DATA = protobuf-vala.vapi
libprotobuf_vala_pkgconfigdir = $(libdir)/pkgconfig
libprotobuf_vala_pkgconfig_DATA = protobuf-vala.pc

libprotobuf_vala_la_SOURCES = \
	protobuf-vala.vala

libprotobuf_vala_la_CFLAGS = \
	$(LIBPROTOBUF_CFLAGS)

libprotobuf_vala_la_LIBADD = \
	$(LIBPROTOBUF_LIBS)

libprotobuf_vala_la_VALAFLAGS = \
	-g \
	--vapi protobuf-vala.vapi \
	-h protobuf-vala.h

bin_PROGRAMS = protoc-gen-vala
noinst_PROGRAMS = test-encode test-decode

TESTS = test-encode test-decode

protoc_gen_vala_SOURCES = \
	descriptor.pb.vala \
	plugin.pb.vala \
	protoc-gen-vala.vala

protoc_gen_vala_VALAFLAGS = \
	--pkg protobuf-vala \
	-g \
	--vapidir .

protoc_gen_vala_CFLAGS = \
	-DVERSION=\"$(VERSION)\" \
	$(PROTOC_GEN_VALA_CFLAGS)

protoc_gen_vala_LDADD = \
	libprotobuf-vala.la
	$(PROTOC_GEN_VALA_LIBS)

test_encode_SOURCES = \
	test-encode.vala

test_encode_VALAFLAGS = \
	--pkg posix \
	--pkg protobuf-vala \
	-g \
	--vapidir .

test_encode_CFLAGS = \
	$(PROTOC_GEN_VALA_CFLAGS)

test_encode_LDADD = \
	libprotobuf-vala.la
	$(PROTOC_GEN_VALA_LIBS)

test_decode_SOURCES = \
	test-decode.vala

test_decode_VALAFLAGS = \
	--pkg posix \
	--pkg protobuf-vala \
	-g \
	--vapidir .

test_decode_CFLAGS = \
	$(PROTOC_GEN_VALA_CFLAGS)

test_decode_LDADD = \
	libprotobuf-vala.la
	$(PROTOC_GEN_VALA_LIBS)

CLEANFILES = \
	$(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) \
	*_vala.stamp \
	protobuf-vala.h \
	protobuf-vala.vapi

DISTCLEANFILES = Makefile.in
