using Google.Protobuf;

public class TestDecode : Object {

	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/decode/varint", () => {
			check_decode_varint ("", 0, true);
			check_decode_varint ("00", 0);
			check_decode_varint ("01", 1);
			check_decode_varint ("03", 3);
			check_decode_varint ("7F", 127);
			check_decode_varint ("FF", 0, true);
			check_decode_varint ("8001", 128);
			check_decode_varint ("8E02", 270);
			check_decode_varint ("FF7F", 16383);
			check_decode_varint ("808001", 16384);
			check_decode_varint ("9EA705", 86942);
			check_decode_varint ("FFFFFF07", 0xFFFFFF);
			check_decode_varint ("FFFFFFFF0F", 0xFFFFFFFF);
			check_decode_varint ("FFFFFFFFFFFFFFFFFF01", 0xFFFFFFFFFFFFFFFF);
		});

		GLib.Test.add_func ("/protobuf-vala/decode/floating_point", () => {
			check_decode_double ("", 0d, true);
			check_decode_double ("00", 0d, true);
			check_decode_double ("00000000000000", 0d, true);
			check_decode_double ("0000000000000000", 0d);
			check_decode_double ("0000000000000080", -0d);
			check_decode_double ("000000000000F03F", 1d);
			check_decode_double ("000000000000F0BF", -1d);
			check_decode_double ("FFFFFFFFFFFFEF7F", double.MAX);
			check_decode_double ("FFFFFFFFFFFFEFFF", -double.MAX);
			check_decode_double ("000000000000F07F", double.INFINITY);
			check_decode_double ("000000000000F0FF", -double.INFINITY);

			check_decode_float ("", 0f, true);
			check_decode_float ("00", 0f, true);
			check_decode_float ("000000", 0f, true);
			check_decode_float ("00000000", 0f);
			check_decode_float ("00000080", -0f);
			check_decode_float ("0000803F", 1f);
			check_decode_float ("000080BF", -1f);
			check_decode_float ("FFFF7F7F", float.MAX);
			check_decode_float ("FFFF7FFF", -float.MAX);
			check_decode_float ("0000807F", float.INFINITY);
			check_decode_float ("000080FF", -float.INFINITY);
			check_decode_float ("0000203E", 0.15625f);
		});

		GLib.Test.add_func ("/protobuf-vala/decode/integers", () => {
			check_decode_int64 ("00", 0);
			check_decode_int64 ("01", 1);
			check_decode_int64 ("FFFFFFFFFFFFFFFFFF01", -1);
			check_decode_int64 ("FFFFFFFFFFFFFFFF7F", int64.MAX);
			check_decode_int64 ("80808080808080808001", int64.MIN);

			check_decode_uint64 ("00", 0);
			check_decode_uint64 ("01", 1);
			check_decode_uint64 ("FFFFFFFFFFFFFFFFFF01", uint64.MAX);

			check_decode_int32 ("00", 0);
			check_decode_int32 ("01", 1);
			check_decode_int32 ("FFFFFFFFFFFFFFFFFF01", -1);
			check_decode_int32 ("FFFFFFFF07", int32.MAX);
			check_decode_int32 ("80808080F8FFFFFFFF01", int32.MIN);

			check_decode_fixed64 ("0000000000000000", 0);
			check_decode_fixed64 ("0100000000000000", 1);
			check_decode_fixed64 ("EFCDAB8967452301", 0x0123456789ABCDEF);
			check_decode_fixed64 ("FFFFFFFFFFFFFFFF", uint64.MAX);

			check_decode_fixed32 ("00000000", 0);
			check_decode_fixed32 ("01000000", 1);
			check_decode_fixed32 ("67452301", 0x01234567);
			check_decode_fixed32 ("FFFFFFFF", uint32.MAX);

			check_decode_bool ("", false, true);
			check_decode_bool ("00", false);
			check_decode_bool ("01", true);
			check_decode_bool ("7F", true);
			check_decode_bool ("FF", false, true);

			check_decode_string ("", 0, "");
			check_decode_string ("", 1, "", true);
			check_decode_string ("31", 1, "1");
			check_decode_string ("31", 3, "", true);
			check_decode_string ("313233", 3, "123");
			check_decode_string ("313233", 5, "", true);

			check_decode_bytes ("", 0, "");
			check_decode_bytes ("", 1, "", true);
			check_decode_bytes ("AA", 1, "AA");
			check_decode_bytes ("AA", 3, "", true);
			check_decode_bytes ("AABBCC", 3, "AABBCC");
			check_decode_bytes ("AABBCC", 5, "", true);

			check_decode_uint32 ("00", 0);
			check_decode_uint32 ("01", 1);
			check_decode_uint32 ("FFFFFFFF0F", uint32.MAX);

			check_decode_sfixed32 ("00000000", 0);
			check_decode_sfixed32 ("01000000", 1);
			check_decode_sfixed32 ("FFFFFFFF", -1);
			check_decode_sfixed32 ("00000080", int32.MIN);
			check_decode_sfixed32 ("FFFFFF7F", int32.MAX);

			check_decode_sfixed64 ("0000000000000000", 0);
			check_decode_sfixed64 ("0100000000000000", 1);
			check_decode_sfixed64 ("FFFFFFFFFFFFFFFF", -1);
			check_decode_sfixed64 ("0000000000000080", int64.MIN);
			check_decode_sfixed64 ("FFFFFFFFFFFFFF7F", int64.MAX);

			check_decode_sint32 ("00", 0);
			check_decode_sint32 ("02", 1);
			check_decode_sint32 ("04", 2);
			check_decode_sint32 ("01", -1);
			check_decode_sint32 ("03", -2);
			check_decode_sint32 ("FEFFFFFF0F", int32.MAX);
			check_decode_sint32 ("FFFFFFFF0F", int32.MIN);

			check_decode_sint64 ("00", 0);
			check_decode_sint64 ("02", 1);
			check_decode_sint64 ("04", 2);
			check_decode_sint64 ("01", -1);
			check_decode_sint64 ("03", -2);
			check_decode_sint64 ("FEFFFFFFFFFFFFFFFF01", int64.MAX);
			check_decode_sint64 ("FFFFFFFFFFFFFFFFFF01", int64.MIN);
		});

		GLib.Test.add_func ("/protobuf-vala/decode/messages", () => {
			check_decode_enum_message ("080110011801", Test.Vala.Enum.ONE, Test.Vala.Enum.ONE, Test.Vala.Enum.ONE);
			check_decode_enum_message ("08021002", Test.Vala.Enum.TWO, Test.Vala.Enum.TWO, Test.Vala.Enum.TWO);
			check_decode_enum_message ("080310031803", Test.Vala.Enum.THREE, Test.Vala.Enum.THREE, Test.Vala.Enum.THREE);

			check_decode_message ("08FFFFFFFFFFFFFFFFFF011001180125010000002DFFFFFFFF30FFFFFFFFFFFFFFFFFF013801400149010000000000000051FFFFFFFFFFFFFFFF580160016A04544553547202BEEF79000000000000F03F85010000803F");

			check_decode_required_message ("", 0, "", true);
			check_decode_required_message ("0800", 0, "", true);
			check_decode_required_message ("1200", 0, "", true);
			check_decode_required_message ("08001200", 0, "");
			check_decode_required_message ("0802120454455354", 1, "TEST");
			check_decode_required_message ("08021204544553541A03313233", 1, "TEST");

			check_decode_required_message_reencode ("0802120454455354");
			check_decode_required_message_reencode ("0802120454455354180125010000002DFFFFFFFF30FFFFFFFFFFFFFFFFFF013801400149010000000000000051FFFFFFFFFFFFFFFF580160016A04544553547202BEEF79000000000000F03F85010000803F");

			check_decode_optional_message ("", 0, "");
			check_decode_optional_message ("0802", 1, "");
			check_decode_optional_message ("120454455354", 0, "TEST");
			check_decode_optional_message ("0802120454455354", 1, "TEST");
			check_decode_optional_message_twice ("120454455354", "0802", 1, "");

			check_decode_optional_defaults_message ("08001200", 0, "");
			check_decode_optional_defaults_message ("1200", 1, "");
			check_decode_optional_defaults_message ("0800", 0, "TEST");
			check_decode_optional_defaults_message ("", 1, "TEST");

			check_decode_repeated_message ("", "");
			check_decode_repeated_message ("0801", "1");
			check_decode_repeated_message ("0801080208030804", "1 2 3 4");

			check_decode_repeated_packed_message ("", "");
			check_decode_repeated_packed_message ("0A0101", "1");
			check_decode_repeated_packed_message ("0A0401020304", "1 2 3 4");
			check_decode_repeated_packed_message ("0A0201020A020304", "1 2 3 4");

			check_decode_required_nested_message ("", 0, true);
			check_decode_required_nested_message ("0A00", 0, true);
			check_decode_required_nested_message ("0A020801", 1);

			check_decode_optional_nested_message ("", null);
			check_decode_optional_nested_message ("0A00", 0, true);
			check_decode_optional_nested_message ("0A020801", 1);

			check_decode_repeated_nested_message ("", "");
			check_decode_repeated_nested_message ("0A00", "", true);
			check_decode_repeated_nested_message ("0A020801", "1");
			check_decode_repeated_nested_message ("0A0208010A0208020A020803", "1 2 3");

			check_decode_existing_buffer ("", 0, -1, 0, true);
			check_decode_existing_buffer ("01", 0, 0, 0, true);
			check_decode_existing_buffer ("01", 0, -1, 1);
			check_decode_existing_buffer ("01", 0, 1, 1);
			check_decode_existing_buffer ("01FFFFFF", 0, 1, 1);
			check_decode_existing_buffer ("FFFFFF01", 3, -1, 1);
			check_decode_existing_buffer ("FFFFFF01", 4, -1, 0, true);
		});

		GLib.Test.add_func ("/protobuf-vala/decode/corrupted_streams", () => {
			// Test varint overflow (> 10 bytes with 0x80 continuation bit)
			var b1 = string_to_buffer ("808080808080808080808080");
			var val = b1.decode_varint ();
			assert_true (b1.error);
			assert_true (val == 0);

			// Test invalid wire type (wire type 7 -> field key 0F)
			var b2 = string_to_buffer ("0F");
			var uf = b2.decode_unknown_field (0x0F);
			assert_true (b2.error);
		});

		return GLib.Test.run ();
	}

	private static void check_decode_varint (string data, uint64 expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_varint ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static void check_decode_double (string data, double expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_double ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static void check_decode_float (string data, float expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_float ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static void check_decode_int64 (string data, int64 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_int64 ();
		assert_true (!buffer.error);
		assert_true (result == expected);
	}

	private static void check_decode_uint64 (string data, uint64 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_uint64 ();
		assert_true (!buffer.error);
		assert_true (result == expected);
	}

	private static void check_decode_int32 (string data, int32 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_int32 ();
		assert_true (!buffer.error);
		assert_cmpint (result, CompareOperator.EQ, expected);
	}

	private static void check_decode_fixed64 (string data, uint64 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_fixed64 ();
		assert_true (!buffer.error);
		assert_true (result == expected);
	}

	private static void check_decode_fixed32 (string data, uint32 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_fixed32 ();
		assert_true (!buffer.error);
		assert_cmpint ((int) result, CompareOperator.EQ, (int) expected);
	}

	private static void check_decode_bool (string data, bool expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_bool ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static void check_decode_string (string data, size_t length, string expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_string (length);
		assert_true (buffer.error == error);
		if (!error) assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_decode_bytes (string data, size_t length, string expected, bool error = false) {
		var buffer = string_to_buffer (data);
		var r = buffer.decode_bytes (length);
		var result = array_to_string (r.data);
		assert_true (buffer.error == error);
		if (!error) assert_cmpstr (result, CompareOperator.EQ, expected);
	}

	private static void check_decode_uint32 (string data, uint32 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_uint32 ();
		assert_true (!buffer.error);
		assert_cmpint ((int) result, CompareOperator.EQ, (int) expected);
	}

	private static void check_decode_sfixed32 (string data, int32 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_sfixed32 ();
		assert_true (!buffer.error);
		assert_cmpint (result, CompareOperator.EQ, expected);
	}

	private static void check_decode_sfixed64 (string data, int64 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_sfixed64 ();
		assert_true (!buffer.error);
		assert_true (result == expected);
	}

	private static void check_decode_sint32 (string data, int32 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_sint32 ();
		assert_true (!buffer.error);
		assert_cmpint (result, CompareOperator.EQ, expected);
	}

	private static void check_decode_sint64 (string data, int64 expected) {
		var buffer = string_to_buffer (data);
		var result = buffer.decode_sint64 ();
		assert_true (!buffer.error);
		assert_true (result == expected);
	}

	private static void check_decode_enum_message (string data, Test.Vala.Enum enum_value, Test.Vala.Enum enum_value_o, Test.Vala.Enum enum_value_od, bool error = false) {
		var result = new Test.Vala.EnumMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			assert_cmpint ((int) result.enum_value, CompareOperator.EQ, (int) enum_value);
			assert_cmpint ((int) result.enum_value_o, CompareOperator.EQ, (int) enum_value_o);
			assert_cmpint ((int) result.enum_value_od, CompareOperator.EQ, (int) enum_value_od);
		}
	}

	private static void check_decode_message (string data, bool error = false) {
		var result = new Test.Vala.Message ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			var result_value_bytes = array_to_string (result.value_bytes.data);
			assert_cmpint (result.value_int32, CompareOperator.EQ, -1);
			assert_cmpint ((int) result.value_uint32, CompareOperator.EQ, 1);
			assert_cmpint (result.value_sint32, CompareOperator.EQ, -1);
			assert_cmpint ((int) result.value_fixed32, CompareOperator.EQ, 1);
			assert_cmpint (result.value_sfixed32, CompareOperator.EQ, -1);
			assert_true (result.value_int64 == -1);
			assert_true (result.value_uint64 == 1);
			assert_true (result.value_sint64 == -1);
			assert_true (result.value_fixed64 == 1);
			assert_true (result.value_sfixed64 == -1);
			assert_true (result.value_bool == true);
			assert_cmpint ((int) result.value_enum, CompareOperator.EQ, (int) Test.Vala.Enum.ONE);
			assert_cmpstr (result.value_string, CompareOperator.EQ, "TEST");
			assert_cmpstr (result_value_bytes, CompareOperator.EQ, "BEEF");
			assert_true (result.value_double == 1.0d);
			assert_true (result.value_float == 1.0f);
		}
	}

	private static void check_decode_required_message (string data, int32 int_value, string string_value, bool error = false) {
		var result = new Test.Vala.RequiredMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			assert_cmpint (result.int_value, CompareOperator.EQ, int_value);
			assert_cmpstr (result.string_value, CompareOperator.EQ, string_value);
		}
	}

	private static void check_decode_required_message_reencode (string data) {
		var result = new Test.Vala.RequiredMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);

		var encode_buffer = new Google.Protobuf.EncodeBuffer ();
		result.encode (encode_buffer);
		var encode_data = array_to_string (encode_buffer.data);
		assert_cmpstr (encode_data, CompareOperator.EQ, data);
	}

	private static void check_decode_optional_message (string data, int32 int_value, string string_value) {
		var result = new Test.Vala.OptionalMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_cmpint (result.int_value, CompareOperator.EQ, int_value);
		assert_cmpstr (result.string_value, CompareOperator.EQ, string_value);
	}

	private static void check_decode_optional_message_twice (string data1, string data2, int32 int_value, string string_value) {
		var result = new Test.Vala.OptionalMessage ();
		var buffer1 = string_to_buffer (data1);
		result.decode (buffer1);
		var buffer2 = string_to_buffer (data2);
		result.decode (buffer2);
		assert_cmpint (result.int_value, CompareOperator.EQ, int_value);
		assert_cmpstr (result.string_value, CompareOperator.EQ, string_value);
	}

	private static void check_decode_optional_defaults_message (string data, int32 int_value, string string_value) {
		var result = new Test.Vala.OptionalDefaultsMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_cmpint (result.int_value, CompareOperator.EQ, int_value);
		assert_cmpstr (result.string_value, CompareOperator.EQ, string_value);
	}

	private static void check_decode_repeated_message (string data, string expected) {
		var result = new Test.Vala.RepeatedMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (!buffer.error);
		var result_value = "";
		foreach (var v in result.value) {
			if (result_value != "") result_value += " ";
			result_value += "%u".printf (v);
		}
		assert_cmpstr (result_value, CompareOperator.EQ, expected);
	}

	private static void check_decode_repeated_packed_message (string data, string expected) {
		var result = new Test.Vala.RepeatedPackedMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (!buffer.error);
		var result_value = "";
		foreach (var v in result.value) {
			if (result_value != "") result_value += " ";
			result_value += "%u".printf (v);
		}
		assert_cmpstr (result_value, CompareOperator.EQ, expected);
	}

	private static void check_decode_required_nested_message (string data, uint32 value, bool error = false) {
		var result = new Test.Vala.RequiredNestedMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			assert_true (result.child != null);
			assert_cmpint ((int) result.child.value, CompareOperator.EQ, (int) value);
		}
	}

	private static void check_decode_optional_nested_message (string data, uint32? value, bool error = false) {
		var result = new Test.Vala.OptionalNestedMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			uint32? child_value = null;
			if (result.child != null) child_value = result.child.value;
			assert_true (child_value == value);
		}
	}

	private static void check_decode_repeated_nested_message (string data, string expected, bool error = false) {
		var result = new Test.Vala.RepeatedNestedMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_true (buffer.error == error);
		if (!error) {
			var result_value = "";
			foreach (var v in result.children) {
				if (result_value != "") result_value += " ";
				result_value += "%u".printf (v.value);
			}
			assert_cmpstr (result_value, CompareOperator.EQ, expected);
		}
	}

	private static void check_decode_existing_buffer (string data, size_t offset, ssize_t length, uint64 expected, bool error = false) {
		var b = new uint8[data.length / 2];
		for (var i = 0; i < b.length; i++)
			b[i] = str_to_int (data[i * 2]) << 4 | str_to_int (data[i * 2 + 1]);
		var buffer = new Google.Protobuf.DecodeBuffer (b, offset, length);
		var result = buffer.decode_varint ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static Google.Protobuf.DecodeBuffer string_to_buffer (string data) {
		var value = new Google.Protobuf.DecodeBuffer.sized (data.length / 2);
		for (var i = 0; i < value.buffer.length; i++)
			value.buffer[i] = str_to_int (data[i * 2]) << 4 | str_to_int (data[i * 2 + 1]);
		return value;
	}

	private static uint8 str_to_int (char c) {
		if (c >= '0' && c <= '9') return c - '0';
		else if (c >= 'a' && c <= 'f') return c - 'a' + 10;
		else if (c >= 'A' && c <= 'F') return c - 'A' + 10;
		else return 0;
	}

	private static string array_to_string (uint8[] value) {
		var text = "";
		for (var i = 0; i < value.length; i++)
			text += "%02X".printf (value[i]);
		return text;
	}
}
