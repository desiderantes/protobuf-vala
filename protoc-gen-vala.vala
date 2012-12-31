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
    
        out_file.content = "";
        foreach (var type in f.message_type)
        {
            out_file.content += "public class %s\n".printf (type.name);
            out_file.content += "{\n";
            foreach (var field in type.field)
                out_file.content += "    public %s %s;\n".printf (get_type_name (field), field.name);
            out_file.content += "}\n";
        }
        stderr.printf ("'%s'\n", out_file.content);

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

private static string get_type_name (FieldDescriptorProto field)
{
    var type_name = "UNKNOWN_TYPE";
    switch (field.type)
    {
    case FieldDescriptorProto.Type.TYPE_INT32:
         type_name = "int32";
         break;
    case FieldDescriptorProto.Type.TYPE_BOOL:
         type_name = "bool";
         break;
    case FieldDescriptorProto.Type.TYPE_STRING:
         type_name = "string";
         break;
    case FieldDescriptorProto.Type.TYPE_MESSAGE:
         type_name = field.type_name.substring (field.type_name.last_index_of (".") + 1);
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
