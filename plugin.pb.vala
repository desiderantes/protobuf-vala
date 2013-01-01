// Generated by protoc-gen-vala from plugin.proto, do not edit

public class CodeGeneratorRequest
{
    public List<string> file_to_generate;
    public string? parameter;
    public List<FileDescriptorProto> proto_file;

    public void decode (uint8[] buffer, size_t length, size_t offset = 0)
    {
        while (offset < length)
        {
            var key = Protobuf.decode_varint (buffer, length, ref offset);
            var wire_type = key & 0x7;
            var field_number = key >> 3;
            int varint;
            var value_length = Protobuf.get_value_length (wire_type, out varint, buffer, length, ref offset);
            // FIXME: Check remaining space

            switch (field_number)
            {
            case 1:
                file_to_generate.append (Protobuf.decode_string (buffer, value_length, offset));
                break;
            case 2:
                parameter = Protobuf.decode_string (buffer, value_length, offset);
                break;
            case 15:
                var f = new FileDescriptorProto ();
                f.decode (buffer, offset + value_length, offset);
                proto_file.append (f);
                break;
            }

            offset += value_length;
        }

        if (offset != length)
            stderr.printf ("Unused %zu octets on end of CodeGeneratorRequest\n", offset - length);
    }

    public size_t encode (uint8[] buffer, size_t offset)
    {
        if (proto_file != null)
        {
            // ...
            Protobuf.encode_varint (120, buffer, ref offset);
        }
        if (parameter != null)
        {
            // ...
            Protobuf.encode_varint (16, buffer, ref offset);
        }
        if (file_to_generate != null)
        {
            // ...
            Protobuf.encode_varint (8, buffer, ref offset);
        }

        return 0;
    }

    public string to_string ()
    {
        var text = "";

        if (file_to_generate != null)
        {
            text += "file_to_generate=[";
            foreach (var f in file_to_generate)
                text += "\"%s\" ".printf (f);
            text += "] ";
        }

        if (parameter != null)
            text += "parameter=\"%s\" ".printf (parameter);

        if (proto_file != null)
        {
            text += "proto_file=[";
            foreach (var f in proto_file)
                text += "{ %s } ".printf (f.to_string ());
            text += "] ";
        }

        return text;
    }
}

public class CodeGeneratorResponse
{
    public class File
    {
        public string? name;
        public string? insertion_point;
        public string? content;

        public void decode (uint8[] buffer, size_t length, size_t offset = 0)
        {
            while (offset < length)
            {
                var key = Protobuf.decode_varint (buffer, length, ref offset);
                var wire_type = key & 0x7;
                var field_number = key >> 3;
                int varint;
                var value_length = Protobuf.get_value_length (wire_type, out varint, buffer, length, ref offset);
                // FIXME: Check remaining space

                switch (field_number)
                {
                case 1:
                    break;
                case 2:
                    break;
                case 15:
                    break;
                }

                offset += value_length;
            }
        }

        public size_t encode (uint8[] buffer, size_t offset)
        {
            var start = offset;

            if (content != null)
            {
                Protobuf.encode_string (content, buffer, ref offset);
                Protobuf.encode_varint ((15 << 3) | 0x2, buffer, ref offset);
            }
            if (name != null)
            {
                Protobuf.encode_string (name, buffer, ref offset);
                Protobuf.encode_varint ((1 << 3) | 0x2, buffer, ref offset);
            }

            return start - offset;
        }
    }

    public string? error;
    public List<File> file;

    public void decode (uint8[] buffer, size_t length, size_t offset = 0)
    {
        while (offset < length)
        {
            var key = Protobuf.decode_varint (buffer, length, ref offset);
            var wire_type = key & 0x7;
            var field_number = key >> 3;
            int varint;
            var value_length = Protobuf.get_value_length (wire_type, out varint, buffer, length, ref offset);
            // FIXME: Check remaining space

            switch (field_number)
            {
            case 1:
                break;
            case 15:
                break;
            }

            offset += value_length;
        }
    }

    public size_t encode (uint8[] buffer, size_t offset)
    {
        var start = offset;

        // FIXME: Reverse the list
        foreach (var v in file)
        {
            var n_written = v.encode (buffer, offset);
            offset -= n_written;
            Protobuf.encode_varint ((int) n_written, buffer, ref offset);
            Protobuf.encode_varint ((15 << 3) | 0x2, buffer, ref offset);
        }
        if (error != null)
        {
            // ...
            Protobuf.encode_varint (8, buffer, ref offset);
        }

        return start - offset;
    }
}
