test_pb_vala = [
    protoc_vala_generator.process(files('test.proto')),
]

test3_pb_vala = [
    protoc_vala_generator.process(files('test3.proto')),
]

test_encode_exec = executable(
    'test-encode-exec',
    files('test-encode.vala') + test_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-encode', test_encode_exec, suite: ['proto2'])

test_decode_exec = executable(
    'test-decode-exec',
    files('test-decode.vala') + test_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-decode', test_decode_exec, suite: ['proto2'])

test3_encode_exec = executable(
    'test3-encode-exec',
    files('test3-encode.vala') + test3_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test3-encode', test3_encode_exec, suite: ['proto3'])

test3_decode_exec = executable(
    'test3-decode-exec',
    files('test3-decode.vala') + test3_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test3-decode', test3_decode_exec, suite: ['proto3'])
