private int n_tests = 0;
private int n_passed = 0;

public static int main (string[] args)
{
    check_encode_varint (0, "00");
    check_encode_varint (1, "01");
    check_encode_varint (3, "03");
    check_encode_varint (127, "7F");
    check_encode_varint (128, "8001");
    check_encode_varint (270, "8E02");
    check_encode_varint (16383, "FF7F");
    check_encode_varint (16384, "808001");
    check_encode_varint (86942, "9EA705");
    check_encode_varint (0xFFFFFFFF, "FFFFFFFF0F");
    check_encode_varint (0xFFFFFFFFFFFFFFFF, "FFFFFFFFFFFFFFFFFF01");

    check_encode_double (0f, "0000000000000000");
    check_encode_double (-0f, "0000000000000080");
    check_encode_double (1f, "000000000000F03F");
    check_encode_double (-1f, "000000000000F0BF");
    check_encode_double (double.MAX, "FFFFFFFFFFFFEF7F");
    check_encode_double (-double.MAX, "FFFFFFFFFFFFEFFF");
    check_encode_double (double.INFINITY, "000000000000F07F");
    check_encode_double (-double.INFINITY, "000000000000F0FF");

    check_encode_float (0f, "00000000");
    check_encode_float (-0f, "00000080");
    check_encode_float (1f, "0000803F");
    check_encode_float (-1f, "000080BF");
    check_encode_float (float.MAX, "FFFF7F7F");
    check_encode_float (-float.MAX, "FFFF7FFF");
    check_encode_float (float.INFINITY, "0000807F");
    check_encode_float (-float.INFINITY, "000080FF");
    check_encode_float (0.15625f, "0000203E");

    check_encode_int64 (0, "00");
    check_encode_int64 (1, "01");
    check_encode_int64 (-1, "FFFFFFFFFFFFFFFFFF01");
    check_encode_int64 (int64.MAX, "FFFFFFFFFFFFFFFF7F");
    check_encode_int64 (int64.MIN, "80808080808080808001");

    check_encode_uint64 (0, "00");
    check_encode_uint64 (1, "01");
    check_encode_uint64 (uint64.MAX, "FFFFFFFFFFFFFFFFFF01");

    check_encode_int32 (0, "00");
    check_encode_int32 (1, "01");
    check_encode_int32 (-1, "FFFFFFFFFFFFFFFFFF01");
    check_encode_int32 (int32.MAX, "FFFFFFFF07");
    check_encode_int32 (int32.MIN, "80808080F8FFFFFFFF01");

    check_encode_fixed64 (0, "0000000000000000");
    check_encode_fixed64 (1, "0100000000000000");
    check_encode_fixed64 (0x0123456789ABCDEF, "EFCDAB8967452301");
    check_encode_fixed64 (uint64.MAX, "FFFFFFFFFFFFFFFF");

    check_encode_fixed32 (0, "00000000");
    check_encode_fixed32 (1, "01000000");
    check_encode_fixed32 (0x01234567, "67452301");
    check_encode_fixed32 (uint32.MAX, "FFFFFFFF");

    check_encode_bool (false, "00");
    check_encode_bool (true, "01");

    check_encode_string ("", "");
    check_encode_string ("123", "313233");

    check_encode_bytes ("", "");
    check_encode_bytes ("AA", "AA");
    check_encode_bytes ("AABBCC", "AABBCC");

    check_encode_uint32 (0, "00");
    check_encode_uint32 (1, "01");
    check_encode_uint32 (uint32.MAX, "FFFFFFFF0F");

    check_encode_sfixed32 (0, "00000000");
    check_encode_sfixed32 (1, "01000000");
    check_encode_sfixed32 (-1, "FFFFFFFF");
    check_encode_sfixed32 (int32.MIN, "00000080");
    check_encode_sfixed32 (int32.MAX, "FFFFFF7F");

    check_encode_sfixed64 (0, "0000000000000000");
    check_encode_sfixed64 (1, "0100000000000000");
    check_encode_sfixed64 (-1, "FFFFFFFFFFFFFFFF");
    check_encode_sfixed64 (int64.MIN, "0000000000000080");
    check_encode_sfixed64 (int64.MAX, "FFFFFFFFFFFFFF7F");

    check_encode_sint32 (0, "00");
    check_encode_sint32 (1, "02");
    check_encode_sint32 (2, "04");
    check_encode_sint32 (-1, "01");
    check_encode_sint32 (-2, "03");
    check_encode_sint32 (int32.MAX, "FEFFFFFF0F");
    check_encode_sint32 (int32.MIN, "FFFFFFFF0F");

    check_encode_sint64 (0, "00");
    check_encode_sint64 (1, "02");
    check_encode_sint64 (2, "04");
    check_encode_sint64 (-1, "01");
    check_encode_sint64 (-2, "03");
    check_encode_sint64 (int64.MAX, "FEFFFFFFFFFFFFFFFF01");
    check_encode_sint64 (int64.MIN, "FFFFFFFFFFFFFFFFFF01");
    
    if (n_passed != n_tests)
    {
        stderr.printf ("Failed %d/%d tests\n", n_tests - n_passed, n_tests);
        return Posix.EXIT_FAILURE;
    }
    
    stderr.printf ("Passed all %d tests\n", n_tests);

    return Posix.EXIT_SUCCESS;
}

private void check_encode_varint (uint64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_varint (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_varint (%" + uint64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_double (double value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_double (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_double (%f) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_float (float value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_float (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_float (%f) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_int64 (int64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_int64 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_int64 (%" + int64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_uint64 (uint64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_uint64 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_uint64 (%" + uint64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_int32 (int32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_int32 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_int32 (%d) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_fixed64 (uint64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_fixed64 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_fixed64 (%" + uint64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_fixed32 (uint32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_fixed32 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_fixed32 (%u) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_bool (bool value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_bool (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_bool (%s) -> \"%s\", expected \"%s\"\n", value.to_string (), result, expected);
}

private void check_encode_string (string value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_string (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_string (%s) -> \"%s\", expected \"%s\"\n", value.to_string (), result, expected);
}

private void check_encode_bytes (string value, string expected)
{
    var v = new ByteArray.take (string_to_array (value));

    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_bytes (v);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_bytes (%s) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_uint32 (uint32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_uint32 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_uint32 (%u) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_sfixed32 (int32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_sfixed32 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_sfixed32 (%i) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_sfixed64 (int64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_sfixed64 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_sfixed64 (%" + int64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_sint32 (int32 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_sint32 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_sint32 (%d) -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private void check_encode_sint64 (int64 value, string expected)
{
    var buffer = new Protobuf.EncodeBuffer (100);
    buffer.encode_sint64 (value);
    var result = buffer_to_string (buffer);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("encode_sint64 (%" + int64.FORMAT + ") -> \"%s\", expected \"%s\"\n", value, result, expected);
}

private string buffer_to_string (Protobuf.EncodeBuffer buffer)
{
    var value = "";

    var data = buffer.data;
    for (var i = 0; i < data.length; i++)
        value += "%02X".printf (data[i]);

    return value;
}

private uint8[] string_to_array (string data)
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
