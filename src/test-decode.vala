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

    // FIXME: float

    // FIXME: int64

    // FIXME: uint64

    // FIXME: int32

    // FIXME: fixed64

    // FIXME: fixed32

    check_decode_bool ("00", false);
    check_decode_bool ("01", true);
    check_decode_bool ("7F", true);

    check_decode_string ("", "");
    check_decode_string ("313233", "123");

    // FIXME: bytes

    // FIXME: uint32

    // FIXME: sfixed32

    // FIXME: sfixed64

    // FIXME: sint32

    // FIXME: sint64

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