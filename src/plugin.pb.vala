// Generated by protoc-gen-vala 0.0.1 from plugin.proto, do not edit

public class CodeGeneratorRequest
{
    public List<string> file_to_generate;
    public string? parameter;
    public List<FileDescriptorProto> proto_file;

    public CodeGeneratorRequest.from_data (uint8[] buffer, size_t length, size_t offset = 0)
    {
        decode (buffer, length, offset);
    }

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
                this.file_to_generate.append (Protobuf.decode_string (buffer, offset + value_length, offset));
                break;
            case 2:
                this.parameter = Protobuf.decode_string (buffer, offset + value_length, offset);
                break;
            case 15:
                this.proto_file.append (new FileDescriptorProto.from_data (buffer, offset + value_length, offset));
                break;
            }

            offset += value_length;
        }
    }

    public size_t encode (Protobuf.EncodeBuffer buffer)
    {
        var start = buffer.write_index;

        for (unowned List<FileDescriptorProto> i = this.proto_file.last (); i != null; i = i.prev)
        {
            var proto_file_length = i.data.encode (buffer);
            buffer.encode_varint (proto_file_length);
            buffer.encode_varint (122);
        }
        if (this.parameter != null)
        {
            var parameter_length = buffer.encode_string (this.parameter);
            buffer.encode_varint (parameter_length);
            buffer.encode_varint (18);
        }
        for (unowned List<string> i = this.file_to_generate.last (); i != null; i = i.prev)
        {
            var file_to_generate_length = buffer.encode_string (i.data);
            buffer.encode_varint (file_to_generate_length);
            buffer.encode_varint (10);
        }

        return start - buffer.write_index;
    }

    public string to_string (string indent = "")
    {
        var text = "{\n";

        if (this.file_to_generate != null)
        {
            text += "file_to_generate = ";
            foreach (unowned string v in this.file_to_generate)
                text += "\"%s\";\n".printf (v);
        }

        if (this.parameter != null)
        {
            text += "parameter = ";
            text += "\"%s\";\n".printf (this.parameter);
        }

        if (this.proto_file != null)
        {
            text += "proto_file = ";
            foreach (unowned FileDescriptorProto v in this.proto_file)
                text += "%s;\n".printf (v.to_string ());
        }

        text += "}";
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

        public File.from_data (uint8[] buffer, size_t length, size_t offset = 0)
        {
            decode (buffer, length, offset);
        }

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
                    this.name = Protobuf.decode_string (buffer, offset + value_length, offset);
                    break;
                case 2:
                    this.insertion_point = Protobuf.decode_string (buffer, offset + value_length, offset);
                    break;
                case 15:
                    this.content = Protobuf.decode_string (buffer, offset + value_length, offset);
                    break;
                }

                offset += value_length;
            }
        }

        public size_t encode (Protobuf.EncodeBuffer buffer)
        {
            var start = buffer.write_index;

            if (this.content != null)
            {
                var content_length = buffer.encode_string (this.content);
                buffer.encode_varint (content_length);
                buffer.encode_varint (122);
            }
            if (this.insertion_point != null)
            {
                var insertion_point_length = buffer.encode_string (this.insertion_point);
                buffer.encode_varint (insertion_point_length);
                buffer.encode_varint (18);
            }
            if (this.name != null)
            {
                var name_length = buffer.encode_string (this.name);
                buffer.encode_varint (name_length);
                buffer.encode_varint (10);
            }

            return start - buffer.write_index;
        }

        public string to_string (string indent = "")
        {
            var text = "{\n";

            if (this.name != null)
            {
                text += "name = ";
                text += "\"%s\";\n".printf (this.name);
            }

            if (this.insertion_point != null)
            {
                text += "insertion_point = ";
                text += "\"%s\";\n".printf (this.insertion_point);
            }

            if (this.content != null)
            {
                text += "content = ";
                text += "\"%s\";\n".printf (this.content);
            }

            text += "}";
            return text;
        }
    }
    public string? error;
    public List<File> file;

    public CodeGeneratorResponse.from_data (uint8[] buffer, size_t length, size_t offset = 0)
    {
        decode (buffer, length, offset);
    }

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
                this.error = Protobuf.decode_string (buffer, offset + value_length, offset);
                break;
            case 15:
                this.file.append (new File.from_data (buffer, offset + value_length, offset));
                break;
            }

            offset += value_length;
        }
    }

    public size_t encode (Protobuf.EncodeBuffer buffer)
    {
        var start = buffer.write_index;

        for (unowned List<File> i = this.file.last (); i != null; i = i.prev)
        {
            var file_length = i.data.encode (buffer);
            buffer.encode_varint (file_length);
            buffer.encode_varint (122);
        }
        if (this.error != null)
        {
            var error_length = buffer.encode_string (this.error);
            buffer.encode_varint (error_length);
            buffer.encode_varint (10);
        }

        return start - buffer.write_index;
    }

    public string to_string (string indent = "")
    {
        var text = "{\n";

        if (this.error != null)
        {
            text += "error = ";
            text += "\"%s\";\n".printf (this.error);
        }

        if (this.file != null)
        {
            text += "file = ";
            foreach (unowned File v in this.file)
                text += "%s;\n".printf (v.to_string ());
        }

        text += "}";
        return text;
    }
}
