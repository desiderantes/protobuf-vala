using Google.Protobuf;
using ValaPoet;

private class WrapperHandler : WktHandler {
	public static bool is_wrapper_field (FieldDescriptorProto field) {
		if (field.type != FieldDescriptorProto.Type.TYPE_MESSAGE) return false;
		var name = field.type_name;
		if (name.has_prefix (".")) name = name.substring (1);
		return name == "google.protobuf.DoubleValue" ||
		       name == "google.protobuf.FloatValue" ||
		       name == "google.protobuf.Int64Value" ||
		       name == "google.protobuf.UInt64Value" ||
		       name == "google.protobuf.Int32Value" ||
		       name == "google.protobuf.UInt32Value" ||
		       name == "google.protobuf.BoolValue" ||
		       name == "google.protobuf.StringValue" ||
		       name == "google.protobuf.BytesValue";
	}

	private static string get_wrapper_name (FieldDescriptorProto field) {
		var name = field.type_name;
		if (name.has_prefix (".")) name = name.substring (1);
		return name;
	}

	private static bool needs_box (string name) {
		return name == "google.protobuf.DoubleValue" ||
		       name == "google.protobuf.FloatValue" ||
		       name == "google.protobuf.Int64Value" ||
		       name == "google.protobuf.UInt64Value";
	}

	public override string get_vala_type (FieldDescriptorProto field, bool full = true, bool is_explicit = false, bool is_required = false) {
		var name = get_wrapper_name (field);
		string base_type;
		switch (name) {
			case "google.protobuf.DoubleValue": base_type = "double"; break;
			case "google.protobuf.FloatValue": base_type = "float"; break;
			case "google.protobuf.Int64Value": base_type = "int64"; break;
			case "google.protobuf.UInt64Value": base_type = "uint64"; break;
			case "google.protobuf.Int32Value": base_type = "int32"; break;
			case "google.protobuf.UInt32Value": base_type = "uint32"; break;
			case "google.protobuf.BoolValue": base_type = "bool"; break;
			case "google.protobuf.StringValue": base_type = "string"; break;
			case "google.protobuf.BytesValue": base_type = "GLib.ByteArray"; break;
			default: base_type = "string"; break;
		}
		if (!full) return base_type;
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			return "List<%s>".printf (needs_box (name) ? base_type + "?" : base_type);
		}
		return base_type + "?";
	}

	public override string get_generic_type (FieldDescriptorProto field) {
		var name = get_wrapper_name (field);
		var base_type = get_vala_type (field, false);
		return needs_box (name) ? base_type + "?" : base_type;
	}

	public override string get_default_value (FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			return "new List<%s> ()".printf (get_generic_type (field));
		}
		return "null";
	}

	public override string get_map_default_value (FieldDescriptorProto field) {
		return get_zero_value (get_wrapper_name (field));
	}

	private static string get_zero_value (string name) {
		switch (name) {
			case "google.protobuf.DoubleValue": return "0d";
			case "google.protobuf.FloatValue": return "0f";
			case "google.protobuf.Int64Value":
			case "google.protobuf.UInt64Value":
			case "google.protobuf.Int32Value":
			case "google.protobuf.UInt32Value": return "0";
			case "google.protobuf.BoolValue": return "false";
			case "google.protobuf.StringValue": return "\"\"";
			case "google.protobuf.BytesValue": return "new GLib.ByteArray ()";
			default: return "\"\"";
		}
	}

	public override void emit_decode_value (MethodSpec.Builder decode_method, FieldDescriptorProto field, string target_template, bool verify_utf8 = false) {
		var name = get_wrapper_name (field);
		var base_type = get_vala_type (field, false);

		decode_method.add_statement ("var wrp_len = buffer.decode_length ()");
		decode_method.add_statement ("var wrp_end = buffer.read_index + wrp_len");
		decode_method.add_statement ("%s wrp_val = %s".printf (base_type, get_zero_value (name)));
		decode_method.begin_control_flow ("while (buffer.read_index < wrp_end && !buffer.error)");
		decode_method.add_statement ("var wrp_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var wrp_num = wrp_tag >> 3");
		decode_method.begin_control_flow ("if (wrp_num == 1)");

		switch (name) {
			case "google.protobuf.DoubleValue":
				decode_method.add_statement ("wrp_val = buffer.decode_double ()");
				break;
			case "google.protobuf.FloatValue":
				decode_method.add_statement ("wrp_val = buffer.decode_float ()");
				break;
			case "google.protobuf.Int64Value":
				decode_method.add_statement ("wrp_val = buffer.decode_int64 ()");
				break;
			case "google.protobuf.UInt64Value":
				decode_method.add_statement ("wrp_val = buffer.decode_uint64 ()");
				break;
			case "google.protobuf.Int32Value":
				decode_method.add_statement ("wrp_val = buffer.decode_int32 ()");
				break;
			case "google.protobuf.UInt32Value":
				decode_method.add_statement ("wrp_val = buffer.decode_uint32 ()");
				break;
			case "google.protobuf.BoolValue":
				decode_method.add_statement ("wrp_val = buffer.decode_bool ()");
				break;
			case "google.protobuf.StringValue":
				if (verify_utf8) {
					decode_method.add_statement ("wrp_val = buffer.decode_utf8_string ((size_t) buffer.decode_length ())");
				} else {
					decode_method.add_statement ("wrp_val = buffer.decode_string ((size_t) buffer.decode_length ())");
				}
				break;
			case "google.protobuf.BytesValue":
				decode_method.add_statement ("wrp_val = buffer.decode_bytes ((size_t) buffer.decode_length ())");
				break;
		}

		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (wrp_tag))");
		decode_method.end_control_flow (); // end if
		decode_method.end_control_flow (); // end while

		decode_method.begin_control_flow ("if (buffer.read_index != wrp_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();

		decode_method.add_statement (target_template.replace ("{val}", "wrp_val"));
	}

	public override void emit_encode_submessage (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string buf_var, string len_var) {
		var name = get_wrapper_name (field);

		switch (name) {
			case "google.protobuf.DoubleValue":
				encode_method.begin_control_flow ("if (%s != 0d)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_double (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 1));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.FloatValue":
				encode_method.begin_control_flow ("if (%s != 0f)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_float (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 5));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.Int64Value":
				encode_method.begin_control_flow ("if (%s != 0)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_int64 (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.UInt64Value":
				encode_method.begin_control_flow ("if (%s != 0)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_uint64 (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.Int32Value":
				encode_method.begin_control_flow ("if (%s != 0)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_int32 (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.UInt32Value":
				encode_method.begin_control_flow ("if (%s != 0)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_uint32 (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.BoolValue":
				encode_method.begin_control_flow ("if (%s)".printf (val_expr));
				encode_method.add_statement ("%s += %s.encode_bool (%s)".printf (len_var, buf_var, val_expr));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 0));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.StringValue":
				encode_method.begin_control_flow ("if (%s != null && %s != \"\")".printf (val_expr, val_expr));
				encode_method.add_statement ("var str_len = %s.encode_string (%s)".printf (buf_var, val_expr));
				encode_method.add_statement ("%s += str_len".printf (len_var));
				encode_method.add_statement ("%s += %s.encode_varint (str_len)".printf (len_var, buf_var));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 2));
				encode_method.end_control_flow ();
				break;
			case "google.protobuf.BytesValue":
				encode_method.begin_control_flow ("if (%s != null && %s.len > 0)".printf (val_expr, val_expr));
				encode_method.add_statement ("var bytes_len = %s.encode_bytes (%s)".printf (buf_var, val_expr));
				encode_method.add_statement ("%s += bytes_len".printf (len_var));
				encode_method.add_statement ("%s += %s.encode_varint (bytes_len)".printf (len_var, buf_var));
				encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 2));
				encode_method.end_control_flow ();
				break;
		}
	}

	public override void emit_encode_map_value (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string entry_buf_var, string entry_len_var) {
		var name = get_wrapper_name (field);
		var base_type = get_vala_type (field, false);

		encode_method.add_statement ("var wrp_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t wrp_len = 0");
		if (needs_box (name)) {
			encode_method.add_statement ("%s wrp_val = (%s != null) ? (%s) %s : %s".printf (base_type, val_expr, base_type, val_expr, get_zero_value (name)));
		} else {
			encode_method.add_statement ("%s wrp_val = %s".printf (base_type, val_expr));
		}
		emit_encode_submessage (encode_method, field, "wrp_val", "wrp_buf", "wrp_len");
		encode_method.add_statement ("%s += %s.encode_raw_bytes (wrp_buf.data)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (wrp_len)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (entry_len_var, entry_buf_var, (2 << 3) | 2));
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		var name = get_wrapper_name (field);
		var base_type = get_vala_type (field, false);

		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			var generic_type = get_generic_type (field);
			encode_method.begin_control_flow ("for (unowned List<%s> wrp_node = %s.last (); wrp_node != null; wrp_node = wrp_node.prev)".printf (generic_type, field_name));
			encode_method.add_statement ("var wrp_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t wrp_len = 0");
			if (needs_box (name)) {
				encode_method.add_statement ("%s wrp_val = (wrp_node.data != null) ? (%s) wrp_node.data : %s".printf (base_type, base_type, get_zero_value (name)));
			} else {
				encode_method.add_statement ("%s wrp_val = wrp_node.data".printf (base_type));
			}
			emit_encode_submessage (encode_method, field, "wrp_val", "wrp_buf", "wrp_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (wrp_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (wrp_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		} else {
			encode_method.begin_control_flow ("if (%s != null)".printf (field_name));
			encode_method.add_statement ("var wrp_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t wrp_len = 0");
			encode_method.add_statement ("%s wrp_val = (%s) %s".printf (base_type, base_type, field_name));
			emit_encode_submessage (encode_method, field, "wrp_val", "wrp_buf", "wrp_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (wrp_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (wrp_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		}
	}

	private static string format_unboxed_expr (string name, string val_expr) {
		if (name == "google.protobuf.StringValue") {
			return "Google.Protobuf.string_to_string (%s)".printf (val_expr);
		} else if (name == "google.protobuf.BytesValue") {
			return "Google.Protobuf.bytes_to_string (%s)".printf (val_expr);
		} else {
			return "%s.to_string ()".printf (val_expr);
		}
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));
		var name = get_wrapper_name (field);

		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			var generic_type = get_generic_type (field);
			var base_type = get_vala_type (field, false);
			to_string_method.begin_control_flow ("foreach (unowned %s wrp_v in %s)".printf (generic_type, field_name));
			if (needs_box (name)) {
				to_string_method.add_statement ("%s wrp_val = (wrp_v != null) ? (%s) wrp_v : %s".printf (base_type, base_type, get_zero_value (name)));
				to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (%s)".printf (field.name, format_unboxed_expr (name, "wrp_val")));
			} else {
				to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (%s)".printf (field.name, format_unboxed_expr (name, "wrp_v")));
			}
			to_string_method.end_control_flow ();
		} else {
			to_string_method.begin_control_flow ("if (%s != null)".printf (field_name));
			to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (%s)".printf (field.name, format_unboxed_expr (name, field_name)));
			to_string_method.end_control_flow ();
		}
	}

	public override void emit_map_value_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, string val_expr) {
		var name = get_wrapper_name (field);
		var base_type = get_vala_type (field, false);
		if (needs_box (name)) {
			to_string_method.add_statement_raw ("text += indent + \"  value: %%s\\n\".printf (%s != null ? ((%s) %s).to_string () : \"%s\")".printf (val_expr, base_type, val_expr, get_zero_value (name)));
		} else {
			to_string_method.add_statement_raw ("text += indent + \"  value: %%s\\n\".printf (%s)".printf (format_unboxed_expr (name, val_expr)));
		}
	}
}
