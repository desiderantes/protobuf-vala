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

	public override string get_vala_type (FieldDescriptorProto field, bool full = true) {
		var name = get_wrapper_name (field);
		switch (name) {
			case "google.protobuf.DoubleValue": return full ? "double?" : "double";
			case "google.protobuf.FloatValue": return full ? "float?" : "float";
			case "google.protobuf.Int64Value": return full ? "int64?" : "int64";
			case "google.protobuf.UInt64Value": return full ? "uint64?" : "uint64";
			case "google.protobuf.Int32Value": return full ? "int32?" : "int32";
			case "google.protobuf.UInt32Value": return full ? "uint32?" : "uint32";
			case "google.protobuf.BoolValue": return full ? "bool?" : "bool";
			case "google.protobuf.StringValue": return full ? "string?" : "string";
			case "google.protobuf.BytesValue": return full ? "GLib.ByteArray?" : "GLib.ByteArray";
			default: return "string?";
		}
	}

	public override string get_default_value (FieldDescriptorProto field) {
		return "null";
	}

	public override void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first) {
		if (first) {
			decode_method.begin_control_flow ("if (field_number == %d && wire_type == 2)".printf (field.number));
		} else {
			decode_method.next_control_flow ("else if (field_number == %d && wire_type == 2)".printf (field.number));
		}

		var field_name = get_field_name (field);
		var name = get_wrapper_name (field);

		decode_method.add_statement ("var wrp_len = (ssize_t) buffer.decode_varint ()");
		decode_method.add_statement ("var wrp_end = buffer.read_index + wrp_len");
		decode_method.begin_control_flow ("while (buffer.read_index < wrp_end)");
		decode_method.add_statement ("var wrp_tag = buffer.decode_varint ()");
		decode_method.add_statement ("var wrp_num = wrp_tag >> 3");
		decode_method.begin_control_flow ("if (wrp_num == 1)");

		switch (name) {
			case "google.protobuf.DoubleValue":
				decode_method.add_statement ("this.%s = buffer.decode_double ()".printf (field_name));
				break;
			case "google.protobuf.FloatValue":
				decode_method.add_statement ("this.%s = buffer.decode_float ()".printf (field_name));
				break;
			case "google.protobuf.Int64Value":
				decode_method.add_statement ("this.%s = buffer.decode_int64 ()".printf (field_name));
				break;
			case "google.protobuf.UInt64Value":
				decode_method.add_statement ("this.%s = buffer.decode_uint64 ()".printf (field_name));
				break;
			case "google.protobuf.Int32Value":
				decode_method.add_statement ("this.%s = buffer.decode_int32 ()".printf (field_name));
				break;
			case "google.protobuf.UInt32Value":
				decode_method.add_statement ("this.%s = buffer.decode_uint32 ()".printf (field_name));
				break;
			case "google.protobuf.BoolValue":
				decode_method.add_statement ("this.%s = buffer.decode_bool ()".printf (field_name));
				break;
			case "google.protobuf.StringValue":
				decode_method.add_statement ("this.%s = buffer.decode_string ((size_t) buffer.decode_varint ())".printf (field_name));
				break;
			case "google.protobuf.BytesValue":
				decode_method.add_statement ("this.%s = buffer.decode_bytes ((size_t) buffer.decode_varint ())".printf (field_name));
				break;
		}

		decode_method.next_control_flow ("else");
		decode_method.add_statement ("this.unknown_fields.prepend (buffer.decode_unknown_field (wrp_tag))");
		decode_method.end_control_flow (); // end if
		decode_method.end_control_flow (); // end while

		decode_method.begin_control_flow ("if (buffer.read_index != wrp_end)");
		decode_method.add_statement ("buffer.error = true");
		decode_method.end_control_flow ();

		first = false;
	}

	public override void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field) {
		var field_name = get_field_name (field);
		var name = get_wrapper_name (field);

		encode_method.begin_control_flow ("if (this.%s != null)".printf (field_name));
		encode_method.add_statement ("var wrp_buf = new Google.Protobuf.EncodeBuffer ()");
		encode_method.add_statement ("size_t wrp_len = 0");

		switch (name) {
			case "google.protobuf.DoubleValue":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_double (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 1));
				break;
			case "google.protobuf.FloatValue":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_float (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 5));
				break;
			case "google.protobuf.Int64Value":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_int64 (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 0));
				break;
			case "google.protobuf.UInt64Value":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_uint64 (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 0));
				break;
			case "google.protobuf.Int32Value":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_int32 (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 0));
				break;
			case "google.protobuf.UInt32Value":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_uint32 (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 0));
				break;
			case "google.protobuf.BoolValue":
				encode_method.add_statement ("wrp_len += wrp_buf.encode_bool (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 0));
				break;
			case "google.protobuf.StringValue":
				encode_method.add_statement ("var str_len = wrp_buf.encode_string (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += str_len");
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (str_len)");
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 2));
				break;
			case "google.protobuf.BytesValue":
				encode_method.add_statement ("var bytes_len = wrp_buf.encode_bytes (this.%s)".printf (field_name));
				encode_method.add_statement ("wrp_len += bytes_len");
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (bytes_len)");
				encode_method.add_statement ("wrp_len += wrp_buf.encode_varint (%d)".printf ((1 << 3) | 2));
				break;
		}

		encode_method.add_statement ("n_written += buffer.encode_raw_bytes (wrp_buf.data)");
		encode_method.add_statement ("n_written += buffer.encode_varint (wrp_len)");
		encode_method.add_statement ("n_written += buffer.encode_varint (%d)".printf ((field.number << 3) | 2));
		encode_method.add_statement ("n_written += wrp_len");
		encode_method.end_control_flow ();
	}

	public override void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field) {
		var field_name = "this.%s".printf (get_field_name (field));
		var name = get_wrapper_name (field);

		to_string_method.begin_control_flow ("if (%s != null)".printf (field_name));
		if (name == "google.protobuf.StringValue") {
			to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (Google.Protobuf.string_to_string (%s))".printf (field.name, field_name));
		} else if (name == "google.protobuf.BytesValue") {
			to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (Google.Protobuf.bytes_to_string (%s))".printf (field.name, field_name));
		} else {
			to_string_method.add_statement_raw ("text += indent + \"%s: %%s\\n\".printf (%s.to_string ())".printf (field.name, field_name));
		}
		to_string_method.end_control_flow ();
	}
}
