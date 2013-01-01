public static int main (string[] args)
{
    var buf = new uint8[65535];
    var n_read = stdin.read (buf); // FIXME: Read all
    if (n_read < 0)
        return 1;
    buf.length = (int) n_read;

    var req = new CodeGeneratorRequest ();
    req.decode (buf, n_read);

    stderr.printf ("{ %s }\n", req.to_string ());

    var resp = new CodeGeneratorResponse ();
    
    foreach (var f in req.proto_file)
    {
        var out_file = new CodeGeneratorResponse.File ();

        if (f.name.has_suffix (".proto"))
            out_file.name = f.name.substring (0, f.name.length - 6) + ".pb.vala";
        else
            out_file.name = f.name + ".vala";
    
        out_file.content = "// Generated by protoc-gen-vala from %s, do not edit\n".printf (f.name);
        foreach (var enum_type in f.enum_type)
        {
            out_file.content += "\n";
            out_file.content += write_enum (enum_type);
        }
        foreach (var message_type in f.message_type)
        {
            out_file.content += "\n";
            out_file.content += write_class (message_type);
        }

        resp.file.append (out_file);
    }

    var resp_buf = new uint8[65535];
    var n_written = resp.encode (resp_buf, resp_buf.length - 1);
    unowned uint8[] start = (uint8[]) ((uint8*) resp_buf + resp_buf.length - n_written);
    start.length = (int) n_written;

    stdout.write (start);
    stdout.flush ();

    return 0;
}

private static string write_enum (EnumDescriptorProto type, string indent = "")
{
    var text = "";

    text += indent + "public enum %s\n".printf (type.name);
    text += indent + "{\n";
    foreach (var value in type.value)
        text += indent + "    %s = %d,\n".printf (value.name, value.number);
    text += indent + "}\n";

    return text;
}

private static string write_class (DescriptorProto type, string indent = "")
{
    var text = "";
    text += indent + "public class %s\n".printf (type.name);
    text += indent + "{\n";
    foreach (var enum_type in type.enum_type)
        text += write_enum (enum_type, indent + "    ");
    foreach (var nested_type in type.nested_type)
        text += write_class (nested_type, indent + "    ");
    foreach (var field in type.field)
        text += indent + "    public %s %s;\n".printf (get_type_name (field), field.name);
    text += "\n";
    text += indent + "    public void decode (uint8[] buffer, size_t length, size_t offset = 0)\n";
    text += indent + "    {\n";
    text += indent + "        while (offset < length)\n";
    text += indent + "        {\n";
    text += indent + "            var key = decode_varint (buffer, length, ref offset);\n";
    text += indent + "            var wire_type = key & 0x7;\n";
    text += indent + "            var field_number = key >> 3;\n";
    text += indent + "            int varint;\n";
    text += indent + "            var value_length = get_value_length (wire_type, out varint, buffer, length, ref offset);\n";
    text += indent + "            // FIXME: Check remaining space\n";
    text += "\n";
    text += indent + "            switch (field_number)\n";
    text += indent + "            {\n";
    foreach (var field in type.field)
    {
        text += indent + "            case %d:\n".printf (field.number);
        text += indent + "                break;\n";
    }
    text += indent + "            }\n";
    text += "\n";
    text += indent + "            offset += value_length;\n";
    text += indent + "        }\n";
    text += indent + "    }\n";
    text += "\n";
    text += indent + "    public size_t encode (uint8[] buffer, size_t offset)\n";
    text += indent + "    {\n";
    for (unowned List<FieldDescriptorProto> i = type.field.last (); i != null; i = i.prev)
    {
        var field = i.data;
        var indent2 = indent;
        if (field.label == FieldDescriptorProto.Label.LABEL_OPTIONAL || field.label == FieldDescriptorProto.Label.LABEL_REPEATED)
        {
            text += indent + "        if (%s != null)\n".printf (field.name);
            text += indent + "        {\n";
            indent2 += "    ";
        }

        text += indent2 + "        // ...\n";
        var n = field.number << 3;
        // FIXME add wire_type
        text += indent2 + "        encode_varint (%d, buffer, ref offset);\n".printf (n);

        if (field.label == FieldDescriptorProto.Label.LABEL_OPTIONAL || field.label == FieldDescriptorProto.Label.LABEL_REPEATED)
            text += indent + "        }\n";
    }
    text += indent + "        return 0;\n";
    text += indent + "    }\n";
    text += indent + "}\n";

    return text;
}

private static string get_type_name (FieldDescriptorProto field)
{
    var type_name = "";
    switch (field.type)
    {
    case FieldDescriptorProto.Type.TYPE_DOUBLE:
         type_name = "double";
         break;
    case FieldDescriptorProto.Type.TYPE_FLOAT:
         type_name = "float";
         break;
    case FieldDescriptorProto.Type.TYPE_INT64:
         type_name = "int64";
         break;
    case FieldDescriptorProto.Type.TYPE_UINT64:
         type_name = "uint64";
         break;
    case FieldDescriptorProto.Type.TYPE_INT32:
         type_name = "int32";
         break;
    case FieldDescriptorProto.Type.TYPE_BOOL:
         type_name = "bool";
         break;
    case FieldDescriptorProto.Type.TYPE_STRING:
         type_name = "string";
         break;
    case FieldDescriptorProto.Type.TYPE_BYTES:
         type_name = "uint8[]";
         break;
    case FieldDescriptorProto.Type.TYPE_UINT32:
         type_name = "uint32";
         break;
    case FieldDescriptorProto.Type.TYPE_MESSAGE:
    case FieldDescriptorProto.Type.TYPE_ENUM:
         type_name = field.type_name.substring (field.type_name.last_index_of (".") + 1);
         break;
    default:
         type_name = "UNKNOWN_TYPE%d".printf (field.type);
         break;
    }
    
    switch (field.label)
    {
    case FieldDescriptorProto.Label.LABEL_REPEATED:
        return "List<%s>".printf (type_name);
    case FieldDescriptorProto.Label.LABEL_OPTIONAL:
        return "%s?".printf (type_name);
    default:
    case FieldDescriptorProto.Label.LABEL_REQUIRED:
        return type_name;
    }
}
