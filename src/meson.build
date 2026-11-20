protobuf_vala_sources = files(
    'protobuf-vala.vala',
    'descriptor.pb.vala',
    'plugin.pb.vala',
)

version_split = meson.project_version().split('.')
version_conf = configuration_data()
version_conf.set('VERSION', meson.project_version())
version_conf.set('MAJOR_VERSION', version_split[0])
version_conf.set('MINOR_VERSION', version_split[1])
version_conf.set('MICRO_VERSION', version_split[2])
api_version = version_split[0] + '.' + version_split[1]

config_file = configure_file(
    input: 'config.vala.in',
    output: 'config.vala',
    configuration: version_conf,
)

protoc_gen_vala_sources = [config_file] + files(
    'protoc-gen-vala.vala',
    'wkt-handlers/wkt-handler.vala',
    'wkt-handlers/timestamp-handler.vala',
    'wkt-handlers/duration-handler.vala',
    'wkt-handlers/wrapper-handler.vala',
    'wkt-handlers/field-mask-handler.vala',
)

protobuf_vala_deps = [
    dependency('glib-2.0', version: '>= 2.80'),
    dependency('gobject-2.0'),
    dependency('gee-0.8'),
]

valapoet_dep = dependency(
    'valapoet-0.2',
    fallback: ['valapoet', 'valapoet_dep'],
    default_options: {'enable_valadoc': false, 'enable_tests': false},
)

posix_dep = valac.find_library('posix')

protobuf_vala_lib = library(
    'protobuf-vala',
    protobuf_vala_sources,
    dependencies: protobuf_vala_deps,
    vala_args: ['--abi-stability'],
    install: true,
    version: api_version,
)

protobuf_vala_dep = declare_dependency(
    link_with: protobuf_vala_lib,
    include_directories: include_directories('.'),
    dependencies: protobuf_vala_deps,
)

meson.override_dependency('protobuf-vala-' + api_version, protobuf_vala_dep)

pkgconfig.generate(
    description: 'Vala support for Protocol Buffers',
    libraries: protobuf_vala_lib,
    name: 'protobuf-vala',
    filebase: 'protobuf-vala-' + api_version,
    version: meson.project_version(),
    subdirs: 'protobuf-vala',
    requires: ['glib-2.0', 'gee-0.8'],
    install_dir: get_option('libdir') / 'pkgconfig',
)

protoc_gen_vala = executable(
    'protoc-gen-vala',
    protoc_gen_vala_sources,
    dependencies: protobuf_vala_deps + [posix_dep, valapoet_dep],
    link_with: protobuf_vala_lib,
    install: true,
)

meson.override_find_program('protoc-gen-vala', protoc_gen_vala)

protoc_exe = find_program('protoc', required: true)

protoc_vala_generator = generator(
    protoc_exe,
    output: ['@BASENAME@.pb.vala'],
    arguments: [
        '--plugin=@0@'.format(protoc_gen_vala.full_path()),
        '--proto_path=@CURRENT_SOURCE_DIR@',
        '--vala_out=@BUILD_DIR@',
        '@INPUT@',
    ],
    depends: [protoc_gen_vala],
)

fs = import('fs')
regen_proto_dir = get_option('protobuf_proto_dir')
if regen_proto_dir == ''
    if fs.exists(meson.current_source_dir() / 'proto/google/protobuf/descriptor.proto')
        regen_proto_dir = meson.current_source_dir() / 'proto'
    else
        protobuf_dep = dependency('protobuf', required: false)
        if protobuf_dep.found()
            regen_proto_dir = protobuf_dep.get_variable(pkgconfig: 'includedir', default_value: '')
        endif
        if regen_proto_dir == ''
            regen_proto_dir = fs.parent(fs.parent(protoc_exe.full_path())) / 'include'
        endif
    endif
endif
summary({'regen-proto proto dir': regen_proto_dir}, section: 'Codegen')

sh = find_program('sh')
run_target(
    'regen-proto',
    command: [
        sh,
        '-c',
        'dir="$1"; protoc_bin="$2"; plugin="$3"; outdir="$4"; ' +
        'if [ ! -f "$dir/google/protobuf/descriptor.proto" ] || [ ! -f "$dir/google/protobuf/compiler/plugin.proto" ]; then ' +
        '  echo "error: descriptor.proto or plugin.proto not found under $dir (pass -Dprotobuf_proto_dir=/path/to/protobuf/src)" >&2; exit 1; ' +
        'fi; ' +
        'if ! grep -q "enum Edition" "$dir/google/protobuf/descriptor.proto"; then ' +
        '  echo "error: $dir/google/protobuf/descriptor.proto predates Editions (requires protobuf >= 26 headers); pass -Dprotobuf_proto_dir=/path/to/protobuf/src" >&2; exit 1; ' +
        'fi; ' +
        'exec "$protoc_bin" --plugin="protoc-gen-vala=$plugin" --vala_opt=paths=flat --proto_path="$dir" --vala_out="$outdir" "$dir/google/protobuf/descriptor.proto" "$dir/google/protobuf/compiler/plugin.proto"',
        'regen-proto',
        regen_proto_dir,
        protoc_exe.full_path(),
        protoc_gen_vala.full_path(),
        meson.current_source_dir(),
    ],
    depends: [protoc_gen_vala],
)


