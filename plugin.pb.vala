private int decode_varint (uint8[] buffer, size_t length, ref size_t offset)
{
    int value = 0;
    var shift = 0;

    while (true)
    {
        var b = buffer[offset];
        offset++;
        value = value | (b & 0x7F) << shift;
        if ((b & 0x80) == 0)
            return value;
        shift += 7;
    }
}

private string decode_string (uint8[] buffer, size_t length, size_t offset)
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
        varint = decode_varint (buffer, length, ref o);
        return o - offset;
    case 1: //64-bit
        return 8;
    case 2: //length-delimited
        return decode_varint (buffer, length, ref offset);
    case 5: //32-bit
        return 4;
    default: //FIXME: throw error
        stderr.printf ("Unknown wire type %d\n", wire_type);
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
            var key = decode_varint (buffer, length, ref offset);
            var wire_type = key & 0x7;
            var field_number = key >> 3;
            int varint;
            var value_length = get_value_length (wire_type, out varint, buffer, length, ref offset);
            // FIXME: Check remaining space

            switch (field_number)
            {
            case 1:
                file_to_generate.append (decode_string (buffer, value_length, offset));
                break;
            case 2:
                parameter = decode_string (buffer, value_length, offset);
                break;
            case 15:
                var f = new FileDescriptorProto ();
                f.decode (buffer, offset + value_length, offset);
                proto_file.append (f);
                break;
            default:
                stderr.printf ("Unknown CodeGeneratorRequest field %d\n", field_number);
                Process.exit (1);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of CodeGeneratorRequest\n", offset - length);
    }

    public string to_string ()
    {
        var value = "file_to_generate=[";
        foreach (var f in file_to_generate)
            value += "\"%s\" ".printf (f);
        value += "]";
        if (parameter != null)
            value += " parameter=\"%s\"".printf (parameter);
        value += " proto_file=[";
        foreach (var f in proto_file)
            value += "{ %s } ".printf (f.to_string ());
        value += "]";
        return value;
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
