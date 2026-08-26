using Google.Protobuf;
using ValaPoet;

private class FieldMaskHandler : WktHandler {
	public static bool is_field_mask_field (FieldDescriptorProto field) {
		if (field.type != FieldDescriptorProto.Type.TYPE_MESSAGE) return false;
		var name = field.type_name;
		if (name.has_prefix (".")) name = name.substring (1);
		return name == "google.protobuf.FieldMask";
	}

	public override string get_vala_type (FieldDescriptorProto field, bool full = true) {
		return "Gee.ArrayList<string>";
	}

	public override string get_default_value (FieldDescriptorProto field) {
		return "new Gee.ArrayList<string> ()";
	}

	public override void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first) {
		if (first) {
			decode_method.begin_control_flow ("if (field_number == %d && wire_type == 2)".printf (field.number));
		} else {
			decode_method.next_control_flow ("else if (field_number == %d && wire_type == 2)".printf (field.number));
		}

		var field_name = get_field_name (field);

		decode_method.add_statement ("var fm_len = (ssize_t) buffer.decode_varint ()");
		decode_method.add_statement ("var fm_end = buffer.read_index + fm_len");
		decode_method.begin_control_flow ("while (buffer.read_index < fm_end && !buffer.error)");
		decode_method.add_statement ("var fm_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var fm_num = fm_tag >> 3");
		decode_method.begin_control_flow ("if (fm_num == 1)");
		decode_method.add_statement ("this.%s.add (buffer.decode_string ((size_t) buffer.decode_varint ()))".printf (field_name));
		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (fm_tag))");
		decode_method.end_control_flow (); // end if
		decode_method.end_control_flow (); // end while

		decode_method.begin_control_flow ("if (buffer.read_index != fm_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();

		first = false;
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field) {
		var field_name = "this.%s".printf (get_field_name (field));

		encode_method.begin_control_flow ("if (%s != null && %s.size > 0)".printf (field_name, field_name));
		encode_method.add_statement ("var fm_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t fm_len = 0");
		encode_method.begin_control_flow ("for (var i = %s.size - 1; i >= 0; i--)".printf (field_name));
		encode_method.add_statement ("var path = %s.get (i)".printf (field_name));
		encode_method.add_statement ("var path_len = fm_buf.encode_string (path)");
		encode_method.add_statement ("fm_len += path_len");
		encode_method.add_statement ("fm_len += fm_buf.encode_varint (path_len)");
		encode_method.add_statement ("fm_len += fm_buf.encode_varint (%d)".printf ((1 << 3) | 2));
		encode_method.end_control_flow ();

		encode_method.add_statement ("n_written += buffer.encode_raw_bytes (fm_buf.data)");
		encode_method.add_statement ("n_written += buffer.encode_varint (fm_len)");
		encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
		encode_method.add_statement ("n_written += fm_len");
		encode_method.end_control_flow ();
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field) {
		var field_name = "this.%s".printf (get_field_name (field));

		to_string_method.begin_control_flow ("if (%s != null && %s.size > 0)".printf (field_name, field_name));
		to_string_method.add_statement ("var fm_str = \"\"");
		to_string_method.begin_control_flow ("foreach (var p in %s)".printf (field_name));
		to_string_method.begin_control_flow ("if (fm_str != \"\")");
		to_string_method.add_statement ("fm_str += \", \"");
		to_string_method.end_control_flow ();
		to_string_method.add_statement ("fm_str += p");
		to_string_method.end_control_flow ();
		to_string_method.add_statement_raw ("text += indent + \"%s { paths: [\\\"%%s\\\"] }\\n\".printf (fm_str)".printf (field.name));
		to_string_method.end_control_flow ();
	}
}
