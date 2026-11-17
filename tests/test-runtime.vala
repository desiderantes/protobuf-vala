using Google.Protobuf;

public class TestRuntime : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/runtime/encode_varint", () => {
			check_encode_varint (0, "00");
			check_encode_varint (1, "01");
			check_encode_varint (3, "03");
			check_encode_varint (127, "7F");
			check_encode_varint (128, "8001");
			check_encode_varint (270, "8E02");
			check_encode_varint (16383, "FF7F");
			check_encode_varint (16384, "808001");
			check_encode_varint (86942, "9EA705");
			check_encode_varint (0xFFFFFFFF, "FFFFFFFF0F");
			check_encode_varint (0xFFFFFFFFFFFFFFFF, "FFFFFFFFFFFFFFFFFF01");
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/encode_floating_point", () => {
			check_encode_double (0f, "0000000000000000");
			check_encode_double (-0f, "0000000000000080");
			check_encode_double (1f, "000000000000F03F");
			check_encode_double (-1f, "000000000000F0BF");
			check_encode_double (double.MAX, "FFFFFFFFFFFFEF7F");
			check_encode_double (-double.MAX, "FFFFFFFFFFFFEFFF");
			check_encode_double (double.INFINITY, "000000000000F07F");
			check_encode_double (-double.INFINITY, "000000000000F0FF");

			check_encode_float (0f, "00000000");
			check_encode_float (-0f, "00000080");
			check_encode_float (1f, "0000803F");
			check_encode_float (-1f, "000080BF");
			check_encode_float (float.MAX, "FFFF7F7F");
			check_encode_float (-float.MAX, "FFFF7FFF");
			check_encode_float (float.INFINITY, "0000807F");
			check_encode_float (-float.INFINITY, "000080FF");
			check_encode_float (0.15625f, "0000203E");
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/encode_integers_and_slices", () => {
			check_encode_int64 (0, "00");
			check_encode_int64 (1, "01");
			check_encode_int64 (-1, "FFFFFFFFFFFFFFFFFF01");
			check_encode_int64 (int64.MAX, "FFFFFFFFFFFFFFFF7F");
			check_encode_int64 (int64.MIN, "80808080808080808001");

			check_encode_uint64 (0, "00");
			check_encode_uint64 (1, "01");
			check_encode_uint64 (uint64.MAX, "FFFFFFFFFFFFFFFFFF01");

			check_encode_int32 (0, "00");
			check_encode_int32 (1, "01");
			check_encode_int32 (-1, "FFFFFFFFFFFFFFFFFF01");
			check_encode_int32 (int32.MAX, "FFFFFFFF07");
			check_encode_int32 (int32.MIN, "80808080F8FFFFFFFF01");

			check_encode_fixed64 (0, "0000000000000000");
			check_encode_fixed64 (1, "0100000000000000");
			check_encode_fixed64 (0x0123456789ABCDEF, "EFCDAB8967452301");
			check_encode_fixed64 (uint64.MAX, "FFFFFFFFFFFFFFFF");

			check_encode_fixed32 (0, "00000000");
			check_encode_fixed32 (1, "01000000");
			check_encode_fixed32 (0x01234567, "67452301");
			check_encode_fixed32 (uint32.MAX, "FFFFFFFF");

			check_encode_bool (false, "00");
			check_encode_bool (true, "01");

			check_encode_string ("", "");
			check_encode_string ("123", "313233");

			check_encode_bytes ("", "");
			check_encode_bytes ("AA", "AA");
			check_encode_bytes ("AABBCC", "AABBCC");

			check_encode_uint32 (0, "00");
			check_encode_uint32 (1, "01");
			check_encode_uint32 (uint32.MAX, "FFFFFFFF0F");

			check_encode_sfixed32 (0, "00000000");
			check_encode_sfixed32 (1, "01000000");
			check_encode_sfixed32 (-1, "FFFFFFFF");
			check_encode_sfixed32 (int32.MIN, "00000080");
			check_encode_sfixed32 (int32.MAX, "FFFFFF7F");

			check_encode_sfixed64 (0, "0000000000000000");
			check_encode_sfixed64 (1, "0100000000000000");
			check_encode_sfixed64 (-1, "FFFFFFFFFFFFFFFF");
			check_encode_sfixed64 (int64.MIN, "0000000000000080");
			check_encode_sfixed64 (int64.MAX, "FFFFFFFFFFFFFF7F");

			check_encode_sint32 (0, "00");
			check_encode_sint32 (1, "02");
			check_encode_sint32 (2, "04");
			check_encode_sint32 (-1, "01");
			check_encode_sint32 (-2, "03");
			check_encode_sint32 (int32.MAX, "FEFFFFFF0F");
			check_encode_sint32 (int32.MIN, "FFFFFFFF0F");

			check_encode_sint64 (0, "00");
			check_encode_sint64 (1, "02");
			check_encode_sint64 (2, "04");
			check_encode_sint64 (-1, "01");
			check_encode_sint64 (-2, "03");
			check_encode_sint64 (int64.MAX, "FEFFFFFFFFFFFFFFFF01");
			check_encode_sint64 (int64.MIN, "FFFFFFFFFFFFFFFFFF01");
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/encode_buffer_resize", () => {
			check_buffer_resize (0, 0);
			check_buffer_resize (0, 1);
			check_buffer_resize (2, 0);
			check_buffer_resize (2, 1);
			check_buffer_resize (2, 2);
			check_buffer_resize (2, 3);
			check_buffer_resize (8, 1);
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/formatting_helpers", () => {
			// Test string_to_string escaping both backslashes and double quotes
			assert_cmpstr (Google.Protobuf.string_to_string ("foo\\bar\"baz"), CompareOperator.EQ, "\"foo\\\\bar\\\"baz\"");
			// Test bytes_to_string null safety
			assert_cmpstr (Google.Protobuf.bytes_to_string (null), CompareOperator.EQ, "\"\"");
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/decode_varint", () => {
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

		GLib.Test.add_func ("/protobuf-vala/runtime/decode_floating_point", () => {
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

		GLib.Test.add_func ("/protobuf-vala/runtime/decode_integers_and_slices", () => {
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

		GLib.Test.add_func ("/protobuf-vala/runtime/decode_existing_buffer_slices", () => {
			check_decode_existing_buffer ("", 0, -1, 0, true);
			check_decode_existing_buffer ("01", 0, 0, 0, true);
			check_decode_existing_buffer ("01", 0, -1, 1);
			check_decode_existing_buffer ("01", 0, 1, 1);
			check_decode_existing_buffer ("01FFFFFF", 0, 1, 1);
			check_decode_existing_buffer ("FFFFFF01", 3, -1, 1);
			check_decode_existing_buffer ("FFFFFF01", 4, -1, 0, true);
		});

		GLib.Test.add_func ("/protobuf-vala/runtime/decode_corrupted_streams", () => {
			// Varint overflow (> 10 bytes with 0x80 continuation bit)
			var b1 = string_to_buffer ("808080808080808080808080");
			var val = b1.decode_varint ();
			assert_true (b1.error);
			assert_true (val == 0);

			// Invalid wire type (wire type 7 -> field key 0F)
			var b2 = string_to_buffer ("0F");
			b2.decode_unknown_field (0x0F);
			assert_true (b2.error);

			// Integer overflow protection on size_t.MAX bounds
			var b_str_ovf = string_to_buffer ("31");
			assert_cmpstr (b_str_ovf.decode_string (size_t.MAX), CompareOperator.EQ, "");
			assert_true (b_str_ovf.error);

			var b_bytes_ovf = string_to_buffer ("AA");
			var res_bytes = b_bytes_ovf.decode_bytes (size_t.MAX);
			assert_cmpuint (res_bytes.len, CompareOperator.EQ, 0);
			assert_true (b_bytes_ovf.error);
		});

		return GLib.Test.run ();
	}

	private static void check_encode_varint (uint64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_varint (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_double (double value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_double (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_float (float value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_float (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_int64 (int64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_int64 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_uint64 (uint64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_uint64 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_int32 (int32 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_int32 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_fixed64 (uint64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_fixed64 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_fixed32 (uint32 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_fixed32 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_bool (bool value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_bool (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_string (string value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_string (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_bytes (string value, string expected) {
		var v = new ByteArray.take (string_to_array (value));
		var buffer = new EncodeBuffer ();
		buffer.encode_bytes (v);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_uint32 (uint32 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_uint32 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_sfixed32 (int32 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_sfixed32 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_sfixed64 (int64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_sfixed64 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_sint32 (int32 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_sint32 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_encode_sint64 (int64 value, string expected) {
		var buffer = new EncodeBuffer ();
		buffer.encode_sint64 (value);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_buffer_resize (size_t value_length, size_t buffer_length) {
		var buffer = new EncodeBuffer (buffer_length);
		var value = "";
		for (var i = 0; i < value_length; i++)
			value += "FF";
		var v = new ByteArray.take (string_to_array (value));
		buffer.encode_bytes (v);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, value);
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

	private static void check_decode_existing_buffer (string data, size_t offset, ssize_t length, uint64 expected, bool error = false) {
		var b = string_to_array (data);
		var buffer = new DecodeBuffer (b, offset, length);
		var result = buffer.decode_varint ();
		assert_true (buffer.error == error);
		if (!error) assert_true (result == expected);
	}

	private static DecodeBuffer string_to_buffer (string data) {
		var value = new DecodeBuffer.sized (data.length / 2);
		for (var i = 0; i < value.buffer.length; i++)
			value.buffer[i] = str_to_int (data[i * 2]) << 4 | str_to_int (data[i * 2 + 1]);
		return value;
	}

	private static uint8[] string_to_array (string data) {
		var value = new uint8[data.length / 2];
		for (var i = 0; i < value.length; i++)
			value[i] = str_to_int (data[i * 2]) << 4 | str_to_int (data[i * 2 + 1]);
		return value;
	}

	private static uint8 str_to_int (char c) {
		if (c >= '0' && c <= '9') return c - '0';
		else if (c >= 'a' && c <= 'f') return c - 'a' + 10;
		else if (c >= 'A' && c <= 'F') return c - 'A' + 10;
		else return 0;
	}

	private static string buffer_to_string (EncodeBuffer buffer) {
		return array_to_string (buffer.data);
	}

	private static string array_to_string (uint8[] value) {
		var text = "";
		for (var i = 0; i < value.length; i++)
			text += "%02X".printf (value[i]);
		return text;
	}
}
