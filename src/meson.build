protobuf_vala_sources = files(
	'protobuf-vala.vala',
)

version_split = meson.project_version().split('.')
version_conf = configuration_data()
version_conf.set('VERSION', meson.project_version())
version_conf.set('MAJOR_VERSION', version_split[0])
version_conf.set('MINOR_VERSION', version_split[1])
version_conf.set('MICRO_VERSION', version_split[2])
api_version = version_split[0] + '.' + version_split[1]

config_file = configure_file(input: 'config.vala.in', output: 'config.vala', configuration: version_conf)

protoc_gen_vala_sources = [config_file] + files(
	'protoc-gen-vala.vala',
	'descriptor.pb.vala',
	'plugin.pb.vala',
)

protobuf_vala_deps = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
]

posix_dep = valac.find_library('posix')

proto_dep = dependency('libprotobuf-c')

protobuf_vala_lib = library('protobuf-vala',
	protobuf_vala_sources,
	dependencies: protobuf_vala_deps,
	vala_args: ['--abi-stability'],
	install: true,
	version: api_version,
)

pkgconfig.generate(
	description: 'Vala support for Protocol Buffers',
	libraries: protobuf_vala_lib,
	name: 'protobuf-vala',
	filebase: 'protobuf-vala-' + api_version,
	version: meson.project_version(),
	subdirs: 'protobuf-vala',
	requires: 'glib-2.0',
	install_dir: get_option('libdir') / 'pkgconfig'
)

protoc_gen_vala = executable('protoc-gen-vala', protoc_gen_vala_sources,
	dependencies: protobuf_vala_deps + posix_dep,
	link_with: protobuf_vala_lib,
	install: true
)

protoc_exe = find_program('protoc', required: true)

protoc_vala_generator = generator(protoc_exe,
	output: ['@BASENAME@.pb.vala'],
	arguments: ['--plugin=@0@'.format(protoc_gen_vala.full_path()), '--proto_path=@CURRENT_SOURCE_DIR@', '--vala_out=@BUILD_DIR@', '@INPUT@'],
	depends: [protoc_gen_vala],
)

test_pb_vala = protoc_vala_generator.process(files('test.proto'))

test_encode_exec = executable('test-encode-exec', files('test-encode.vala') + test_pb_vala,
	dependencies: protobuf_vala_deps + posix_dep,
	link_with: protobuf_vala_lib,
)

test('test-encode', test_encode_exec)

test_decode_exec = executable('test-decode-exec', files('test-decode.vala') + test_pb_vala,
	dependencies: protobuf_vala_deps + posix_dep,
	link_with: protobuf_vala_lib,
)

test('test-decode', test_decode_exec)



