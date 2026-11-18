using Google.Protobuf;

public class TestProto3 : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/proto3/implicit_scalars", () => {
			check_encode_scalar_message (0, "", "");
			check_encode_scalar_message (5, "hello", "080A120568656C6C6F");

			check_decode_scalar_message ("", 0, "");
			check_decode_scalar_message ("080A120568656C6C6F", 5, "hello");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/implicit_empty_bytes", () => {
			// Non-optional proto3 bytes field set to an empty ByteArray emits nothing
			var msg1 = new Test.Vala3.Message3 ();
			msg1.value_bytes = new GLib.ByteArray ();
			var buf1 = new EncodeBuffer ();
			msg1.encode (buf1);
			assert_cmpstr (buffer_to_string (buf1), CompareOperator.EQ, "");

			// Non-empty bytes field still encodes
			var msg2 = new Test.Vala3.Message3 ();
			var ba2 = new GLib.ByteArray ();
			uint8[] raw = { 0xDE, 0xAD };
			ba2.append (raw);
			msg2.value_bytes = ba2;
			var buf2 = new EncodeBuffer ();
			msg2.encode (buf2);
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "7202DEAD");

			// Explicit optional proto3 bytes set to empty ByteArray DOES emit (field 5: 2A 00)
			var msg3 = new Test.Vala3.OptionalMessage3 ();
			msg3.opt_bytes = new GLib.ByteArray ();
			var buf3 = new EncodeBuffer ();
			msg3.encode (buf3);
			assert_cmpstr (buffer_to_string (buf3), CompareOperator.EQ, "2A00");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/repeated_packing", () => {
			check_encode_repeated_message3 ("1 2 3", "0A03010203");

			// Other field options (like [deprecated = true]) must NOT disable proto3 default packing,
			// while explicit [packed = false] must emit unpacked elements.
			var msg = new Test.Vala3.RepeatedMessage3 ();
			msg.deprecated_packed.append (1);
			msg.deprecated_packed.append (2);
			msg.explicitly_unpacked.append (1);
			msg.explicitly_unpacked.append (2);
			var buf = new EncodeBuffer ();
			msg.encode (buf);
			// field 2 packed: 12 02 01 02
			// field 3 unpacked: 18 01 18 02
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "1202010218011802");

			// Decoding packed repeated scalar field (proto3 default) and unpacked (backward compatibility)
			check_decode_repeated_message3 ("0A03010203", "1 2 3");
			check_decode_repeated_message3 ("080108020803", "1 2 3");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/open_enums", () => {
			check_encode_enum_message3 (Test.Vala3.Enum3.TWO, "0802");
			// Unrecognized open enum value (e.g. 99 = 0x63) re-encodes and formats without crashing
			check_encode_enum_message3 ((Test.Vala3.Enum3) 99, "0863");

			check_decode_enum_message3 ("0802", Test.Vala3.Enum3.TWO);
			var data = string_to_array ("0863");
			var buffer = new DecodeBuffer (data);
			var msg = new Test.Vala3.EnumMessage3.from_data (buffer);
			assert_true (!buffer.error);
			assert_cmpint ((int) msg.enum_value, CompareOperator.EQ, 99);
			assert_cmpstr (msg.enum_value.to_string (), CompareOperator.EQ, "99");
			assert_cmpstr (msg.to_string (), CompareOperator.EQ, "enum_value: 99\n");
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/optional_fields", () => {
			// Unset optional fields emit nothing
			var msg1 = new Test.Vala3.OptionalMessage3 ();
			var buf1 = new EncodeBuffer ();
			msg1.encode (buf1);
			assert_cmpstr (buffer_to_string (buf1), CompareOperator.EQ, "");
			assert_true (msg1.opt_duration == null);
			assert_true (msg1.opt_field_mask == null);
			assert_cmpstr (msg1.to_string (), CompareOperator.EQ, "");

			// Explicitly zero-valued optional field DOES emit on wire
			var msg2 = new Test.Vala3.OptionalMessage3 ();
			msg2.opt_int = 0;
			msg2.opt_duration = (GLib.TimeSpan) 0;
			msg2.opt_field_mask = new Gee.ArrayList<string> ();
			var buf2 = new EncodeBuffer ();
			msg2.encode (buf2);
			// field 1 (0): 0800, field 6 (dur 0): 3200, field 7 (mask empty): 3A00
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "080032003A00");
			assert_true (msg2.to_string ().contains ("opt_duration: 0"));
			assert_true (msg2.to_string ().contains ("opt_field_mask {"));

			// Non-zero optional field emits
			var msg3 = new Test.Vala3.OptionalMessage3 ();
			msg3.opt_int = 42;
			msg3.opt_str = "hi";
			msg3.opt_enum = Test.Vala3.Enum3.ONE;
			msg3.opt_bool = true;
			msg3.opt_duration = 5 * GLib.TimeSpan.SECOND;
			msg3.opt_field_mask = new Gee.ArrayList<string> ();
			msg3.opt_field_mask.add ("a.b");
			var buf3 = new EncodeBuffer ();
			msg3.encode (buf3);
			assert_cmpstr (buffer_to_string (buf3), CompareOperator.EQ, "082A1202686918012001320208053A050A03612E62");

			// Decode: unset fields remain null
			var d1 = string_to_array ("");
			var b1 = new DecodeBuffer (d1);
			var dec1 = new Test.Vala3.OptionalMessage3.from_data (b1);
			assert_true (dec1.opt_int == null);
			assert_true (dec1.opt_str == null);
			assert_true (dec1.opt_enum == null);
			assert_true (dec1.opt_bool == null);
			assert_true (dec1.opt_bytes == null);
			assert_true (dec1.opt_duration == null);
			assert_true (dec1.opt_field_mask == null);

			// Decode: explicit zero values in stream set fields to non-null zero values
			var d2 = string_to_array ("08002A0032003A00");
			var b2 = new DecodeBuffer (d2);
			var dec2 = new Test.Vala3.OptionalMessage3.from_data (b2);
			assert_true (!b2.error);
			assert_true (dec2.opt_int != null);
			assert_cmpint (dec2.opt_int, CompareOperator.EQ, 0);
			assert_true (dec2.opt_bytes != null);
			assert_cmpuint (dec2.opt_bytes.len, CompareOperator.EQ, 0);
			assert_true (dec2.opt_duration != null);
			assert_true (dec2.opt_duration == 0);
			assert_true (dec2.opt_field_mask != null);
			assert_cmpint (dec2.opt_field_mask.size, CompareOperator.EQ, 0);

			// Decode: non-zero values
			var d3 = string_to_array ("082A1202686918012001320208053A050A03612E62");
			var b3 = new DecodeBuffer (d3);
			var dec3 = new Test.Vala3.OptionalMessage3.from_data (b3);
			assert_true (!b3.error);
			assert_true (dec3.opt_int != null);
			assert_cmpint (dec3.opt_int, CompareOperator.EQ, 42);
			assert_cmpstr (dec3.opt_str, CompareOperator.EQ, "hi");
			assert_true (dec3.opt_enum != null);
			assert_true (dec3.opt_bool == true);
			assert_true (dec3.opt_duration != null);
			assert_true (dec3.opt_duration == 5 * GLib.TimeSpan.SECOND);
			assert_true (dec3.opt_field_mask != null);
			assert_cmpint (dec3.opt_field_mask.size, CompareOperator.EQ, 1);
			assert_cmpstr (dec3.opt_field_mask.get (0), CompareOperator.EQ, "a.b");

			// Malformed wire length (0xFFFFFFFFFFFFFFFF) on optional WKT sets error safely
			var d_bad_dur = string_to_array ("32FFFFFFFFFFFFFFFFFF01");
			var b_bad_dur = new DecodeBuffer (d_bad_dur);
			var m_bad_dur = new Test.Vala3.OptionalMessage3 ();
			assert_false (m_bad_dur.decode (b_bad_dur));
			assert_true (b_bad_dur.error);
		});

		GLib.Test.add_func ("/protobuf-vala/proto3/utf8_validation", () => {
			// Valid multi-byte UTF-8 roundtrips on scalar and optional proto3 strings
			var msg = new Test.Vala3.ScalarMessage3 ();
			msg.int_value = 3;
			msg.string_value = "héllo";
			var enc = new EncodeBuffer ();
			msg.encode (enc);
			var dbuf = new DecodeBuffer (enc.data);
			var dec = new Test.Vala3.ScalarMessage3.from_data (dbuf);
			assert_true (!dbuf.error);
			assert_cmpint (dec.int_value, CompareOperator.EQ, 3);
			assert_cmpstr (dec.string_value, CompareOperator.EQ, "héllo");

			// Invalid UTF-8 on proto3 scalar string (field 2: 12 02 FF FE) fails decode
			check_decode_scalar_message ("1202FFFE", 0, "", true);

			// Invalid UTF-8 on proto3 optional string (field 2: 12 02 C3 28) fails decode
			var bad_opt_str_bytes = string_to_array ("1202C328");
			var bad_opt_str_buf = new DecodeBuffer (bad_opt_str_bytes);
			var bad_opt_str_msg = new Test.Vala3.OptionalMessage3 ();
			assert_false (bad_opt_str_msg.decode (bad_opt_str_buf));
			assert_true (bad_opt_str_buf.error);

			// Invalid UTF-8 on proto3 optional FieldMask (field 7: 3A 04 0A 02 FF FE) fails decode
			var bad_opt_fm_bytes = string_to_array ("3A040A02FFFE");
			var bad_opt_fm_buf = new DecodeBuffer (bad_opt_fm_bytes);
			var bad_opt_fm_msg = new Test.Vala3.OptionalMessage3 ();
			assert_false (bad_opt_fm_msg.decode (bad_opt_fm_buf));
			assert_true (bad_opt_fm_buf.error);
		});

		return GLib.Test.run ();
	}

	private static void check_encode_scalar_message (int32 int_value, string string_value, string expected) {
		var value = new Test.Vala3.ScalarMessage3 ();
		value.int_value = int_value;
		value.string_value = string_value;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_scalar_message (string hex, int32 expected_int, string expected_str, bool expect_error = false) {
		var data = string_to_array (hex);
		var buffer = new DecodeBuffer (data);
		var value = new Test.Vala3.ScalarMessage3.from_data (buffer);

		assert_true (buffer.error == expect_error);
		if (!expect_error) {
			assert_cmpint (value.int_value, CompareOperator.EQ, expected_int);
			assert_cmpstr (value.string_value, CompareOperator.EQ, expected_str);
		}
	}

	private static void check_encode_repeated_message3 (string repeated_value, string expected) {
		var value = new Test.Vala3.RepeatedMessage3 ();
		var values = repeated_value.split (" ");
		for (var i = 0; i < values.length; i++)
			value.value.append (int.parse (values[i]));

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_repeated_message3 (string hex, string expected) {
		var data = string_to_array (hex);
		var buffer = new DecodeBuffer (data);
		var value = new Test.Vala3.RepeatedMessage3.from_data (buffer);

		assert_true (!buffer.error);
		var list_str = "";
		foreach (unowned uint32 v in value.value) {
			if (list_str != "") list_str += " ";
			list_str += v.to_string ();
		}
		assert_cmpstr (list_str, CompareOperator.EQ, expected);
	}

	private static void check_encode_enum_message3 (Test.Vala3.Enum3 enum_val, string expected) {
		var value = new Test.Vala3.EnumMessage3 ();
		value.enum_value = enum_val;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_enum_message3 (string hex, Test.Vala3.Enum3 expected) {
		var data = string_to_array (hex);
		var buffer = new DecodeBuffer (data);
		var value = new Test.Vala3.EnumMessage3.from_data (buffer);

		assert_true (!buffer.error);
		assert_cmpint ((int) value.enum_value, CompareOperator.EQ, (int) expected);
	}

	private static string buffer_to_string (EncodeBuffer buffer) {
		var value = "";
		var data = buffer.data;
		for (var i = 0; i < data.length; i++)
			value += "%02X".printf (data[i]);
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
}
