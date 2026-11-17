# Runtime wire & buffer primitives (syntax-independent)
test_runtime_exec = executable(
    'test-runtime-exec',
    files('test-runtime.vala'),
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-runtime', test_runtime_exec, suite: ['runtime'])

# Built-in descriptor schemas (descriptor.pb.vala)
test_descriptor_exec = executable(
    'test-descriptor-exec',
    files('test-descriptor.vala'),
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-descriptor', test_descriptor_exec, suite: ['descriptor'])

# Proto2-only syntax & semantics
proto2_pb_vala = [
    protoc_vala_generator.process(files('imported.proto', 'proto2.proto')),
]

test_proto2_exec = executable(
    'test-proto2-exec',
    files('test-proto2.vala') + proto2_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-proto2', test_proto2_exec, suite: ['proto2'])

# Proto3-only syntax & semantics
proto3_pb_vala = [
    protoc_vala_generator.process(files('proto3.proto')),
]

test_proto3_exec = executable(
    'test-proto3-exec',
    files('test-proto3.vala') + proto3_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-proto3', test_proto3_exec, suite: ['proto3'])

# Well-Known Types (Timestamp, Duration, Wrappers, FieldMask)
wkt_pb_vala = [
    protoc_vala_generator.process(files('wkt.proto')),
]

test_wkt_exec = executable(
    'test-wkt-exec',
    files('test-wkt.vala') + wkt_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-wkt', test_wkt_exec, suite: ['wkt'])

# Protobuf map<> fields
maps_pb_vala = [
    protoc_vala_generator.process(files('maps.proto')),
]

test_maps_exec = executable(
    'test-maps-exec',
    files('test-maps.vala') + maps_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-maps', test_maps_exec, suite: ['maps'])

# Editions-only (2023 & 2024) feature inheritance & semantics
gen_editions_req_exec = executable(
    'gen-editions-req',
    files('gen-editions-req.vala'),
    dependencies: [protobuf_vala_dep, posix_dep, dependency('gio-2.0')],
    install: false,
)

editions_pb_vala = custom_target(
    'editions-pb-vala',
    output: ['editions.pb.vala', 'editions2024.pb.vala'],
    command: [gen_editions_req_exec, protoc_gen_vala, '@OUTDIR@'],
    depends: [protoc_gen_vala],
)

test_editions_exec = executable(
    'test-editions-exec',
    [files('test-editions.vala'), editions_pb_vala],
    dependencies: [protobuf_vala_dep, posix_dep, dependency('gio-2.0')],
    install: false,
)

test('test-editions', test_editions_exec, args: [protoc_gen_vala.full_path()], depends: [protoc_gen_vala], suite: ['editions'])
