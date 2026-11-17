using Google.Protobuf;
using ValaPoet;

private class DurationHandler : WktHandler {
	public override string get_vala_type (FieldDescriptorProto field, bool full = true, bool is_explicit = false, bool is_required = false) {
		if (!full) return "GLib.TimeSpan";
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "List<GLib.TimeSpan?>";
		if (is_explicit || field.proto3_optional) return "GLib.TimeSpan?";
		return "GLib.TimeSpan";
	}

	public override string get_generic_type (FieldDescriptorProto field) {
		return "GLib.TimeSpan?";
	}

	public override string get_default_value (FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "new List<GLib.TimeSpan?> ()";
		if (is_explicit || field.proto3_optional) return "null";
		return "0";
	}

	public override string get_map_default_value (FieldDescriptorProto field) {
		return "(GLib.TimeSpan) 0";
	}

	public override void emit_decode_value (MethodSpec.Builder decode_method, FieldDescriptorProto field, string target_template) {
		decode_method.add_statement ("var dur_len = buffer.decode_length ()");
		decode_method.add_statement ("var dur_end = buffer.read_index + dur_len");
		decode_method.add_statement ("int64 dur_sec = 0");
		decode_method.add_statement ("int32 dur_nsec = 0");
		decode_method.begin_control_flow ("while (buffer.read_index < dur_end && !buffer.error)");
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
		decode_method.add_statement (target_template.replace ("{val}", "dur_sec * GLib.TimeSpan.SECOND + (dur_nsec / 1000)"));
	}

	public override void emit_encode_submessage (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string buf_var, string len_var) {
		encode_method.add_statement ("int64 dur_sec = %s / GLib.TimeSpan.SECOND".printf (val_expr));
		encode_method.add_statement ("int32 dur_nsec = (int32) ((%s %% GLib.TimeSpan.SECOND) * 1000)".printf (val_expr));
		encode_method.begin_control_flow ("if (dur_nsec != 0)");
		encode_method.add_statement ("%s += %s.encode_int32 (dur_nsec)".printf (len_var, buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (2 << 3) | 0));
		encode_method.end_control_flow ();
		encode_method.begin_control_flow ("if (dur_sec != 0)");
		encode_method.add_statement ("%s += %s.encode_int64 (dur_sec)".printf (len_var, buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
		encode_method.end_control_flow ();
	}

	public override void emit_encode_map_value (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string entry_buf_var, string entry_len_var) {
		encode_method.add_statement ("var dur_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t dur_len = 0");
		encode_method.add_statement ("GLib.TimeSpan dur_val = (%s != null) ? (GLib.TimeSpan) %s : 0".printf (val_expr, val_expr));
		emit_encode_submessage (encode_method, field, "dur_val", "dur_buf", "dur_len");
		encode_method.add_statement ("%s += %s.encode_raw_bytes (dur_buf.data)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (dur_len)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (entry_len_var, entry_buf_var, (2 << 3) | 2));
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			encode_method.begin_control_flow ("for (unowned List<GLib.TimeSpan?> dur_node = %s.last (); dur_node != null; dur_node = dur_node.prev)".printf (field_name));
			encode_method.add_statement ("var dur_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t dur_len = 0");
			encode_method.add_statement ("GLib.TimeSpan dur_val = (dur_node.data != null) ? (GLib.TimeSpan) dur_node.data : 0");
			emit_encode_submessage (encode_method, field, "dur_val", "dur_buf", "dur_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (dur_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (dur_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		} else if (is_explicit || field.proto3_optional) {
			encode_method.begin_control_flow ("if (%s != null)".printf (field_name));
			encode_method.add_statement ("var dur_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t dur_len = 0");
			encode_method.add_statement ("GLib.TimeSpan dur_val = (GLib.TimeSpan) %s".printf (field_name));
			emit_encode_submessage (encode_method, field, "dur_val", "dur_buf", "dur_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (dur_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (dur_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		} else if (is_required) {
			var buf_v = "dur_buf_%d".printf (field.number);
			var len_v = "dur_len_%d".printf (field.number);
			encode_method.add_statement ("var %s = new Google.Protobuf.EncodeBuffer ()".printf (buf_v));
			encode_method.add_statement ("size_t %s = 0".printf (len_v));
			emit_encode_submessage (encode_method, field, field_name, buf_v, len_v);
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (%s.data)".printf (buf_v));
			encode_method.add_statement ("n_written += buffer.encode_varint (%s)".printf (len_v));
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
		} else {
			encode_method.begin_control_flow ("if (%s != 0)".printf (field_name));
			encode_method.add_statement ("var dur_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t dur_len = 0");
			emit_encode_submessage (encode_method, field, field_name, "dur_buf", "dur_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (dur_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (dur_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		}
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			to_string_method.begin_control_flow ("foreach (unowned GLib.TimeSpan? dur_v in %s)".printf (field_name));
			to_string_method.add_statement ("GLib.TimeSpan dur_val = (dur_v != null) ? (GLib.TimeSpan) dur_v : 0");
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (dur_val.to_string ())".printf (field.name));
			to_string_method.end_control_flow ();
		} else if (is_explicit || field.proto3_optional) {
			to_string_method.begin_control_flow ("if (%s != null)".printf (field_name));
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (((GLib.TimeSpan) %s).to_string ())".printf (field.name, field_name));
			to_string_method.end_control_flow ();
		} else if (is_required) {
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (%s.to_string ())".printf (field.name, field_name));
		} else {
			to_string_method.begin_control_flow ("if (%s != 0)".printf (field_name));
			to_string_method.add_statement ("text += indent + \"%s: %%s\\n\".printf (%s.to_string ())".printf (field.name, field_name));
			to_string_method.end_control_flow ();
		}
	}

	public override void emit_map_value_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, string val_expr) {
		to_string_method.add_statement_raw ("text += indent + \"  value: %%s\\n\".printf (%s != null ? ((GLib.TimeSpan) %s).to_string () : \"0\")".printf (val_expr, val_expr));
	}
}
