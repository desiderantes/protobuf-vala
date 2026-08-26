using Google.Protobuf;
using ValaPoet;

private abstract class WktHandler : Object {
	public abstract string get_vala_type (FieldDescriptorProto field, bool full = true);
	public abstract string get_default_value (FieldDescriptorProto field);
	public abstract void emit_decode (MethodSpec.Builder decode_method, FieldDescriptorProto field, ref bool first);
	public abstract void emit_encode (MethodSpec.Builder encode_method, FieldDescriptorProto field);
	public abstract void emit_to_string (MethodSpec.Builder to_string_method, FieldDescriptorProto field);
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
