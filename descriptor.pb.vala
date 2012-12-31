public class FileDescriptorProto
{
    public string? name;
    public string? package;
    public List<string> dependency;
    public List<DescriptorProto> message_type;
    public FileOptions? options;

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
                name = decode_string (buffer, value_length, offset);
                break;
            case 2:
                package = decode_string (buffer, value_length, offset);
                break;
            case 3:
                dependency.append (decode_string (buffer, value_length, offset));
                break;
            case 4:
                var v = new DescriptorProto ();
                v.decode (buffer, offset + value_length, offset);
                message_type.append (v);
                break;
            case 8:
                options = new FileOptions ();
                options.decode (buffer, offset + value_length, offset);
                break;
            default:
                stderr.printf ("Unknown FileDescriptorProto field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of FileDescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var value = "";

        if (name != null)
            value += "name=\"%s\" ".printf (name);
        if (package != null)
            value += "package=\"%s\" ".printf (package);

        if (dependency != null)
        {
            value += "dependency=[";
            foreach (var v in dependency)
                value += "\"%s\" ".printf (v);
            value += "] ";
        }

        if (message_type != null)
        {
            value += "message_type=[";
            foreach (var v in message_type)
                value += "{ %s} ".printf (v.to_string ());
            value += "] ";
        }

        if (options != null)
            value += "options={ %s} ".printf (options.to_string ());

        return value;
    }
}

public class DescriptorProto
{
    public class ExtensionRange
    {
        int32? start;
        int32? end;

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
                    start = varint;
                    break;
                case 2:
                    end = varint;
                    break;
                default:
                    stderr.printf ("Unknown DescriptorProto.ExtensionRange field %d\n", field_number);
                    // Skip unknown data
                    break;
                }

                offset += value_length;
            }

            if (offset != length)
                stderr.printf ("Unused %zu octets on end of DescriptorProto.ExtensionRange\n", offset - length);
        }
    }

    public string? name;
    public List<FieldDescriptorProto> field;
    public List<FieldDescriptorProto> extension;
    public List<DescriptorProto> nested_type;
    public List<EnumDescriptorProto> enum_type;
    public List<ExtensionRange> extension_range;

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
                name = decode_string (buffer, value_length, offset);
                break;
            case 2:
                var m = new FieldDescriptorProto ();
                m.decode (buffer, offset + value_length, offset);
                field.append (m);
                break;
            case 3:
                var v = new DescriptorProto ();
                v.decode (buffer, offset + value_length, offset);
                nested_type.append (v);
                break;
            case 4:
                var v = new EnumDescriptorProto ();
                v.decode (buffer, offset + value_length, offset);
                enum_type.append (v);
                break;
            case 5:
                var v = new ExtensionRange ();
                v.decode (buffer, offset + value_length, offset);
                extension_range.append (v);
                break;
            case 6:
                var m = new FieldDescriptorProto ();
                m.decode (buffer, offset + value_length, offset);
                extension.append (m);
                break;
            default:
                stderr.printf ("Unknown DescriptorProto field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of DescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var value = "";

        if (name != null)
            value += "name=\"%s\" ".printf (name);

        if (field != null)
        {
            value += "field=[";
            foreach (var v in field)
                value += "{ %s} ".printf (v.to_string ());
            value += "] ";
        }

        if (extension != null)
        {
            value += "extension=[";
            foreach (var v in extension)
                value += "{ %s} ".printf (v.to_string ());
            value += "] ";
        }

        if (nested_type != null)
        {
            value += "nested_type=[";
            foreach (var v in nested_type)
                value += "{ %s} ".printf (v.to_string ());
            value += "] ";
        }

        if (enum_type != null)
        {
            value += "enum_type=[";
            foreach (var v in enum_type)
                value += "{ %s} ".printf (v.to_string ());
            value += "] ";
        }

        return value;
    }
}

public class FieldDescriptorProto
{
    public enum Type
    {
        TYPE_DOUBLE = 1,
        TYPE_FLOAT = 2,
        TYPE_INT64 = 3,
        TYPE_UINT64 = 4,
        TYPE_INT32 = 5,
        TYPE_FIXED64 = 6,
        TYPE_FIXED32 = 7,
        TYPE_BOOL  = 8,
        TYPE_STRING = 9,
        TYPE_GROUP = 10,
        TYPE_MESSAGE = 11,
        TYPE_BYTES = 12,
        TYPE_UINT32 = 13,
        TYPE_ENUM  = 14,
        TYPE_SFIXED32 = 15,
        TYPE_SFIXED64 = 16,
        TYPE_SINT32 = 17,
        TYPE_SINT64 = 18
    }

    public string type_to_string (Type type)
    {
        switch (type)
        {
        case Type.TYPE_DOUBLE:
            return "TYPE_DOUBLE";
        case Type.TYPE_FLOAT:
            return "TYPE_FLOAT";
        case Type.TYPE_INT64:
            return "TYPE_INT64";
        case Type.TYPE_UINT64:
            return "TYPE_UINT64";
        case Type.TYPE_INT32:
            return "TYPE_INT32";
        case Type.TYPE_FIXED64:
            return "TYPE_FIXED64";
        case Type.TYPE_FIXED32:
            return "TYPE_FIXED32";
        case Type.TYPE_BOOL:
            return "TYPE_BOOL";
        case Type.TYPE_STRING:
            return "TYPE_STRING";
        case Type.TYPE_GROUP:
            return "TYPE_GROUP";
        case Type.TYPE_MESSAGE:
            return "TYPE_MESSAGE";
        case Type.TYPE_BYTES:
            return "TYPE_BYTES";
        case Type.TYPE_UINT32:
            return "TYPE_UINT32";
        case Type.TYPE_ENUM:
            return "TYPE_ENUM";
        case Type.TYPE_SFIXED32:
            return "TYPE_SFIXED32";
        case Type.TYPE_SFIXED64:
            return "TYPE_SFIXED64";
        case Type.TYPE_SINT32:
            return "TYPE_SINT32";
        case Type.TYPE_SINT64:
            return "TYPE_SINT64";
        default:
            return "%d".printf (type);
        }
    }

    public enum Label
    {
        LABEL_OPTIONAL = 1,
        LABEL_REQUIRED = 2,
        LABEL_REPEATED = 3
    }

    public string label_to_string (Label label)
    {
        switch (label)
        {
        case Label.LABEL_OPTIONAL:
            return "LABEL_OPTIONAL";
        case Label.LABEL_REQUIRED:
            return "LABEL_REQUIRED";
        case Label.LABEL_REPEATED:
            return "LABEL_REPEATED";
        default:
            return "%d".printf (label);
        }
    }

    public string? name;
    public int32? number;
    public Label? label;
    public Type? type;
    public string? type_name;
    public string? default_value;
    public FieldOptions? options;

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
                name = decode_string (buffer, value_length, offset);
                break;
            case 3:
                number = varint;
                break;
            case 4:
                label = (Label) varint;
                break;
            case 5:
                type = (Type) varint;
                break;
            case 6:
                type_name = decode_string (buffer, value_length, offset);
                break;
            case 7:
                default_value = decode_string (buffer, value_length, offset);
                break;
            case 8:
                options = new FieldOptions ();
                options.decode (buffer, offset + value_length, offset);
                break;
            default:
                stderr.printf ("Unknown FieldDescriptorProto field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of FieldDescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";
        
        if (name != null)
            text += "name=\"%s\" ".printf (name);
        if (number != null)
            text += "number=%d ".printf (number);
        if (label != null)
            text += "label=%s ".printf (label_to_string (label));
        if (type != null)
            text += "type=%s ".printf (type_to_string (type));
        if (type_name != null)
            text += "type_name=\"%s\" ".printf (type_name);
        if (default_value != null)
            text += "default_value=\"%s\" ".printf (default_value);
        if (options != null)
            text += "options={ %s} ".printf (options.to_string ());

        return text;
    }
}

public class EnumDescriptorProto
{
    public string? name;
    public List<EnumValueDescriptorProto> value;

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
                name = decode_string (buffer, value_length, offset);
                break;
            case 2:
                var v = new EnumValueDescriptorProto ();
                v.decode (buffer, offset + value_length, offset);
                value.append (v);
                break;
            default:
                stderr.printf ("Unknown EnumDescriptorProto field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of EnumDescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";
        
        if (name != null)
            text += "name=\"%s\" ".printf (name);
        
        text += "value=[";
        foreach (var v in value)
            text += "{ %s} ".printf (v.to_string ());
        text += "] ";

        return text;
    }
}

public class EnumValueDescriptorProto
{
    public string? name;
    public int32? number;

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
                name = decode_string (buffer, value_length, offset);
                break;
            case 2:
                number = varint;
                break;
            default:
                stderr.printf ("Unknown EnumValueDescriptorProto field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of EnumValueDescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";
        
        if (name != null)
            text += "name=\"%s\" ".printf (name);
        if (number != null)
            text += "number=%d ".printf (number);

        return text;
    }
}

public class FileOptions
{
    public enum OptimizeMode
    {
        SPEED = 1,
        CODE_SIZE = 2,
        LITE_RUNTIME = 3
    }

    private string optimize_mode_to_string (OptimizeMode mode)
    {
        switch (mode)
        {
        case OptimizeMode.SPEED:
            return "SPEED";
        case OptimizeMode.CODE_SIZE:
            return "CODE_SIZE";
        case OptimizeMode.LITE_RUNTIME:
            return "LITE_RUNTIME";
        default:
            return "%d".printf (mode);
        }
    }

    public string? java_package;
    public string? java_outer_classname;
    public OptimizeMode? optimize_for;

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
                java_package = decode_string (buffer, value_length, offset);
                break;
            case 8:
                java_outer_classname = decode_string (buffer, value_length, offset);
                break;
            case 9:
                optimize_for = (OptimizeMode) varint;
                break;
            default:
                stderr.printf ("Unknown FileOptions field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of EnumValueDescriptorProto\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";

        if (java_package != null)
            text += "java_package=\"%s\" ".printf (java_package);
        if (java_outer_classname != null)
            text += "java_outer_classname=\"%s\" ".printf (java_outer_classname);
        if (optimize_for != null)
            text += "optimize_for=%s ".printf (optimize_mode_to_string (optimize_for));

        return text;
    }
}

public class FieldOptions
{
    public bool? packed;

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
            case 2:
                packed = varint != 0;
                break;
            default:
                stderr.printf ("Unknown FieldOptions field %d\n", field_number);
                // Skip unknown data
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of FieldOptions\n", offset - length);
    }

    public string to_string ()
    {
        var text = "";

        if (packed != null)
            text += "packed=%s ".printf (packed ? "true" : "false");

        return text;
    }
}
