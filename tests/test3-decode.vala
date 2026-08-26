using Google.Protobuf;

public class Test3Decode : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_scalar", () => {
			check_decode_scalar_message ("", 0, "");
			check_decode_scalar_message ("080A120568656C6C6F", 5, "hello");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_repeated", () => {
			// Test decoding repeated packed scalar field (proto3 default)
			check_decode_repeated_message3 ("0A03010203", "1 2 3");
			// Test decoding repeated unpacked scalar field (backward compatibility)
			check_decode_repeated_message3 ("080108020803", "1 2 3");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_enum", () => {
			check_decode_enum_message3 ("0802", Test.Vala3.Enum3.TWO);
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_map", () => {
			check_decode_map_message3 ("0A070A03666F6F102A", "foo", 42);
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_wkt", () => {
			check_decode_wkt_message3 ("0A0308E807", 1000);
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_optional", () => {
			// Unset fields in stream remain null in object
			var d1 = string_to_array ("");
			var b1 = new Google.Protobuf.DecodeBuffer (d1);
			var msg1 = new Test.Vala3.OptionalMessage3.from_data (b1);
			assert_true (msg1.opt_int == null);
			assert_true (msg1.opt_str == null);
			assert_true (msg1.opt_enum == null);
			assert_true (msg1.opt_bool == null);

			// Explicit zero value in stream sets field to non-null zero value
			var d2 = string_to_array ("0800");
			var b2 = new Google.Protobuf.DecodeBuffer (d2);
			var msg2 = new Test.Vala3.OptionalMessage3.from_data (b2);
			assert_true (msg2.opt_int != null);
			assert_cmpint (msg2.opt_int, CompareOperator.EQ, 0);

			// Non-zero values decode properly
			var d3 = string_to_array ("082A1202686918012001");
			var b3 = new Google.Protobuf.DecodeBuffer (d3);
			var msg3 = new Test.Vala3.OptionalMessage3.from_data (b3);
			assert_true (msg3.opt_int != null);
			assert_cmpint (msg3.opt_int, CompareOperator.EQ, 42);
			assert_cmpstr (msg3.opt_str, CompareOperator.EQ, "hi");
			assert_true (msg3.opt_enum != null);
			assert_true (msg3.opt_bool == true);
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_wrappers", () => {
			// Unset wrappers remain null
			var d1 = string_to_array ("");
			var b1 = new Google.Protobuf.DecodeBuffer (d1);
			var msg1 = new Test.Vala3.WrapperMessage3.from_data (b1);
			assert_true (msg1.wrp_int32 == null);
			assert_true (msg1.wrp_string == null);
			assert_true (msg1.wrp_bool == null);

			// Decoded wrapper fields unbox properly
			var d2 = string_to_array ("0A02082A3A02080142040A026869");
			var b2 = new Google.Protobuf.DecodeBuffer (d2);
			var msg2 = new Test.Vala3.WrapperMessage3.from_data (b2);
			assert_true (msg2.wrp_int32 != null);
			assert_cmpint (msg2.wrp_int32, CompareOperator.EQ, 42);
			assert_true (msg2.wrp_bool != null);
			assert_cmpstr (msg2.wrp_string, CompareOperator.EQ, "hi");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/decode_field_mask", () => {
			var d = string_to_array ("0A0E0A07666F6F2E6261720A0362617A");
			var b = new Google.Protobuf.DecodeBuffer (d);
			var msg = new Test.Vala3.FieldMaskMessage3.from_data (b);
			assert_true (!b.error);
			assert_cmpint (msg.update_mask.size, CompareOperator.EQ, 2);
			assert_cmpstr (msg.update_mask.get (0), CompareOperator.EQ, "foo.bar");
			assert_cmpstr (msg.update_mask.get (1), CompareOperator.EQ, "baz");
		});

		return GLib.Test.run ();
	}

	private static void check_decode_scalar_message (string hex, int32 expected_int, string expected_str, bool expect_error = false) {
		var data = string_to_array (hex);
		var buffer = new Google.Protobuf.DecodeBuffer (data);
		var value = new Test.Vala3.ScalarMessage3.from_data (buffer);

		assert_true (buffer.error == expect_error);
		if (!expect_error) {
			assert_cmpint (value.int_value, CompareOperator.EQ, expected_int);
			assert_cmpstr (value.string_value, CompareOperator.EQ, expected_str);
		}
	}

	private static void check_decode_repeated_message3 (string hex, string expected) {
		var data = string_to_array (hex);
		var buffer = new Google.Protobuf.DecodeBuffer (data);
		var value = new Test.Vala3.RepeatedMessage3.from_data (buffer);

		assert_true (!buffer.error);
		var list_str = "";
		foreach (unowned uint32 v in value.value) {
			if (list_str != "") list_str += " ";
			list_str += v.to_string ();
		}
		assert_cmpstr (list_str, CompareOperator.EQ, expected);
	}

	private static void check_decode_enum_message3 (string hex, Test.Vala3.Enum3 expected) {
		var data = string_to_array (hex);
		var buffer = new Google.Protobuf.DecodeBuffer (data);
		var value = new Test.Vala3.EnumMessage3.from_data (buffer);

		assert_true (!buffer.error);
		assert_cmpint ((int) value.enum_value, CompareOperator.EQ, (int) expected);
	}

	private static void check_decode_map_message3 (string hex, string expected_key, int32 expected_val) {
		var data = string_to_array (hex);
		var buffer = new Google.Protobuf.DecodeBuffer (data);
		var value = new Test.Vala3.MapMessage3.from_data (buffer);

		assert_true (!buffer.error);
		assert_true (value.string_to_int.has_key (expected_key));
		assert_cmpint (value.string_to_int.get (expected_key), CompareOperator.EQ, expected_val);
	}

	private static void check_decode_wkt_message3 (string hex, int64 expected_unix_sec) {
		var data = string_to_array (hex);
		var buffer = new Google.Protobuf.DecodeBuffer (data);
		var value = new Test.Vala3.WktMessage3.from_data (buffer);

		assert_true (!buffer.error);
		assert_true (value.timestamp != null);
		assert_true (value.timestamp.to_unix () == expected_unix_sec);
	}

	private static uint8[] string_to_array (string data) {
		var value = new uint8[data.length / 2];
		for (var i = 0; i < value.length; i++)
			value[i] = str_to_int (data[i * 2]) << 4 | str_to_int (data[i * 2 + 1]);
		return value;
	}

	private static uint8 str_to_int (char c) {
		if (c >= '0' && c <= '9')
			return c - '0';
		else if (c >= 'a' && c <= 'f')
			return c - 'a' + 10;
		else if (c >= 'A' && c <= 'F')
			return c - 'A' + 10;
		else
			return 0;
	}
}
