using Google.Protobuf;
using ValaPoet;

private class FieldMaskHandler : WktHandler {
	public static bool is_field_mask_field (FieldDescriptorProto field) {
		if (field.type != FieldDescriptorProto.Type.TYPE_MESSAGE) return false;
		var name = field.type_name;
		if (name.has_prefix (".")) name = name.substring (1);
		return name == "google.protobuf.FieldMask";
	}

	public override string get_vala_type (FieldDescriptorProto field, bool full = true, bool is_explicit = false, bool is_required = false) {
		if (!full) return "Gee.ArrayList<string>";
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "List<Gee.ArrayList<string>>";
		if (is_explicit || field.proto3_optional) return "Gee.ArrayList<string>?";
		return "Gee.ArrayList<string>";
	}

	public override string get_generic_type (FieldDescriptorProto field) {
		return "Gee.ArrayList<string>";
	}

	public override string get_default_value (FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) return "new List<Gee.ArrayList<string>> ()";
		if (is_explicit || field.proto3_optional) return "null";
		return "new Gee.ArrayList<string> ()";
	}

	public override string get_map_default_value (FieldDescriptorProto field) {
		return "new Gee.ArrayList<string> ()";
	}

	public override void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first, bool is_explicit = false, bool is_required = false, bool verify_utf8 = false) {
		if (first) {
			decode_method.begin_control_flow ("if (field_number == %d && wire_type == 2)".printf (field.number));
		} else {
			decode_method.next_control_flow ("else if (field_number == %d && wire_type == 2)".printf (field.number));
		}
		var fname = get_field_name (field);
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			emit_decode_value (decode_method, field, "this.%s.append ({val})".printf (fname), verify_utf8);
		} else if (is_explicit || field.proto3_optional) {
			emit_decode_value (decode_method, field, "if (this.%s == null) this.%s = {val}; else this.%s.add_all ({val})".printf (fname, fname, fname), verify_utf8);
		} else {
			emit_decode_value (decode_method, field, "this.%s.add_all ({val})".printf (fname), verify_utf8);
			if (is_required) {
				decode_method.add_statement ("have_%s = true".printf (field.name));
			}
		}
		first = false;
	}

	public override void emit_decode_value (MethodSpec.Builder decode_method, FieldDescriptorProto field, string target_template, bool verify_utf8 = false) {
		decode_method.add_statement ("var fm_len = buffer.decode_length ()");
		decode_method.add_statement ("var fm_end = buffer.read_index + fm_len");
		decode_method.add_statement ("var fm_val = new Gee.ArrayList<string> ()");
		decode_method.begin_control_flow ("while (buffer.read_index < fm_end && !buffer.error)");
		decode_method.add_statement ("var fm_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var fm_num = fm_tag >> 3");
		decode_method.begin_control_flow ("if (fm_num == 1)");
		if (verify_utf8) {
			decode_method.add_statement ("fm_val.add (buffer.decode_utf8_string ((size_t) buffer.decode_length ()))");
		} else {
			decode_method.add_statement ("fm_val.add (buffer.decode_string ((size_t) buffer.decode_length ()))");
		}
		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (fm_tag))");
		decode_method.end_control_flow (); // end if
		decode_method.end_control_flow (); // end while

		decode_method.begin_control_flow ("if (buffer.read_index != fm_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();

		decode_method.add_statement (target_template.replace ("{val}", "fm_val"));
	}

	public override void emit_encode_submessage (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string buf_var, string len_var) {
		encode_method.begin_control_flow ("if (%s != null)".printf (val_expr));
		encode_method.begin_control_flow ("for (var fm_i = %s.size - 1; fm_i >= 0; fm_i--)".printf (val_expr));
		encode_method.add_statement ("var fm_path = %s.get (fm_i)".printf (val_expr));
		encode_method.add_statement ("var fm_path_len = %s.encode_string (fm_path)".printf (buf_var));
		encode_method.add_statement ("%s += fm_path_len".printf (len_var));
		encode_method.add_statement ("%s += %s.encode_varint (fm_path_len)".printf (len_var, buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (len_var, buf_var, (1 << 3) | 2));
		encode_method.end_control_flow ();
		encode_method.end_control_flow ();
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));

		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			encode_method.begin_control_flow ("for (unowned List<Gee.ArrayList<string>> fm_node = %s.last (); fm_node != null; fm_node = fm_node.prev)".printf (field_name));
			encode_method.add_statement ("var fm_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t fm_len = 0");
			emit_encode_submessage (encode_method, field, "fm_node.data", "fm_buf", "fm_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (fm_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (fm_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		} else {
			if (is_explicit || is_required || field.proto3_optional) {
				encode_method.begin_control_flow ("if (%s != null)".printf (field_name));
			} else {
				encode_method.begin_control_flow ("if (%s != null && %s.size > 0)".printf (field_name, field_name));
			}
			encode_method.add_statement ("var fm_buf = new Google.Protobuf.EncodeBuffer ()");
			encode_method.add_statement ("size_t fm_len = 0");
			emit_encode_submessage (encode_method, field, field_name, "fm_buf", "fm_len");
			encode_method.add_statement ("n_written += buffer.encode_raw_bytes (fm_buf.data)");
			encode_method.add_statement ("n_written += buffer.encode_varint (fm_len)");
			encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
			encode_method.end_control_flow ();
		}
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false) {
		var field_name = "this.%s".printf (get_field_name (field));

		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			to_string_method.begin_control_flow ("foreach (unowned Gee.ArrayList<string> fm_v in %s)".printf (field_name));
			to_string_method.add_statement ("var fm_str = \"\"");
			to_string_method.begin_control_flow ("if (fm_v != null)");
			to_string_method.begin_control_flow ("foreach (var fm_p in fm_v)");
			to_string_method.begin_control_flow ("if (fm_str != \"\")");
			to_string_method.add_statement ("fm_str += \", \"");
			to_string_method.end_control_flow ();
			to_string_method.add_statement ("fm_str += fm_p");
			to_string_method.end_control_flow ();
			to_string_method.end_control_flow ();
			to_string_method.add_statement_raw ("text += indent + \"%s { paths: [\\\"%%s\\\"] }\\n\".printf (fm_str)".printf (field.name));
			to_string_method.end_control_flow ();
		} else {
			if (is_explicit || is_required || field.proto3_optional) {
				to_string_method.begin_control_flow ("if (%s != null)".printf (field_name));
			} else {
				to_string_method.begin_control_flow ("if (%s != null && %s.size > 0)".printf (field_name, field_name));
			}
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

	public override void emit_map_value_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, string val_expr) {
		to_string_method.add_statement ("var fm_str = \"\"");
		to_string_method.begin_control_flow ("if (%s != null)".printf (val_expr));
		to_string_method.begin_control_flow ("foreach (var fm_p in %s)".printf (val_expr));
		to_string_method.begin_control_flow ("if (fm_str != \"\")");
		to_string_method.add_statement ("fm_str += \", \"");
		to_string_method.end_control_flow ();
		to_string_method.add_statement ("fm_str += fm_p");
		to_string_method.end_control_flow ();
		to_string_method.end_control_flow ();
		to_string_method.add_statement_raw ("text += indent + \"  value { paths: [\\\"%s\\\"] }\\n\".printf (fm_str)");
	}
}
