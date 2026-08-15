test_pb_vala = [
    protoc_vala_generator.process(files('test.proto')),
]

test_encode_exec = executable(
    'test-encode-exec',
    files('test-encode.vala') + test_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-encode', test_encode_exec)

test_decode_exec = executable(
    'test-decode-exec',
    files('test-decode.vala') + test_pb_vala,
    dependencies: [protobuf_vala_dep, posix_dep],
    install: false,
)

test('test-decode', test_decode_exec)
