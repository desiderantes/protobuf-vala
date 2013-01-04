private int n_tests = 0;
private int n_passed = 0;

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

    check_decode_fixed64 ("0000000000000000", 0);
    check_decode_fixed64 ("0100000000000000", 1);
    check_decode_fixed64 ("EFCDAB8967452301", 0x0123456789ABCDEF);
    check_decode_fixed64 ("FFFFFFFFFFFFFFFF", uint64.MAX);

    check_decode_fixed32 ("00000000", 0);
    check_decode_fixed32 ("01000000", 1);
    check_decode_fixed32 ("67452301", 0x01234567);
    check_decode_fixed32 ("FFFFFFFF", uint32.MAX);

    check_decode_bool ("00", false);
    check_decode_bool ("01", true);
    check_decode_bool ("7F", true);

    check_decode_string ("", "");
    check_decode_string ("313233", "123");

    check_decode_bytes ("", "");
    check_decode_bytes ("AA", "AA");
    check_decode_bytes ("AABBCC", "AABBCC");

    check_decode_uint32 ("00", 0);
    check_decode_uint32 ("01", 1);
    check_decode_uint32 ("FFFFFFFF0F", uint32.MAX);

    check_decode_sfixed32 ("00000000", 0);
    check_decode_sfixed32 ("01000000", 1);
    check_decode_sfixed32 ("FFFFFFFF", -1);
    check_decode_sfixed32 ("00000080", int32.MIN);
    check_decode_sfixed32 ("FFFFFF7F", int32.MAX);

    check_decode_sfixed64 ("0000000000000000", 0);
    check_decode_sfixed64 ("0100000000000000", 1);
    check_decode_sfixed64 ("FFFFFFFFFFFFFFFF", -1);
    check_decode_sfixed64 ("0000000000000080", int64.MIN);
    check_decode_sfixed64 ("FFFFFFFFFFFFFF7F", int64.MAX);

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

    if (n_passed != n_tests)
    {
        stderr.printf ("Failed %d/%d tests\n", n_tests - n_passed, n_tests);
        return Posix.EXIT_FAILURE;
    }
    
    stderr.printf ("Passed all %d tests\n", n_tests);

    return Posix.EXIT_SUCCESS;
}

private void check_decode_varint (string data, size_t expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_varint ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_varint (\"%s\") -> %zu, expected %zu\n", data, result, expected);
}

private void check_decode_double (string data, double expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_double ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_double (\"%s\") -> %f, expected %f\n", data, result, expected);
}

private void check_decode_float (string data, float expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_float ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_float (\"%s\") -> %f, expected %f\n", data, result, expected);
}

private void check_decode_int64 (string data, int64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_int64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_int64 (\"%s\") -> %lli, expected %lli\n", data, result, expected);
}

private void check_decode_uint64 (string data, uint64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_uint64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_uint64 (\"%s\") -> %llu, expected %llu\n", data, result, expected);
}

private void check_decode_int32 (string data, int32 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_int32 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_int32 (\"%s\") -> %d, expected %d\n", data, result, expected);
}

private void check_decode_fixed64 (string data, uint64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_fixed64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_fixed64 (\"%s\") -> %llu, expected %llu\n", data, result, expected);
}

private void check_decode_fixed32 (string data, uint32 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_fixed32 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_fixed32 (\"%s\") -> %u, expected %u\n", data, result, expected);
}

private void check_decode_bool (string data, bool expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_bool ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_bool (\"%s\") -> %s, expected %s\n", data, result.to_string (), expected.to_string ());
}

private void check_decode_string (string data, string expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_string (buffer.buffer.length);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_string (\"%s\") -> \"%s\", expected \"%s\"\n", data, result, expected);
}

private void check_decode_bytes (string data, string expected)
{
    var buffer = string_to_buffer (data);
    var r = buffer.decode_bytes (buffer.buffer.length);
    var result = array_to_string (r.data);

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_bytes (\"%s\") -> \"%s\", expected \"%s\"\n", data, result, expected);
}

private void check_decode_uint32 (string data, uint32 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_uint32 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_uint32 (\"%s\") -> %u, expected %u\n", data, result, expected);
}

private void check_decode_sfixed32 (string data, int32 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_sfixed32 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_sfixed32 (\"%s\") -> %i, expected %i\n", data, result, expected);
}

private void check_decode_sfixed64 (string data, int64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_sfixed64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_sfixed64 (\"%s\") -> %lli, expected %lli\n", data, result, expected);
}

private void check_decode_sint32 (string data, int32 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_sint32 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_sint32 (\"%s\") -> %d, expected %d\n", data, result, expected);
}

private void check_decode_sint64 (string data, int64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_sint64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_sint64 (\"%s\") -> %lli, expected %lli\n", data, result, expected);
}

private Protobuf.DecodeBuffer string_to_buffer (string data)
{
    var value = new Protobuf.DecodeBuffer (data.length / 2);

    for (var i = 0; i < data.length; i++)
        value.buffer[i] = str_to_int (data[i*2]) << 4 | str_to_int (data[i*2+1]);

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

private string array_to_string (uint8[] value)
{
    var text = "";

    for (var i = 0; i < value.length; i++)
        text += "%02X".printf (value[i]);

    return text;
}
