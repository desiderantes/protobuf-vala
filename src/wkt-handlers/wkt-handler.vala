using Google.Protobuf;
using ValaPoet;

private abstract class WktHandler : Object {
	public abstract string get_vala_type (FieldDescriptorProto field, bool full = true, bool is_explicit = false, bool is_required = false);
	public virtual string get_generic_type (FieldDescriptorProto field) {
		return get_vala_type (field, false);
	}
	public abstract string get_default_value (FieldDescriptorProto field, bool is_explicit = false, bool is_required = false);
	public virtual string get_map_default_value (FieldDescriptorProto field) {
		return get_default_value (field);
	}
	public abstract void emit_decode_value (MethodSpec.Builder decode_method, FieldDescriptorProto field, string target_template, bool verify_utf8 = false);
	public abstract void emit_encode_submessage (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string buf_var, string len_var);
	public virtual void emit_encode_map_value (MethodSpec.Builder encode_method, FieldDescriptorProto field, string val_expr, string entry_buf_var, string entry_len_var) {
		encode_method.add_statement ("var wkt_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t wkt_len = 0");
		emit_encode_submessage (encode_method, field, val_expr, "wkt_buf", "wkt_len");
		encode_method.add_statement ("%s += %s.encode_raw_bytes (wkt_buf.data)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (wkt_len)".printf (entry_len_var, entry_buf_var));
		encode_method.add_statement ("%s += %s.encode_varint (%d)".printf (entry_len_var, entry_buf_var, (2 << 3) | 2));
	}
	public abstract void emit_map_value_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, string val_expr);

	public virtual void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first, bool is_explicit = false, bool is_required = false, bool verify_utf8 = false) {
		if (first) {
			decode_method.begin_control_flow ("if (field_number == %d && wire_type == 2)".printf (field.number));
		} else {
			decode_method.next_control_flow ("else if (field_number == %d && wire_type == 2)".printf (field.number));
		}
		if (field.label == FieldDescriptorProto.Label.LABEL_REPEATED) {
			emit_decode_value (decode_method, field, "this.%s.append ({val})".printf (get_field_name (field)), verify_utf8);
		} else {
			emit_decode_value (decode_method, field, "this.%s = {val}".printf (get_field_name (field)), verify_utf8);
			if (is_required) {
				decode_method.add_statement ("have_%s = true".printf (field.name));
			}
		}
		first = false;
	}

	public abstract void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false);
	public abstract void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field, bool is_explicit = false, bool is_required = false);
}

private class WktRegistry {
	private static TimestampHandler timestamp_handler;
	private static DurationHandler duration_handler;
	private static WrapperHandler wrapper_handler;
	private static FieldMaskHandler field_mask_handler;

	public static void init () {
		if (timestamp_handler == null) timestamp_handler = new TimestampHandler ();
		if (duration_handler == null) duration_handler = new DurationHandler ();
		if (wrapper_handler == null) wrapper_handler = new WrapperHandler ();
		if (field_mask_handler == null) field_mask_handler = new FieldMaskHandler ();
	}

	public static bool is_timestamp_field (FieldDescriptorProto field) {
		if (field.type != FieldDescriptorProto.Type.TYPE_MESSAGE) return false;
		return field.type_name == ".google.protobuf.Timestamp" || field.type_name == "google.protobuf.Timestamp";
	}

	public static bool is_duration_field (FieldDescriptorProto field) {
		if (field.type != FieldDescriptorProto.Type.TYPE_MESSAGE) return false;
		return field.type_name == ".google.protobuf.Duration" || field.type_name == "google.protobuf.Duration";
	}

	public static WktHandler? get_handler (FieldDescriptorProto field) {
		init ();
		if (is_timestamp_field (field)) return timestamp_handler;
		if (is_duration_field (field)) return duration_handler;
		if (WrapperHandler.is_wrapper_field (field)) return wrapper_handler;
		if (FieldMaskHandler.is_field_mask_field (field)) return field_mask_handler;
		return null;
	}
}
