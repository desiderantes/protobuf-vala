using Google.Protobuf;

private HashTable<string, EnumDescriptorProto> enums;

public static int main (string[] args) {
	var data = new uint8[0];
	while (true) {
		uint8 buffer[65535];
		var n_read = stdin.read (buffer);
		if (n_read < 0)
			return Posix.EXIT_FAILURE;
		if (n_read == 0)
			break;

		var n_used = data.length;
		data.resize (n_used + (int) n_read);
		for (var i = 0; i < n_read; i++)
			data[n_used + i] = buffer[i];
	}

	var buf = new DecodeBuffer (data);
	var req = new Compiler.CodeGeneratorRequest ();
	req.decode (buf);

	// stderr.printf ("request = {\n%s}\n", req.to_string ("  "));

	var resp = new Compiler.CodeGeneratorResponse ();

	enums = new HashTable<string, EnumDescriptorProto> (str_hash, str_equal);
	foreach (var f in req.proto_file) {
		var out_file = new Compiler.CodeGeneratorResponse.File ();

		if (f.name.has_suffix (".proto"))
			out_file.name = f.name.substring (0, f.name.length - 6) + ".pb.vala";
		else
			out_file.name = f.name + ".vala";

		/* Generate valid namespace */
		var vala_namespace = "";
		if (f.package != "")
			vala_namespace = get_namespace (f.package);

		out_file.content = "// Generated by protoc-gen-vala %s from %s, do not edit\n".printf (BuildConstants.VERSION, f.name);
		if (vala_namespace != "") {
			out_file.content += "\n";
			out_file.content += "namespace %s {\n".printf (vala_namespace);
		}
		foreach (var enum_type in f.enum_type) {
			var type_name = "%s.%s".printf (f.package, enum_type.name);
			enums.insert (type_name, enum_type);
			out_file.content += "\n";
			out_file.content += write_enum (enum_type);
		}
		foreach (var message_type in f.message_type) {
			out_file.content += "\n";
			out_file.content += write_class (message_type);
		}
		if (vala_namespace != "") {
			out_file.content += "\n";
			out_file.content += "}\n";
		}

		resp.file.append (out_file);
	}

	var resp_buf = new EncodeBuffer ();
	resp.encode (resp_buf);

	stdout.write (resp_buf.data);
	stdout.flush ();

	return Posix.EXIT_SUCCESS;
}

private static string write_enum (EnumDescriptorProto type, string indent = "") {
	var text = "";

	text += indent + "public enum %s {\n".printf (type.name);
	foreach (var value in type.value)
		text += indent + "    %s = %d,\n".printf (value.name, value.number);
	text += indent + "}\n";
	text += indent + "public static string %s_to_string (%s value) {\n".printf (type.name, type.name);
	text += indent + "    switch (value) {\n";
	foreach (var value in type.value) {
		text += indent + "    case %s.%s:\n".printf (type.name, value.name);
		text += indent + "        return \"%s\";\n".printf (value.name);
	}
	text += indent + "    default:\n";
	text += indent + "        return \"%d\".printf (value);\n";
	text += indent + "    }\n";
	text += indent + "}\n";

	return text;
}

private static string write_class (DescriptorProto type, string indent = "") {
	var text = "";
	text += indent + "public class %s : Google.Protobuf.Message {\n".printf (type.name);
	foreach (var enum_type in type.enum_type)
		text += write_enum (enum_type, indent + "    ");
	foreach (var nested_type in type.nested_type)
		text += write_class (nested_type, indent + "    ");
	foreach (var field in type.field)
		text += indent + "    public %s %s;\n".printf (get_type_name (field), get_field_name (field));
	text += "\n";
	text += indent + "    public %s () {\n".printf (type.name);
	foreach (var field in type.field)
		text += indent + "        this.%s = %s;\n".printf (get_field_name (field), get_default_value (field));
	text += indent + "    }\n";
	text += "\n";
	text += indent + "    public %s.from_data (Google.Protobuf.DecodeBuffer buffer, ssize_t data_length = -1) {\n".printf (type.name);
	text += indent + "        decode (buffer, data_length);\n";
	text += indent + "    }\n";
	text += "\n";
	text += indent + "    public override bool decode (Google.Protobuf.DecodeBuffer buffer, ssize_t data_length = -1) {\n";
	text += indent + "        size_t end;\n";
	text += indent + "        if (data_length < 0)\n";
	text += indent + "            end = buffer.buffer.length;\n";
	text += indent + "        else\n";
	text += indent + "            end = buffer.read_index + data_length;\n";
	var required_field_check = "";
	foreach (var field in type.field) {
		if (field.label != FieldDescriptorProto.Label.LABEL_REQUIRED)
			continue;
		text += indent + "        var have_%s = false;\n".printf (field.name);
		if (required_field_check != "")
			required_field_check += " || ";
		required_field_check += "!have_%s".printf (field.name);
	}
	text += "\n";
	foreach (var field in type.field)
		text += indent + "        this.%s = %s;\n".printf (get_field_name (field), get_default_value (field));
	text += indent + "        while (buffer.read_index < end) {\n";
	text += indent + "            var key = buffer.decode_varint ();\n";
	text += indent + "            var wire_type = key & 0x7;\n";
	text += indent + "            var field_number = key >> 3;\n";
	text += "\n";
	var first = true;
	foreach (var field in type.field) {
		var decode_method = "";
		var wire_type = 0;
		switch (field.type) {
		case FieldDescriptorProto.Type.TYPE_DOUBLE:
			wire_type = 1;
			decode_method = "buffer.decode_double ()";
			break;
		case FieldDescriptorProto.Type.TYPE_FLOAT:
			wire_type = 5;
			decode_method = "buffer.decode_float ()";
			break;
		case FieldDescriptorProto.Type.TYPE_INT64:
			wire_type = 0;
			decode_method = "buffer.decode_int64 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_UINT64:
			wire_type = 0;
			decode_method = "buffer.decode_uint64 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_INT32:
			wire_type = 0;
			decode_method = "buffer.decode_int32 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_FIXED64:
			wire_type = 1;
			decode_method = "buffer.decode_fixed64 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_FIXED32:
			wire_type = 5;
			decode_method = "buffer.decode_fixed32 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_BOOL:
			wire_type = 0;
			decode_method = "buffer.decode_bool ()";
			break;
		case FieldDescriptorProto.Type.TYPE_STRING:
			wire_type = 2;
			decode_method = "buffer.decode_string ((size_t) buffer.decode_varint ())";
			break;
		case FieldDescriptorProto.Type.TYPE_BYTES:
			wire_type = 2;
			decode_method = "buffer.decode_bytes ((size_t) buffer.decode_varint ())";
			break;
		case FieldDescriptorProto.Type.TYPE_MESSAGE:
			wire_type = 2;
			decode_method = "new %s.from_data (buffer, (ssize_t) buffer.decode_varint ())".printf (get_type_name (field, false));
			break;
		case FieldDescriptorProto.Type.TYPE_ENUM:
			wire_type = 0;
			decode_method = "(%s) buffer.decode_varint ()".printf (get_type_name (field, false));
			break;
		case FieldDescriptorProto.Type.TYPE_UINT32:
			wire_type = 0;
			decode_method = "buffer.decode_uint32 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_SFIXED32:
			wire_type = 5;
			decode_method = "buffer.decode_sfixed32 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_SFIXED64:
			wire_type = 1;
			decode_method = "buffer.decode_sfixed64 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_SINT32:
			wire_type = 0;
			decode_method = "buffer.decode_sint32 ()";
			break;
		case FieldDescriptorProto.Type.TYPE_SINT64:
			wire_type = 0;
			decode_method = "buffer.decode_sint64 ()";
			break;
		default:
			// FIXME: Exit with error
			decode_method = "buffer.DECODE_UNKNOWN_TYPE%d ()".printf (field.type);
			break;
		}

		var packed = field.options != null && field.options.packed;
		if (packed)
			wire_type = 2;

		text += indent + "            %s (field_number == %d && wire_type == %d) {\n".printf (first ? "if" : "else if", field.number, wire_type);
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			if (packed) {
				text += indent + "                var %s_length = buffer.decode_varint ();\n".printf (field.name);
				text += indent + "                var %s_end = buffer.read_index + %s_length;\n".printf (field.name, field.name);
				text += indent + "                while (buffer.read_index < %s_end)\n".printf (field.name);
				text += indent + "                    this.%s.append (%s);\n".printf (get_field_name (field), decode_method);
				text += indent + "                if (buffer.read_index != %s_end)\n".printf (field.name);
				text += indent + "                    buffer.error = true;\n";
			} else
				text += indent + "                this.%s.append (%s);\n".printf (get_field_name (field), decode_method);
		} else if (field.label == FieldDescriptorProto.Label.LABEL_REQUIRED) {
			text += indent + "                this.%s = %s;\n".printf (get_field_name (field), decode_method);
			text += indent + "                have_%s = true;\n".printf (field.name);
		} else
			text += indent + "                this.%s = %s;\n".printf (get_field_name (field), decode_method);
		text += indent + "            }\n";

		first = false;
	}
	text += indent + "            else\n";
	text += indent + "                this.unknown_fields.prepend (buffer.decode_unknown_field (key));\n";
	text += indent + "        }\n";
	text += "\n";
	text += indent + "        if (buffer.read_index != end)\n";
	text += indent + "            buffer.error = true;\n";
	if (required_field_check != "") {
		text += indent + "        else if (%s)\n".printf (required_field_check);
		text += indent + "            buffer.error = true;\n";
	}
	text += "\n";
	text += indent + "        return !buffer.error;\n";
	text += indent + "    }\n";
	text += "\n";
	text += indent + "    public override size_t encode (Google.Protobuf.EncodeBuffer buffer) {\n";
	text += indent + "        size_t n_written = 0;\n";
	text += "\n";
	text += indent + "        foreach (var f in this.unknown_fields)\n";
	text += indent + "            n_written += buffer.encode_unknown_field (f);\n";
	for (unowned List<FieldDescriptorProto> i = type.field.last (); i != null; i = i.prev) {
		var field = i.data;
		var packed = field.options != null && field.options.packed;
		var indent2 = indent;
		var field_name = "this.%s".printf (get_field_name (field));
		if (field.label == FieldDescriptorProto.Label.LABEL_OPTIONAL) {
			text += indent + "        if (%s != %s) {\n".printf (field_name, get_default_value (field));
			indent2 += "    ";
		} else if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			if (packed)
				text += indent + "        size_t %s_length = 0;\n".printf (field.name);
			text += indent + "        for (unowned %s i = %s.last (); i != null; i = i.prev) {\n".printf (get_type_name (field), field_name);
			indent2 += "    ";
			field_name = "i.data";
		}

		var encode_length = false;
		switch (field.type) {
			case FieldDescriptorProto.Type.TYPE_STRING:
			case FieldDescriptorProto.Type.TYPE_BYTES:
			case FieldDescriptorProto.Type.TYPE_MESSAGE:
				encode_length = true;
				break;
		}

		text += indent2 + "        ";
		if (encode_length)
			text += "var %s_length = ".printf (field.name);
		else if (packed)
			text += "%s_length += ".printf (field.name);
		else
			text += "n_written += ";
		var wire_type = 0;
		switch (field.type) {
		case FieldDescriptorProto.Type.TYPE_DOUBLE:
			text += "buffer.encode_double (%s);\n".printf (field_name);
			wire_type = 1;
			break;
		case FieldDescriptorProto.Type.TYPE_FLOAT:
			text += "buffer.encode_float (%s);\n".printf (field_name);
			wire_type = 5;
			break;
		case FieldDescriptorProto.Type.TYPE_INT64:
			text += "buffer.encode_int64 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_UINT64:
			text += "buffer.encode_uint64 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_INT32:
			text += "buffer.encode_int32 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_FIXED64:
			text += "buffer.encode_fixed64 (%s);\n".printf (field_name);
			wire_type = 1;
			break;
		case FieldDescriptorProto.Type.TYPE_FIXED32:
			text += "buffer.encode_fixed32 (%s);\n".printf (field_name);
			wire_type = 5;
			break;
		case FieldDescriptorProto.Type.TYPE_BOOL:
			text += "buffer.encode_bool (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_STRING:
			text += "buffer.encode_string (%s);\n".printf (field_name);
			wire_type = 2;
			break;
		case FieldDescriptorProto.Type.TYPE_BYTES:
			text += "buffer.encode_bytes (%s);\n".printf (field_name);
			wire_type = 2;
			break;
		case FieldDescriptorProto.Type.TYPE_UINT32:
			text += "buffer.encode_uint32 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_SFIXED64:
			text += "buffer.encode_sfixed64 (%s);\n".printf (field_name);
			wire_type = 1;
			break;
		case FieldDescriptorProto.Type.TYPE_SFIXED32:
			text += "buffer.encode_sfixed32 (%s);\n".printf (field_name);
			wire_type = 5;
			break;
		case FieldDescriptorProto.Type.TYPE_SINT64:
			text += "buffer.encode_sint64 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_SINT32:
			text += "buffer.encode_sint32 (%s);\n".printf (field_name);
			break;
		case FieldDescriptorProto.Type.TYPE_MESSAGE:
			text += "%s.encode (buffer);\n".printf (field_name);
			wire_type = 2;
			break;
		case FieldDescriptorProto.Type.TYPE_ENUM:
			text += "buffer.encode_varint (%s);\n".printf (field_name);
			break;
		default:
			text += "ENCODE_UNKNOWN_TYPE%d (%s);\n".printf (field.type, field_name);
			break;
		}
		if (encode_length) {
			text += indent2 + "        n_written += %s_length;\n".printf (field.name);
			text += indent2 + "        n_written += buffer.encode_varint (%s_length);\n".printf (field.name);
		}

		/* Encode key */
		if (!packed) {
			var n = (field.number << 3) | wire_type;
			text += indent2 + "        n_written += buffer.encode_varint (%d);\n".printf (n);
		}

		if (field.label == FieldDescriptorProto.Label.LABEL_OPTIONAL || field.label == FieldDescriptorProto.Label.LABEL_REPEATED)
			text += indent + "        }\n";

		if (packed) {
			var n = (field.number << 3) | 2;
			text += indent2 + "    if (%s_length != 0) {\n".printf (field.name);
			text += indent2 + "        n_written += %s_length;\n".printf (field.name);
			text += indent2 + "        n_written += buffer.encode_varint (%s_length);\n".printf (field.name);
			text += indent2 + "        n_written += buffer.encode_varint (%d);\n".printf (n);
			text += indent2 + "    }\n";
		}
	}
	text += "\n";
	text += indent + "        return n_written;\n";
	text += indent + "    }\n";
	text += "\n";
	text += indent + "    public override string to_string (string indent = \"\") {\n";
	text += indent + "        var text = \"\";\n";
	text += "\n";
	foreach (var field in type.field) {
		var field_name = "this.%s".printf (get_field_name (field));
		var indent2 = indent;
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			text += indent + "        foreach (unowned %s v in %s) {\n".printf (get_type_name (field, false), field_name);
			indent2 += "    ";
			field_name = "v";
		} else if (field.type == FieldDescriptorProto.Type.TYPE_MESSAGE) {
			text += indent + "        if (%s != null) {\n".printf (field.name);
			indent2 += "    ";
		}

		if (field.type == FieldDescriptorProto.Type.TYPE_MESSAGE) {
			text += indent2 + "        text += indent + \"%s {\\n\";\n".printf (field.name);
			text += indent2 + "        text += \"%%s\".printf (%s);\n".printf (get_to_string_method (field, field_name, "  "));
			text += indent2 + "        text += indent + \"}\\n\";\n";
		} else
			text += indent2 + "        text += indent + \"%s: %%s\\n\".printf (%s);\n".printf (field.name, get_to_string_method (field, field_name));

		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED || field.type == FieldDescriptorProto.Type.TYPE_MESSAGE)
			text += indent + "        }\n";
	}
	text += "\n";
	text += indent + "        return text;\n";
	text += indent + "    }\n";
	text += indent + "}\n";

	return text;
}

private static string get_namespace (string package) {
	int index = 0;
	unichar c;
	var ns = new StringBuilder.sized (package.length);
	var section_start = true;
	while (package.get_next_char (ref index, out c)) {
		if (section_start) {
			/* Ignore leading '.' */
			if (c == '.')
				continue;

			c = c.toupper ();
			section_start = false;
		}
		ns.append_unichar (c);
		if (c == '.')
			section_start = true;
	}

	return ns.str;
}

private static string get_type_name (FieldDescriptorProto field, bool full = true) {
	var type_name = "";
	var needs_box = false;
	var nullable = false;
	switch (field.type) {
	case FieldDescriptorProto.Type.TYPE_DOUBLE:
		type_name = "double";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_FLOAT:
		type_name = "float";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_INT64:
		type_name = "int64";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_UINT64:
		type_name = "uint64";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_INT32:
		type_name = "int32";
		break;
	case FieldDescriptorProto.Type.TYPE_FIXED64:
		type_name = "uint64";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_FIXED32:
		type_name = "uint32";
		break;
	case FieldDescriptorProto.Type.TYPE_BOOL:
		type_name = "bool";
		break;
	case FieldDescriptorProto.Type.TYPE_STRING:
		type_name = "string";
		break;
	case FieldDescriptorProto.Type.TYPE_BYTES:
		type_name = "GLib.ByteArray";
		break;
	case FieldDescriptorProto.Type.TYPE_UINT32:
		type_name = "uint32";
		break;
	case FieldDescriptorProto.Type.TYPE_SFIXED32:
		type_name = "int32";
		break;
	case FieldDescriptorProto.Type.TYPE_SFIXED64:
		type_name = "int64";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_SINT32:
		type_name = "int32";
		break;
	case FieldDescriptorProto.Type.TYPE_SINT64:
		type_name = "int64";
		needs_box = true;
		break;
	case FieldDescriptorProto.Type.TYPE_MESSAGE:
		type_name = get_namespace (field.type_name);
		nullable = true;
		break;
	case FieldDescriptorProto.Type.TYPE_ENUM:
		type_name = get_namespace (field.type_name);
		break;
	default:
		type_name = "UNKNOWN_TYPE%d".printf (field.type);
		break;
	}

	if (!full)
		return type_name;

	switch (field.label) {
	case FieldDescriptorProto.Label.LABEL_REPEATED:
		if (needs_box)
			return "List<%s?>".printf (type_name);
		else
			return "List<%s>".printf (type_name);
	case FieldDescriptorProto.Label.LABEL_OPTIONAL:
		if (nullable)
			return "%s?".printf (type_name);
		else
			return type_name;
	default:
	case FieldDescriptorProto.Label.LABEL_REQUIRED:
		return type_name;
	}
}

private static string get_field_name (FieldDescriptorProto field) {
	string[] reserved_names = { "dynamic", "owned", "unowned", "weak" };

	string[] c_reserved_names =
	{
		"break",
		"case",
		"const",
		"continue",
		"default",
		"do",
		"else",
		"enum",
		"extern",
		"for",
		"if",
		"inline",
		"return",
		"sizeof",
		"static",
		"struct",
		"switch",
		"typeof",
		"void",
		"while"
	};

	foreach (var n in reserved_names)
		if (field.name == n)
			return "@%s".printf (field.name);
	foreach (var n in c_reserved_names)
		if (field.name == n)
			return "%s_".printf (field.name);

	return field.name;
}

private static string get_default_value (FieldDescriptorProto field) {
	if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED)
		return "new %s ()".printf (get_type_name (field));

	switch (field.type) {
	case FieldDescriptorProto.Type.TYPE_DOUBLE:
		return "0d";
	case FieldDescriptorProto.Type.TYPE_FLOAT:
		return "0f";
	case FieldDescriptorProto.Type.TYPE_INT64:
	case FieldDescriptorProto.Type.TYPE_SINT64:
	case FieldDescriptorProto.Type.TYPE_UINT64:
	case FieldDescriptorProto.Type.TYPE_FIXED64:
	case FieldDescriptorProto.Type.TYPE_SFIXED64:
	case FieldDescriptorProto.Type.TYPE_INT32:
	case FieldDescriptorProto.Type.TYPE_SINT32:
	case FieldDescriptorProto.Type.TYPE_UINT32:
	case FieldDescriptorProto.Type.TYPE_FIXED32:
	case FieldDescriptorProto.Type.TYPE_SFIXED32:
		if (field.default_value != "")
			return field.default_value;
		else
			return "0";
	case FieldDescriptorProto.Type.TYPE_BOOL:
		if (field.default_value != "")
			return field.default_value;
		else
			return "false";
	case FieldDescriptorProto.Type.TYPE_STRING:
		if (field.default_value != "") {
			var value = field.default_value;
			value = value.replace ("\\", "\\\\");
			value = value.replace ("\"", "\\\"");
			return "\"%s\"".printf (value);
		} else
			return "\"\"";
	case FieldDescriptorProto.Type.TYPE_BYTES:
		return "null";
	case FieldDescriptorProto.Type.TYPE_MESSAGE:
		if (field.label == FieldDescriptorProto.Label.LABEL_OPTIONAL)
			return "null";
		else
			return "new %s ()".printf (get_type_name (field));
	case FieldDescriptorProto.Type.TYPE_ENUM:
		var type_name = get_type_name (field, false);
		var enum_type = enums.lookup (field.type_name);
		if (field.default_value != "")
			return "%s.%s".printf (type_name, field.default_value);
		else if (enum_type != null && enum_type.value.length () > 0)
			return "%s.%s".printf (type_name, enum_type.value.nth_data (0).name);
		else
			return "0";             // FIXME
	default:
		return "UNKNOWN_TYPE%d".printf (field.type);
	}
}

private static string get_to_string_method (FieldDescriptorProto field, string field_name, string indent = "") {
	switch (field.type) {
	case FieldDescriptorProto.Type.TYPE_STRING:
		return "Google.Protobuf.string_to_string (%s)".printf (field_name);
	case FieldDescriptorProto.Type.TYPE_BYTES:
		return "Google.Protobuf.bytes_to_string (%s)".printf (field_name);
	case FieldDescriptorProto.Type.TYPE_MESSAGE:
		return "%s.to_string (indent + \"%s\")".printf (field_name, indent);
	case FieldDescriptorProto.Type.TYPE_ENUM:
		var type_name = get_type_name (field, false);
		return "%s_to_string (%s)".printf (type_name, field_name);
	default:
		return "%s.to_string ()".printf (field_name);
	}
}

