using Google.Protobuf;

public class Test3Encode : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_scalar", () => {
			check_encode_scalar_message (0, "", "");
			check_encode_scalar_message (5, "hello", "080A120568656C6C6F");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_repeated", () => {
			check_encode_repeated_message3 ("1 2 3", "0A03010203");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_enum", () => {
			check_encode_enum_message3 (Test.Vala3.Enum3.TWO, "0802");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_map", () => {
			check_encode_map_message3 ("foo", 42, "0A070A03666F6F102A");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_wkt", () => {
			check_encode_wkt_message3 (new GLib.DateTime.from_unix_utc (1000), "0A0308E807");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_optional", () => {
			// Unset optional fields emit nothing
			var msg1 = new Test.Vala3.OptionalMessage3 ();
			var buf1 = new Google.Protobuf.EncodeBuffer ();
			msg1.encode (buf1);
			assert_cmpstr (buffer_to_string (buf1), CompareOperator.EQ, "");

			// Explicitly zero-valued optional field DOES emit on wire
			var msg2 = new Test.Vala3.OptionalMessage3 ();
			msg2.opt_int = 0;
			var buf2 = new Google.Protobuf.EncodeBuffer ();
			msg2.encode (buf2);
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "0800");

			// Non-zero optional field emits
			var msg3 = new Test.Vala3.OptionalMessage3 ();
			msg3.opt_int = 42;
			msg3.opt_str = "hi";
			msg3.opt_enum = Test.Vala3.Enum3.ONE;
			msg3.opt_bool = true;
			var buf3 = new Google.Protobuf.EncodeBuffer ();
			msg3.encode (buf3);
			assert_cmpstr (buffer_to_string (buf3), CompareOperator.EQ, "082A1202686918012001");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_wrappers", () => {
			// Unset wrappers emit nothing
			var msg1 = new Test.Vala3.WrapperMessage3 ();
			var buf1 = new Google.Protobuf.EncodeBuffer ();
			msg1.encode (buf1);
			assert_cmpstr (buffer_to_string (buf1), CompareOperator.EQ, "");

			// Wrappers set to values emit submessages
			var msg2 = new Test.Vala3.WrapperMessage3 ();
			msg2.wrp_int32 = 42;
			msg2.wrp_string = "hi";
			msg2.wrp_bool = true;
			var buf2 = new Google.Protobuf.EncodeBuffer ();
			msg2.encode (buf2);
			// field 1 (Int32Value(42)) -> 0A02082A
			// field 7 (BoolValue(true)) -> 3A020801
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "0A02082A3A02080142040A026869");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/encode_field_mask", () => {
			var msg = new Test.Vala3.FieldMaskMessage3 ();
			msg.update_mask.add ("foo.bar");
			msg.update_mask.add ("baz");
			var buf = new Google.Protobuf.EncodeBuffer ();
			msg.encode (buf);
			// field 1 (FieldMask) -> 0A 0E (len 14): 0A 07 'foo.bar' 0A 03 'baz'
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "0A0E0A07666F6F2E6261720A0362617A");
		});

		return GLib.Test.run ();
	}

	private static void check_encode_scalar_message (int32 int_value, string string_value, string expected) {
		var value = new Test.Vala3.ScalarMessage3 ();
		value.int_value = int_value;
		value.string_value = string_value;

		var buffer = new Google.Protobuf.EncodeBuffer ();
		value.encode (buffer);
		var result = buffer_to_string (buffer);
		assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_encode_repeated_message3 (string repeated_value, string expected) {
		var value = new Test.Vala3.RepeatedMessage3 ();
		var values = repeated_value.split (" ");
		for (var i = 0; i < values.length; i++)
			value.value.append (int.parse (values[i]));

		var buffer = new Google.Protobuf.EncodeBuffer ();
		value.encode (buffer);
		var result = buffer_to_string (buffer);
		assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_encode_enum_message3 (Test.Vala3.Enum3 enum_val, string expected) {
		var value = new Test.Vala3.EnumMessage3 ();
		value.enum_value = enum_val;

		var buffer = new Google.Protobuf.EncodeBuffer ();
		value.encode (buffer);
		var result = buffer_to_string (buffer);
		assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_encode_map_message3 (string key, int32 val, string expected) {
		var value = new Test.Vala3.MapMessage3 ();
		value.string_to_int.set (key, val);

		var buffer = new Google.Protobuf.EncodeBuffer ();
		value.encode (buffer);
		var result = buffer_to_string (buffer);
		assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_encode_wkt_message3 (GLib.DateTime dt, string expected) {
		var value = new Test.Vala3.WktMessage3 ();
		value.timestamp = dt;

		var buffer = new Google.Protobuf.EncodeBuffer ();
		value.encode (buffer);
		var result = buffer_to_string (buffer);
		assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static string buffer_to_string (Google.Protobuf.EncodeBuffer buffer) {
		var value = "";
		var data = buffer.data;
		for (var i = 0; i < data.length; i++)
			value += "%02X".printf (data[i]);
		return value;
	}
}
