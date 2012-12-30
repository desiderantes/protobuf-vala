private int decode_int (uint8[] buffer, size_t length, ref size_t offset)
{
    int value = 0;

    while (true)
    {
        var b = buffer[offset];
        offset++;
        value = value << 7 | b & 0x7F;
        if ((b & 0x80) == 0)
            return value;
    }
}

private string decode_string (uint8[] buffer, size_t length, ref size_t offset)
{
    var value = new StringBuilder ();
    for (var i = 0; i < length; i++)
    {
        value.append_c ((char) buffer[offset]);
        offset++;
    }

    return value.str;
}

private size_t get_value_length (int wire_type, out int varint, uint8[] buffer, size_t length, ref size_t offset)
{
    varint = 0;
    switch (wire_type)
    {
    case 0: //varint
        var o = offset;
        varint = decode_int (buffer, length, ref o);
        return o - offset;
    case 1: //64-bit
        return 8;
    case 2: //length-delimited
        return decode_int (buffer, length, ref offset);
    case 5: //32-bit
        return 4;
    default: //FIXME: throw error
        return 0;
    }
}

public class CodeGeneratorRequest
{
    List<string> file_to_generate;
    string? parameter;
    List<FileDescriptorProto> proto_file;

    public void decode (uint8[] buffer, size_t length, size_t offset = 0)
    {
        while (offset < length)
        {
            var key = decode_int (buffer, length, ref offset);
            var wire_type = key & 0x7;
            var field_number = key >> 3;
            int varint;
            var value_length = get_value_length (wire_type, out varint, buffer, length, ref offset);
            // FIXME: Check remaining space

            stderr.printf ("%d %zu\n", field_number, value_length);

            switch (field_number)
            {
            case 1:
                file_to_generate.append (decode_string (buffer, value_length, ref offset));
                break;
            case 2:
                parameter = decode_string (buffer, value_length, ref offset);
                break;
            case 15:
                stderr.printf ("proto_file %d\n", wire_type);
                offset += value_length;
                break;
            default:
                stderr.printf ("Unknown field %d\n", field_number);
                // Skip unknown data
                offset += value_length;
                break;
            }
        }
    }

    public void print ()
    {
        stderr.printf ("file_to_generate:");
        foreach (var f in file_to_generate)
            stderr.printf (" \"%s\"", f);
        stderr.printf ("\n");
        stderr.printf ("parameter: %s\n", parameter);
        stderr.printf ("proto_file:\n");
        foreach (var f in proto_file)
            f.print ();
    }
}

public class CodeGeneratorResponse
{
    string? error;
    File[] file;
}

public class File
{
    string? name;
    string? insertion_point;
    string? content;
}
