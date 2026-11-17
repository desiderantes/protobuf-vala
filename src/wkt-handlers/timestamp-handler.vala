using Google.Protobuf;
using ValaPoet;

private class TimestampHandler : WktHandler {
	public override string get_vala_type (FieldDescriptorProto field, bool full = true, bool is_explicit = false, bool is_required = false) {
		if (!full) return "GLib.DateTime";
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "List<GLib.DateTime>";
		return "GLib.DateTime?";
	}

	public override string get_generic_type (FieldDescriptorProto field) {
		return "GLib.DateTime";
	}

	public override string get_default_value (FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "new List<GLib.DateTime> ()";
		return "null";
	}

	public override string get_map_default_value (FieldDescriptorProto field) {
		return "new GLib.DateTime.from_unix_utc (0)";
	}

	public override void emit_decode_value (MethodSpec.Builder decode_method, FieldDescriptorProto field, string target_template) {
		decode_method.add_statement ("var ts_len = buffer.decode_length ()");
		decode_method.add_statement ("var ts_end = buffer.read_index + ts_len");
		decode_method.add_statement ("int64 ts_sec = 0");
		decode_method.add_statement ("int32 ts_nsec = 0");
		decode_method.begin_control_flow ("while (buffer.read_index < ts_end && !buffer.error)");
		decode_method.add_statement ("var ts_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var ts_num = ts_tag >> 3");
		decode_method.begin_control_flow ("if (ts_num == 1)");
		decode_method.add_statement ("ts_sec = buffer.decode_int64 ()");
		decode_method.next_control_flow ("else if (ts_num == 2)");
		decode_method.add_statement ("ts_nsec = buffer.decode_int32 ()");
		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (ts_tag))");
		decode_method.end_control_flow ();
		decode_method.end_control_flow ();
		decode_method.begin_control_flow ("if (buffer.read_index != ts_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();
		decode_method.add_statement (target_template.replace ("{val}", "new GLib.DateTime.from_unix_utc (ts_sec).add_full (0, 0, 0, 0, 0, ts_nsec / 1000000000.0)"));
	}

	public override void emit_encode_submessage (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string buf_var, string len_var) {
		encode_method.begin_control_flow ("if (%s != null)".printf (val_expr));
		encode_method.add_statement ("int64 ts_sec = %s.to_unix ()".printf (val_expr));
		encode_method.add_statement ("int32 ts_nsec = (int32) (%s.get_microsecond () * 1000)".printf (val_expr));
		encode_method.begin_control_flow ("if (ts_nsec != 0)");
		encode_method.add_statement ("%s += %s.encode_int32 (ts_nsec)".printf (len_var, buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (2 << 3) | 0));
		encode_method.end_control_flow ();
		encode_method.begin_control_flow ("if (ts_sec != 0)");
		encode_method.add_statement ("%s += %s.encode_int64 (ts_sec)".printf (len_var, buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
		encode_method.end_control_flow ();
		encode_method.end_control_flow ();
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			encode_method.begin_control_flow ("for (unowned List<GLib.DateTime> ts_node = %s.last (); ts_node != null; ts_node = ts_node.prev)".printf (field_name));
			encode_method.add_statement ("var ts_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t ts_len = 0");
			emit_encode_submessage (encode_method, field, "ts_node.data", "ts_buf", "ts_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (ts_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (ts_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		} else {
			encode_method.begin_control_flow ("if (%s != null)".printf (field_name));
			encode_method.add_statement ("var ts_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t ts_len = 0");
			emit_encode_submessage (encode_method, field, field_name, "ts_buf", "ts_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (ts_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (ts_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		}
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			to_string_method.begin_control_flow ("foreach (unowned GLib.DateTime ts_v in %s)".printf (field_name));
			to_string_method.begin_control_flow ("if (ts_v != null)");
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (ts_v.to_string ())".printf (field.name));
			to_string_method.end_control_flow ();
			to_string_method.end_control_flow ();
		} else {
			to_string_method.begin_control_flow ("if (%s != null)".printf (field_name));
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (%s.to_string ())".printf (field.name, field_name));
			to_string_method.end_control_flow ();
		}
	}

	public override void emit_map_value_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, string val_expr) {
		to_string_method.add_statement_raw ("text += indent + \"  value: %%s\\n\".printf (%s != null ? %s.to_string () : \"\")".printf (val_expr, val_expr));
	}
}
