bin_PROGRAMS = protoc-gen-vala

protoc_gen_vala_SOURCES = \
	descriptor.pb.vala \
	plugin.pb.vala \
	protobuf.vapi \
	protoc-gen-vala.vala

protoc_gen_vala_CFLAGS = \
	-DVERSION=\"$(VERSION)\" \
	$(PROTOC_GEN_VALA_CFLAGS)

protoc_gen_vala_LDADD = \
	$(PROTOC_GEN_VALA_LIBS)

vapidir = $(datadir)/vala/vapi
vapi_DATA = protobuf.vapi

CLEANFILES = \
	$(patsubst %.vala,%.c,$(filter %.vala, $(SOURCES))) \
	*_vala.stamp

DISTCLEANFILES = Makefile.in
