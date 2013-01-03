public static int main (string[] args)
{
    check_decode_varint ("00", 0);
    check_decode_varint ("01", 1);
    check_decode_varint ("03", 3);
    check_decode_varint ("7F", 127);
    check_decode_varint ("8001", 128);
    check_decode_varint ("8E02", 270);
    check_decode_varint ("FF7F", 16383);
    check_decode_varint ("808001", 16384);
    check_decode_varint ("9EA705", 86942);

    check_decode_double ("0000000000000000", 0f);
    check_decode_double ("0000000000000080", -0f);
    check_decode_double ("000000000000F03F", 1f);
    check_decode_double ("000000000000F0BF", -1f);
    check_decode_double ("FFFFFFFFFFFFEF7F", double.MAX);
    check_decode_double ("FFFFFFFFFFFFEFFF", -double.MAX);
    check_decode_double ("000000000000F07F", double.INFINITY);
    check_decode_double ("000000000000F0FF", -double.INFINITY);

    check_decode_float ("00000000", 0f);
    check_decode_float ("00000080", -0f);
    check_decode_float ("0000803F", 1f);
    check_decode_float ("000080BF", -1f);
    check_decode_float ("FFFF7F7F", float.MAX);
    check_decode_float ("FFFF7FFF", -float.MAX);
    check_decode_float ("0000807F", float.INFINITY);
    check_decode_float ("000080FF", -float.INFINITY);
    check_decode_float ("0000203E", 0.15625f);

    check_decode_int64 ("00", 0);
    check_decode_int64 ("01", 1);
    check_decode_int64 ("FFFFFFFFFFFFFFFFFF01", -1);
    check_decode_int64 ("FFFFFFFFFFFFFFFF7F", int64.MAX);
    check_decode_int64 ("80808080808080808001", int64.MIN); // FIXME: Double check these

    check_decode_uint64 ("00", 0);
    check_decode_uint64 ("01", 1);
    check_decode_uint64 ("FFFFFFFFFFFFFFFFFF01", uint64.MAX);

    check_decode_int32 ("00", 0);
    check_decode_int32 ("01", 1);
    check_decode_int32 ("FFFFFFFFFFFFFFFFFF01", -1);
    check_decode_int32 ("FFFFFFFF07", int32.MAX);
    check_decode_int32 ("80808080F8FFFFFFFF01", int32.MIN); // FIXME: Double check these

    // FIXME: fixed64

    // FIXME: fixed32

    check_decode_bool ("00", false);
    check_decode_bool ("01", true);
    check_decode_bool ("7F", true);

    check_decode_string ("", "");
    check_decode_string ("313233", "123");

    // FIXME: bytes

    check_decode_uint32 ("00", 0);
    check_decode_uint32 ("01", 1);
    check_decode_uint32 ("FFFFFFFF0F", uint32.MAX);

    // FIXME: sfixed32

    // FIXME: sfixed64

    check_decode_sint32 ("00", 0);
    check_decode_sint32 ("02", 1);
    check_decode_sint32 ("04", 2);
    check_decode_sint32 ("01", -1);
    check_decode_sint32 ("03", -2);
    check_decode_sint32 ("FEFFFFFF0F", int32.MAX);
    check_decode_sint32 ("FFFFFFFF0F", int32.MIN);

    check_decode_sint64 ("00", 0);
    check_decode_sint64 ("02", 1);
    check_decode_sint64 ("04", 2);
    check_decode_sint64 ("01", -1);
    check_decode_sint64 ("03", -2);
    check_decode_sint64 ("FEFFFFFFFFFFFFFFFF01", int64.MAX); // FIXME: Double check these
    check_decode_sint64 ("FFFFFFFFFFFFFFFFFF01", int64.MIN); // FIXME: Double check these

    return 0;
}

private void check_decode_varint (string data, size_t expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_varint (buffer, buffer.length, ref offset);
    if (result != expected)
        stderr.printf ("decode_varint (\"%s\") -> %zu, expected %zu\n", data, result, expected);
}

private void check_decode_double (string data, double expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_double (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_double (\"%s\") -> %f, expected %f\n", data, result, expected);
}

private void check_decode_float (string data, float expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_float (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_float (\"%s\") -> %f, expected %f\n", data, result, expected);
}

private void check_decode_int64 (string data, int64 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_int64 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_int64 (\"%s\") -> %lli, expected %lli\n", data, result, expected);
}

private void check_decode_uint64 (string data, uint64 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_uint64 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_uint64 (\"%s\") -> %llu, expected %llu\n", data, result, expected);
}

private void check_decode_int32 (string data, int32 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_int32 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_int32 (\"%s\") -> %d, expected %d\n", data, result, expected);
}

private void check_decode_bool (string data, bool expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_bool (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_bool (\"%s\") -> %s, expected %s\n", data, result.to_string (), expected.to_string ());
}

private void check_decode_string (string data, string expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_string (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_string (\"%s\") -> \"%s\", expected \"%s\"\n", data, result, expected);
}

private void check_decode_uint32 (string data, uint32 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_uint32 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_uint32 (\"%s\") -> %u, expected %u\n", data, result, expected);
}

private void check_decode_sint32 (string data, int32 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_sint32 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_sint32 (\"%s\") -> %d, expected %d\n", data, result, expected);
}

private void check_decode_sint64 (string data, int64 expected)
{
    var buffer = string_to_buffer (data);
    size_t offset = 0;
    var result = Protobuf.decode_sint64 (buffer, buffer.length, offset);
    if (result != expected)
        stderr.printf ("decode_sint64 (\"%s\") -> %lli, expected %lli\n", data, result, expected);
}

private uint8[] string_to_buffer (string data)
{
    var value = new uint8[data.length / 2];

    for (var i = 0; i < data.length; i++)
        value[i] = str_to_int (data[i*2]) << 4 | str_to_int (data[i*2+1]);

    return value;
}

private uint8 str_to_int (char c)
{
    if (c >= '0' && c <= '9')
        return c - '0';
    else if (c >= 'a' && c <= 'f')
        return c - 'a' + 10;
    else if (c >= 'A' && c <= 'F')
        return c - 'A' + 10;
    else
        return 0;
}
