private int n_tests = 0;
private int n_passed = 0;

public static int main (string[] args)
{
    check_decode_varint ("", 0, true);
    check_decode_varint ("00", 0);
    check_decode_varint ("01", 1);
    check_decode_varint ("03", 3);
    check_decode_varint ("7F", 127);
    check_decode_varint ("FF", 0, true);
    check_decode_varint ("8001", 128);
    check_decode_varint ("8E02", 270);
    check_decode_varint ("FF7F", 16383);
    check_decode_varint ("808001", 16384);
    check_decode_varint ("9EA705", 86942);
    check_decode_varint ("FFFFFF07", 0xFFFFFF);
    check_decode_varint ("FFFFFFFF0F", 0xFFFFFFFF);
    check_decode_varint ("FFFFFFFFFFFFFFFFFF01", 0xFFFFFFFFFFFFFFFF);

    check_decode_double ("", 0d, true);
    check_decode_double ("00", 0d, true);
    check_decode_double ("00000000000000", 0d, true);
    check_decode_double ("0000000000000000", 0d);
    check_decode_double ("0000000000000080", -0d);
    check_decode_double ("000000000000F03F", 1d);
    check_decode_double ("000000000000F0BF", -1d);
    check_decode_double ("FFFFFFFFFFFFEF7F", double.MAX);
    check_decode_double ("FFFFFFFFFFFFEFFF", -double.MAX);
    check_decode_double ("000000000000F07F", double.INFINITY);
    check_decode_double ("000000000000F0FF", -double.INFINITY);

    check_decode_float ("", 0f, true);
    check_decode_float ("00", 0f, true);
    check_decode_float ("000000", 0f, true);
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
    check_decode_int64 ("80808080808080808001", int64.MIN);

    check_decode_uint64 ("00", 0);
    check_decode_uint64 ("01", 1);
    check_decode_uint64 ("FFFFFFFFFFFFFFFFFF01", uint64.MAX);

    check_decode_int32 ("00", 0);
    check_decode_int32 ("01", 1);
    check_decode_int32 ("FFFFFFFFFFFFFFFFFF01", -1);
    check_decode_int32 ("FFFFFFFF07", int32.MAX);
    check_decode_int32 ("80808080F8FFFFFFFF01", int32.MIN);

    check_decode_fixed64 ("0000000000000000", 0);
    check_decode_fixed64 ("0100000000000000", 1);
    check_decode_fixed64 ("EFCDAB8967452301", 0x0123456789ABCDEF);
    check_decode_fixed64 ("FFFFFFFFFFFFFFFF", uint64.MAX);

    check_decode_fixed32 ("00000000", 0);
    check_decode_fixed32 ("01000000", 1);
    check_decode_fixed32 ("67452301", 0x01234567);
    check_decode_fixed32 ("FFFFFFFF", uint32.MAX);

    check_decode_bool ("", false, true);
    check_decode_bool ("00", false);
    check_decode_bool ("01", true);
    check_decode_bool ("7F", true);
    check_decode_bool ("FF", false, true);

    check_decode_string ("", 0, "");
    check_decode_string ("", 1, "", true);
    check_decode_string ("31", 1, "1");
    check_decode_string ("31", 3, "", true);
    check_decode_string ("313233", 3, "123");
    check_decode_string ("313233", 5, "", true);

    check_decode_bytes ("", 0, "");
    check_decode_bytes ("", 1, "", true);
    check_decode_bytes ("AA", 1, "AA");
    check_decode_bytes ("AA", 3, "", true);
    check_decode_bytes ("AABBCC", 3, "AABBCC");
    check_decode_bytes ("AABBCC", 5, "", true);

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
    check_decode_sint64 ("FEFFFFFFFFFFFFFFFF01", int64.MAX);
    check_decode_sint64 ("FFFFFFFFFFFFFFFFFF01", int64.MIN);

    check_decode_message ("", 0, "", TestEnum.ONE, true);
    check_decode_message ("0800", 0, "", TestEnum.ONE, true);
    check_decode_message ("1200", 0, "", TestEnum.ONE, true);
    check_decode_message ("080012001802", 0, "", TestEnum.TWO);
    check_decode_message ("08021204544553541802", 1, "TEST", TestEnum.TWO);
    check_decode_message ("080218021204544553541A03313233", 1, "TEST", TestEnum.TWO);

    check_decode_optional_message ("", 0, "");
    check_decode_optional_message ("0802", 1, "");
    check_decode_optional_message ("120454455354", 0, "TEST");
    check_decode_optional_message ("0802120454455354", 1, "TEST");

    check_decode_optional_defaults_message ("08001200", 0, "");
    check_decode_optional_defaults_message ("1200", 1, "");
    check_decode_optional_defaults_message ("0800", 0, "TEST");
    check_decode_optional_defaults_message ("", 1, "TEST");

    check_decode_repeated_message ("", "");
    check_decode_repeated_message ("0801", "1");
    check_decode_repeated_message ("0801080208030804", "1 2 3 4");

    check_decode_repeated_message ("", "");
    check_decode_repeated_message ("0801", "1");
    check_decode_repeated_message ("0801080208030804", "1 2 3 4");

    check_decode_repeated_message ("", "");
    check_decode_repeated_message ("0801", "1");
    check_decode_repeated_message ("0801080208030804", "1 2 3 4");

    check_decode_repeated_message ("", "");
    check_decode_repeated_message ("0801", "1");
    check_decode_repeated_message ("0801080208030804", "1 2 3 4");

    check_decode_repeated_packed_message ("", "");
    check_decode_repeated_packed_message ("0A0101", "1");
    check_decode_repeated_packed_message ("0A0401020304", "1 2 3 4");
    check_decode_repeated_packed_message ("0A0201020A020304", "1 2 3 4");

    if (n_passed != n_tests)
    {
        stderr.printf ("Failed %d/%d tests\n", n_tests - n_passed, n_tests);
        return Posix.EXIT_FAILURE;
    }
    
    stderr.printf ("Passed all %d tests\n", n_tests);

    return Posix.EXIT_SUCCESS;
}

private void check_decode_varint (string data, uint64 expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_varint ();

    n_tests++;

    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_varint (\"%s\") -> error %s, expected error %s\n", data, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_varint (\"%s\") -> %" + uint64.FORMAT + ", expected %" + uint64.FORMAT + "\n", data, result, expected);
}

private void check_decode_double (string data, double expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_double ();

    n_tests++;
    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_double (\"%s\") -> error %s, expected error %s\n", data, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_double (\"%s\") -> %f, expected %f\n", data, result, expected);
}

private void check_decode_float (string data, float expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_float ();

    n_tests++;
    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_float (\"%s\") -> error %s, expected error %s\n", data, buffer.error.to_string (), error.to_string ());
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
        stderr.printf ("decode_int64 (\"%s\") -> %" + int64.FORMAT + ", expected %" + int64.FORMAT + "\n", data, result, expected);
}

private void check_decode_uint64 (string data, uint64 expected)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_uint64 ();

    n_tests++;
    if (result == expected)
        n_passed++;
    else
        stderr.printf ("decode_uint64 (\"%s\") -> %" + uint64.FORMAT + ", expected %" + uint64.FORMAT + "\n", data, result, expected);
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
        stderr.printf ("decode_fixed64 (\"%s\") -> %" + uint64.FORMAT + ", expected %" + uint64.FORMAT + "\n", data, result, expected);
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

private void check_decode_bool (string data, bool expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_bool ();

    n_tests++;
    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_bool (\"%s\") -> error %s, expected error %s\n", data, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_bool (\"%s\") -> %s, expected %s\n", data, result.to_string (), expected.to_string ());
}

private void check_decode_string (string data, size_t length, string expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var result = buffer.decode_string (length);

    n_tests++;
    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_string (\"%s\", %zu) -> error %s, expected error %s\n", data, length, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_string (\"%s\", %zu) -> \"%s\", expected \"%s\"\n", data, length, result, expected);
}

private void check_decode_bytes (string data, size_t length, string expected, bool error = false)
{
    var buffer = string_to_buffer (data);
    var r = buffer.decode_bytes (length);
    var result = array_to_string (r.data);

    n_tests++;
    if (!error && !buffer.error && result == expected)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_bytes (\"%s\", %zu) -> error %s, expected error %s\n", data, length, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_bytes (\"%s\", %zu) -> \"%s\", expected \"%s\"\n", data, length, result, expected);
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
        stderr.printf ("decode_sfixed64 (\"%s\") -> %" + int64.FORMAT + ", expected %" + int64.FORMAT + "\n", data, result, expected);
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
        stderr.printf ("decode_sint64 (\"%s\") -> %" + int64.FORMAT + ", expected %" + int64.FORMAT + "\n", data, result, expected);
}

private void check_decode_message (string data, int32 int_value, string string_value, TestEnum enum_value, bool error = false)
{
    var result = new TestMessage ();
    var buffer = string_to_buffer (data);
    result.decode (buffer, buffer.buffer.length);

    n_tests++;
    if (!error && !buffer.error && result.int_value == int_value && result.string_value == string_value && result.enum_value == enum_value)
        n_passed++;
    else if (error && buffer.error)
        n_passed++;
    else if (buffer.error != error)
        stderr.printf ("decode_message (\"%s\") -> error %s, expected error %s\n", data, buffer.error.to_string (), error.to_string ());
    else
        stderr.printf ("decode_message (\"%s\") -> int_value=%d string_value=\"%s\" enum_value=%s, expected int_value=%d string_value=\"%s\" enum_value=%s\n",
                       data, result.int_value, result.string_value, TestEnum_to_string (result.enum_value), int_value, string_value, TestEnum_to_string (enum_value));
}

private void check_decode_optional_message (string data, int32 int_value, string string_value)
{
    var result = new TestOptionalMessage ();
    var buffer = string_to_buffer (data);
    result.decode (buffer, buffer.buffer.length);

    n_tests++;
    if (result.int_value == int_value && result.string_value == string_value)
        n_passed++;
    else
        stderr.printf ("decode_optional_message (\"%s\") -> int_value=%d string_value=\"%s\", expected int_value=%d string_value=\"%s\"\n",
                       data, result.int_value, result.string_value, int_value, string_value);
}

private void check_decode_optional_defaults_message (string data, int32 int_value, string string_value)
{
    var result = new TestOptionalDefaultsMessage ();
    var buffer = string_to_buffer (data);
    result.decode (buffer, buffer.buffer.length);

    n_tests++;
    if (result.int_value == int_value && result.string_value == string_value)
        n_passed++;
    else
        stderr.printf ("decode_optional_defaults_message (\"%s\") -> int_value=%d string_value=\"%s\", expected int_value=%d string_value=\"%s\"\n",
                       data, result.int_value, result.string_value, int_value, string_value);
}

private void check_decode_repeated_message (string data, string expected)
{
    var result = new TestRepeatedMessage ();
    var buffer = string_to_buffer (data);
    result.decode (buffer, buffer.buffer.length);

    var result_value = "";
    foreach (var v in result.value)
    {
        if (result_value != "")
            result_value += " ";
        result_value += "%u".printf (v);
    }

    n_tests++;
    if (result_value == expected)
        n_passed++;
    else
        stderr.printf ("decode_repeated_message (\"%s\") -> %s, expected %s\n", data, result_value, expected);
}

private void check_decode_repeated_packed_message (string data, string expected)
{
    var result = new TestRepeatedPackedMessage ();
    var buffer = string_to_buffer (data);
    result.decode (buffer, buffer.buffer.length);

    var result_value = "";
    foreach (var v in result.value)
    {
        if (result_value != "")
            result_value += " ";
        result_value += "%u".printf (v);
    }

    n_tests++;
    if (result_value == expected)
        n_passed++;
    else
        stderr.printf ("decode_repeated_packed_message (\"%s\") -> %s, expected %s\n", data, result_value, expected);
}

private Protobuf.DecodeBuffer string_to_buffer (string data)
{
    var value = new Protobuf.DecodeBuffer (data.length / 2);

    for (var i = 0; i < value.buffer.length; i++)
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
