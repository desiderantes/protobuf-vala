using Google.Protobuf;
using ValaPoet;

private class DurationHandler : WktHandler {
	public override string get_vala_type (FieldDescriptorProto field, bool full = true) {
		return "GLib.TimeSpan";
	}

	public override string get_default_value (FieldDescriptorProto field) {
		return "0";
	}

	public override void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first) {
		if (first) {
			decode_method.begin_control_flow ("if (field_number == %d && wire_type == 2)".printf (field.number));
		} else {
			decode_method.next_control_flow ("else if (field_number == %d && wire_type == 2)".printf (field.number));
		}
		decode_method.add_statement ("var dur_len = (ssize_t) buffer.decode_varint ()");
		decode_method.add_statement ("var dur_end = buffer.read_index + dur_len");
		decode_method.add_statement ("int64 dur_sec = 0");
		decode_method.add_statement ("int32 dur_nsec = 0");
		decode_method.begin_control_flow ("while (buffer.read_index < dur_end)");
		decode_method.add_statement ("var dur_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var dur_num = dur_tag >> 3");
		decode_method.begin_control_flow ("if (dur_num == 1)");
		decode_method.add_statement ("dur_sec = buffer.decode_int64 ()");
		decode_method.next_control_flow ("else if (dur_num == 2)");
		decode_method.add_statement ("dur_nsec = buffer.decode_int32 ()");
		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (dur_tag))");
		decode_method.end_control_flow ();
		decode_method.end_control_flow ();
		decode_method.begin_control_flow ("if (buffer.read_index != dur_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();
		decode_method.add_statement ("this.%s = dur_sec * GLib.TimeSpan.SECOND + (dur_nsec / 1000)".printf (get_field_name (field)));
		first = false;
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field) {
		encode_method.begin_control_flow ("if (this.%s != 0)".printf (get_field_name (field)));
		encode_method.add_statement ("var dur_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t dur_len = 0");
		encode_method.add_statement ("int64 dur_sec = this.%s / GLib.TimeSpan.SECOND".printf (get_field_name (field)));
		encode_method.add_statement ("int32 dur_nsec = (int32) ((this.%s %% GLib.TimeSpan.SECOND) * 1000)".printf (get_field_name (field)));
		encode_method.begin_control_flow ("if (dur_nsec != 0)");
		encode_method.add_statement ("dur_len += dur_buf.encode_int32 (dur_nsec)");
		encode_method.add_statement ("dur_len += dur_buf.encode_varint (%d)".printf ((2 << 3) | 0));
		encode_method.end_control_flow ();
		encode_method.begin_control_flow ("if (dur_sec != 0)");
		encode_method.add_statement ("dur_len += dur_buf.encode_int64 (dur_sec)");
		encode_method.add_statement ("dur_len += dur_buf.encode_varint (%d)".printf ((1 << 3) | 0));
		encode_method.end_control_flow ();
		encode_method.add_statement ("n_written += buffer.encode_raw_bytes (dur_buf.data)");
		encode_method.add_statement ("n_written += buffer.encode_varint (dur_len)");
		encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
		encode_method.add_statement ("n_written += dur_len");
		encode_method.end_control_flow ();
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field) {
		to_string_method.begin_control_flow ("if (this.%s != 0)".printf (get_field_name (field)));
		to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (this.%s.to_string ())".printf (field.name, get_field_name (field)));
		to_string_method.end_control_flow ();
	}
}
