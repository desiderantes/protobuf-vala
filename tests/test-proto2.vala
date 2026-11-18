using Google.Protobuf;

public class TestProto2 : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/proto2/scalars", () => {
			var expected = "08FFFFFFFFFFFFFFFFFF011001180125010000002DFFFFFFFF30FFFFFFFFFFFFFFFFFF013801400149010000000000000051FFFFFFFFFFFFFFFF580160016A04544553547202BEEF79000000000000F03F85010000803F";
			check_encode_message (expected);
			check_decode_message (expected);
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/enums", () => {
			check_encode_enum_message (Test.Vala.Enum.ONE, Test.Vala.Enum.ONE, Test.Vala.Enum.ONE, "08011801");
			check_encode_enum_message (Test.Vala.Enum.TWO, Test.Vala.Enum.TWO, Test.Vala.Enum.TWO, "08021002");
			check_encode_enum_message (Test.Vala.Enum.THREE, Test.Vala.Enum.THREE, Test.Vala.Enum.THREE, "080310031803");

			check_decode_enum_message ("08011801", Test.Vala.Enum.ONE, Test.Vala.Enum.ONE, Test.Vala.Enum.ONE);
			check_decode_enum_message ("080110011801", Test.Vala.Enum.ONE, Test.Vala.Enum.ONE, Test.Vala.Enum.ONE);
			check_decode_enum_message ("08021002", Test.Vala.Enum.TWO, Test.Vala.Enum.TWO, Test.Vala.Enum.TWO);
			check_decode_enum_message ("080310031803", Test.Vala.Enum.THREE, Test.Vala.Enum.THREE, Test.Vala.Enum.THREE);

			// Nested, imported, and no-package proto2 enums default to their first enum value (not 0)
			var nested_enum_msg = new Test.Vala.NestedAndImportedEnumMessage ();
			assert_cmpint ((int) nested_enum_msg.local_nested, CompareOperator.EQ, (int) Test.Vala.NestedAndImportedEnumMessage.LocalNestedEnum.LOCAL_FIRST);
			assert_cmpint ((int) nested_enum_msg.no_pkg, CompareOperator.EQ, (int) NoPkgEnum.NOPKG_FIRST);
			assert_cmpint ((int) nested_enum_msg.imp_nested, CompareOperator.EQ, (int) NoPkgOuter.NestedEnum.NESTED_FIRST);
			var nested_enum_buf = new EncodeBuffer ();
			nested_enum_msg.encode (nested_enum_buf);
			assert_cmpstr (buffer_to_string (nested_enum_buf), CompareOperator.EQ, "");
			nested_enum_msg.local_nested = Test.Vala.NestedAndImportedEnumMessage.LocalNestedEnum.LOCAL_SECOND;
			nested_enum_msg.no_pkg = NoPkgEnum.NOPKG_SECOND;
			nested_enum_msg.imp_nested = NoPkgOuter.NestedEnum.NESTED_SECOND;
			nested_enum_buf = new EncodeBuffer ();
			nested_enum_msg.encode (nested_enum_buf);
			assert_cmpstr (buffer_to_string (nested_enum_buf), CompareOperator.EQ, "08051006180A");

			var nested_empty_buf = string_to_buffer ("");
			var nested_empty = new Test.Vala.NestedAndImportedEnumMessage.from_data (nested_empty_buf);
			assert_true (!nested_empty_buf.error);
			assert_cmpint ((int) nested_empty.local_nested, CompareOperator.EQ, (int) Test.Vala.NestedAndImportedEnumMessage.LocalNestedEnum.LOCAL_FIRST);
			assert_cmpint ((int) nested_empty.no_pkg, CompareOperator.EQ, (int) NoPkgEnum.NOPKG_FIRST);
			assert_cmpint ((int) nested_empty.imp_nested, CompareOperator.EQ, (int) NoPkgOuter.NestedEnum.NESTED_FIRST);

			var nested_set_buf = string_to_buffer ("08051006180A");
			var nested_set = new Test.Vala.NestedAndImportedEnumMessage.from_data (nested_set_buf);
			assert_true (!nested_set_buf.error);
			assert_cmpint ((int) nested_set.local_nested, CompareOperator.EQ, (int) Test.Vala.NestedAndImportedEnumMessage.LocalNestedEnum.LOCAL_SECOND);
			assert_cmpint ((int) nested_set.no_pkg, CompareOperator.EQ, (int) NoPkgEnum.NOPKG_SECOND);
			assert_cmpint ((int) nested_set.imp_nested, CompareOperator.EQ, (int) NoPkgOuter.NestedEnum.NESTED_SECOND);
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/required_fields", () => {
			check_encode_required_message (0, "", "08001200");
			check_encode_required_message (1, "TEST", "0802120454455354");

			check_decode_required_message ("", 0, "", true);
			check_decode_required_message ("0800", 0, "", true);
			check_decode_required_message ("1200", 0, "", true);
			check_decode_required_message ("08001200", 0, "");
			check_decode_required_message ("0802120454455354", 1, "TEST");
			check_decode_required_message ("08021204544553541A03313233", 1, "TEST");

			check_decode_required_message_reencode ("0802120454455354");
			check_decode_required_message_reencode ("0802120454455354180125010000002DFFFFFFFF30FFFFFFFFFFFFFFFFFF013801400149010000000000000051FFFFFFFFFFFFFFFF580160016A04544553547202BEEF79000000000000F03F85010000803F");
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/optional_fields", () => {
			check_encode_optional_message (0, "", "");
			check_encode_optional_message (1, "", "0802");
			check_encode_optional_message (0, "TEST", "120454455354");
			check_encode_optional_message (1, "TEST", "0802120454455354");

			check_decode_optional_message ("", 0, "");
			check_decode_optional_message ("0802", 1, "");
			check_decode_optional_message ("120454455354", 0, "TEST");
			check_decode_optional_message ("0802120454455354", 1, "TEST");
			check_decode_optional_message_twice ("120454455354", "0802", 1, "");

			// Proto2 defaults to utf8_validation = NONE: non-UTF-8 string bytes are accepted
			var raw_str_bytes = string_to_buffer ("1202FFFE");
			var raw_str_msg = new Test.Vala.OptionalMessage.from_data (raw_str_bytes);
			assert_true (!raw_str_bytes.error);
			assert_cmpint (raw_str_msg.string_value.length, CompareOperator.EQ, 2);
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/optional_defaults", () => {
			check_encode_optional_defaults_message (0, "", "08001200");
			check_encode_optional_defaults_message (1, "", "1200");
			check_encode_optional_defaults_message (0, "TEST", "0800");
			check_encode_optional_defaults_message (1, "TEST", "");

			check_decode_optional_defaults_message ("08001200", 0, "");
			check_decode_optional_defaults_message ("1200", 1, "");
			check_decode_optional_defaults_message ("0800", 0, "TEST");
			check_decode_optional_defaults_message ("", 1, "TEST");
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/repeated_fields", () => {
			check_encode_repeated_message ("", "");
			check_encode_repeated_message ("1", "0801");
			check_encode_repeated_message ("1 2 3 4", "0801080208030804");

			check_decode_repeated_message ("", "");
			check_decode_repeated_message ("0801", "1");
			check_decode_repeated_message ("0801080208030804", "1 2 3 4");

			check_encode_repeated_packed_message ("", "");
			check_encode_repeated_packed_message ("1", "0A0101");
			check_encode_repeated_packed_message ("1 2 3 4", "0A0401020304");

			check_decode_repeated_packed_message ("", "");
			check_decode_repeated_packed_message ("0A0101", "1");
			check_decode_repeated_packed_message ("0A0401020304", "1 2 3 4");
			check_decode_repeated_packed_message ("0A0201020A020304", "1 2 3 4");
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/nested_messages", () => {
			check_encode_required_nested_message (1, "0A020801");
			check_decode_required_nested_message ("", 0, true);
			check_decode_required_nested_message ("0A00", 0, true);
			check_decode_required_nested_message ("0A020801", 1);

			check_encode_optional_nested_message (null, "");
			check_encode_optional_nested_message (1, "0A020801");
			check_decode_optional_nested_message ("", null);
			check_decode_optional_nested_message ("0A00", 0, true);
			check_decode_optional_nested_message ("0A020801", 1);

			check_encode_repeated_nested_message ("", "");
			check_encode_repeated_nested_message ("1", "0A020801");
			check_encode_repeated_nested_message ("1 2 3", "0A0208010A0208020A020803");
			check_decode_repeated_nested_message ("", "");
			check_decode_repeated_nested_message ("0A00", "", true);
			check_decode_repeated_nested_message ("0A020801", "1");
			check_decode_repeated_nested_message ("0A0208010A0208020A020803", "1 2 3");

			// Null elements inside repeated custom message list must not crash encode or to_string
			var repeated_with_null = new Test.Vala.RepeatedNestedMessage ();
			var placeholder = new Test.Vala.ChildMessage ();
			var child = new Test.Vala.ChildMessage ();
			child.value = 7;
			repeated_with_null.children.append (placeholder);
			repeated_with_null.children.append (child);
			unowned GLib.List<Test.Vala.ChildMessage?> raw_list = repeated_with_null.children;
			raw_list.data = null;
			raw_list.append (null);
			assert_cmpstr (repeated_with_null.to_string (), CompareOperator.EQ, "children {\n  value: 7\n}\n");
			var null_buf = new EncodeBuffer ();
			repeated_with_null.encode (null_buf);
			assert_cmpstr (buffer_to_string (null_buf), CompareOperator.EQ, "0A020807");
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/reserved_keywords", () => {
			var reserved = new Test.Vala.ReservedMessage ();
			reserved.@abstract = 1;
			reserved.@class = 2;
			reserved.@value = 3;
			var buf = new EncodeBuffer ();
			reserved.encode (buf);
			var dec_buf = new DecodeBuffer (buf.data);
			var decoded = new Test.Vala.ReservedMessage.from_data (dec_buf);
			assert_true (!dec_buf.error);
			assert_cmpuint (decoded.@abstract, CompareOperator.EQ, 1);
			assert_cmpuint (decoded.@class, CompareOperator.EQ, 2);
			assert_cmpuint (decoded.@value, CompareOperator.EQ, 3);
		});

		GLib.Test.add_func ("/protobuf-vala/proto2/decode_malformed_streams", () => {
			// Wire length 0xFFFFFFFFFFFFFFFF (-1 as ssize_t) for string, nested message, packed array, and unknown field
			var b_str_wire = string_to_buffer ("12FFFFFFFFFFFFFFFFFF01");
			var m_str = new Test.Vala.OptionalMessage ();
			assert_false (m_str.decode (b_str_wire));
			assert_true (b_str_wire.error);

			var b_nested_wire = string_to_buffer ("0AFFFFFFFFFFFFFFFFFF010801");
			var m_nested = new Test.Vala.OptionalNestedMessage ();
			assert_false (m_nested.decode (b_nested_wire));
			assert_true (b_nested_wire.error);
			if (m_nested.child != null) assert_cmpuint (m_nested.child.value, CompareOperator.EQ, 0);

			var b_packed_wire = string_to_buffer ("0AFFFFFFFFFFFFFFFFFF01");
			var m_packed = new Test.Vala.RepeatedPackedMessage ();
			assert_false (m_packed.decode (b_packed_wire));
			assert_true (b_packed_wire.error);

			var b_unknown_wire = string_to_buffer ("1AFFFFFFFFFFFFFFFFFF01");
			var m_unknown = new Test.Vala.OptionalMessage ();
			assert_false (m_unknown.decode (b_unknown_wire));
			assert_true (b_unknown_wire.error);

			// Out-of-bounds explicit data_length passed to decode ()
			var b_oob = string_to_buffer ("0801");
			var m_oob = new Test.Vala.OptionalMessage ();
			assert_false (m_oob.decode (b_oob, 100));
			assert_true (b_oob.error);
		});

		return GLib.Test.run ();
	}

	private static void check_encode_enum_message (Test.Vala.Enum enum_value, Test.Vala.Enum enum_value_o, Test.Vala.Enum enum_value_od, string expected) {
		var value = new Test.Vala.EnumMessage ();
		value.enum_value = enum_value;
		value.enum_value_o = enum_value_o;
		value.enum_value_od = enum_value_od;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_message (string expected) {
		var value = new Test.Vala.Message ();
		value.value_int32 = -1;
		value.value_uint32 = 1;
		value.value_sint32 = -1;
		value.value_fixed32 = 1;
		value.value_sfixed32 = -1;
		value.value_int64 = -1;
		value.value_uint64 = 1;
		value.value_sint64 = -1;
		value.value_fixed64 = 1;
		value.value_sfixed64 = -1;
		value.value_bool = true;
		value.value_enum = Test.Vala.Enum.ONE;
		value.value_string = "TEST";
		value.value_bytes = new ByteArray.take (string_to_array ("BEEF"));
		value.value_double = 1.0d;
		value.value_float = 1.0f;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_required_message (int32 int_value, string string_value, string expected) {
		var value = new Test.Vala.RequiredMessage ();
		value.int_value = int_value;
		value.string_value = string_value;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

		var encode_buffer = new EncodeBuffer ();
		result.encode (encode_buffer);
		assert_cmpstr (buffer_to_string (encode_buffer), CompareOperator.EQ, data);
	}

	private static void check_encode_optional_message (int32 int_value, string string_value, string expected) {
		var value = new Test.Vala.OptionalMessage ();
		value.int_value = int_value;
		value.string_value = string_value;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_optional_defaults_message (int32 int_value, string string_value, string expected) {
		var value = new Test.Vala.OptionalDefaultsMessage ();
		value.int_value = int_value;
		value.string_value = string_value;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_optional_defaults_message (string data, int32 int_value, string string_value) {
		var result = new Test.Vala.OptionalDefaultsMessage ();
		var buffer = string_to_buffer (data);
		result.decode (buffer);
		assert_cmpint (result.int_value, CompareOperator.EQ, int_value);
		assert_cmpstr (result.string_value, CompareOperator.EQ, string_value);
	}

	private static void check_encode_repeated_message (string repeated_value, string expected) {
		var value = new Test.Vala.RepeatedMessage ();
		var values = repeated_value.split (" ");
		for (var i = 0; i < values.length; i++)
			value.value.append (int.parse (values[i]));

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_repeated_packed_message (string repeated_value, string expected) {
		var value = new Test.Vala.RepeatedPackedMessage ();
		var values = repeated_value.split (" ");
		for (var i = 0; i < values.length; i++)
			value.value.append (int.parse (values[i]));

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_required_nested_message (uint32 v, string expected) {
		var value = new Test.Vala.RequiredNestedMessage ();
		value.child.value = v;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_optional_nested_message (uint32? v, string expected) {
		var value = new Test.Vala.OptionalNestedMessage ();
		if (v != null) {
			value.child = new Test.Vala.ChildMessage ();
			value.child.value = v;
		}

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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

	private static void check_encode_repeated_nested_message (string repeated_value, string expected) {
		var value = new Test.Vala.RepeatedNestedMessage ();
		var values = repeated_value.split (" ");
		for (var i = 0; i < values.length; i++) {
			var m = new Test.Vala.ChildMessage ();
			m.value = int.parse (values[i]);
			value.children.append (m);
		}

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
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
