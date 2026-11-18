using Google.Protobuf;

public class TestMaps : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/maps/basic_scalar_map", () => {
			check_encode_map_message ("foo", 42, "0A070A03666F6F102A");
			check_decode_map_message ("0A070A03666F6F102A", "foo", 42);

			// Malformed wire length (0xFFFFFFFFFFFFFFFF) on map entry sets error safely
			var d_bad_map = string_to_array ("0AFFFFFFFFFFFFFFFFFF01");
			var b_bad_map = new DecodeBuffer (d_bad_map);
			var m_bad_map = new Test.Maps.MapMessage ();
			assert_false (m_bad_map.decode (b_bad_map));
			assert_true (b_bad_map.error);
		});

		GLib.Test.add_func ("/protobuf-vala/maps/missing_value_default", () => {
			// field 3 (bool_to_msg): tag 0x1A, len 2, key=true (08 01), no value tag
			var d = string_to_array ("1A020801");
			var b = new DecodeBuffer (d);
			var msg = new Test.Maps.ExtendedMapMessage.from_data (b);
			assert_true (!b.error);
			assert_true (msg.bool_to_msg.has_key (true));
			assert_true (msg.bool_to_msg.get (true) != null);
			assert_cmpint (msg.bool_to_msg.get (true).int_value, CompareOperator.EQ, 0);
		});

		GLib.Test.add_func ("/protobuf-vala/maps/nested_container", () => {
			var container = new Test.Maps.NestedMapContainer ();
			container.map_msg = new Test.Maps.MapMessage ();
			container.map_msg.string_to_int.set ("foo", 42);

			var buf = new EncodeBuffer ();
			var n = container.encode (buf);
			assert_cmpuint ((uint) n, CompareOperator.EQ, (uint) buf.data.length);
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "0A090A070A03666F6F102A");

			var d = string_to_array ("0A090A070A03666F6F102A");
			var b = new DecodeBuffer (d);
			var dec = new Test.Maps.NestedMapContainer.from_data (b);
			assert_true (!b.error);
			assert_true (dec.map_msg != null);
			assert_cmpint (dec.map_msg.string_to_int.get ("foo"), CompareOperator.EQ, 42);
		});

		GLib.Test.add_func ("/protobuf-vala/maps/extended_and_wkt_roundtrip", () => {
			var msg = new Test.Maps.ExtendedMapMessage ();
			msg.int64_to_string.set (1234567890123LL, "big");
			msg.int64_to_string.set (-42LL, "neg");
			msg.uint64_to_double.set (0xFFFFFFFF00000001ULL, 3.25);

			var sc = new Test.Maps.MapChildMessage ();
			sc.int_value = 7;
			sc.string_value = "sev";
			msg.bool_to_msg.set (true, sc);
			msg.bool_to_msg.set (false, new Test.Maps.MapChildMessage ());

			msg.str_to_ts.set ("now", new GLib.DateTime.from_unix_utc (1000).add_full (0, 0, 0, 0, 0, 0.5));
			msg.str_to_dur.set ("wait", GLib.TimeSpan.SECOND + 1000);
			msg.str_to_int32_wrp.set ("zero", 0);
			msg.str_to_int32_wrp.set ("val", 99);
			msg.str_to_int64_wrp.set ("big", 9876543210987LL);
			var fm = new Gee.ArrayList<string> ();
			fm.add ("foo.bar");
			msg.str_to_mask.set ("mask", fm);

			// Exercise to_string before encode (including empty message value)
			var s = msg.to_string ();
			assert_true (s.contains ("int64_to_string"));
			assert_true (s.contains ("bool_to_msg"));
			assert_true (s.contains ("value {"));
			assert_true (s.contains ("str_to_mask"));

			var enc = new EncodeBuffer ();
			var n = msg.encode (enc);
			assert_cmpuint ((uint) n, CompareOperator.EQ, (uint) enc.data.length);

			var dec_buf = new DecodeBuffer (enc.data);
			var decoded = new Test.Maps.ExtendedMapMessage.from_data (dec_buf);
			assert_true (!dec_buf.error);

			assert_true (decoded.int64_to_string.has_key (1234567890123LL));
			assert_cmpstr (decoded.int64_to_string.get (1234567890123LL), CompareOperator.EQ, "big");
			assert_cmpstr (decoded.int64_to_string.get (-42LL), CompareOperator.EQ, "neg");

			assert_true (decoded.uint64_to_double.has_key (0xFFFFFFFF00000001ULL));
			assert_true (decoded.uint64_to_double.get (0xFFFFFFFF00000001ULL) == 3.25);

			assert_true (decoded.bool_to_msg.has_key (true));
			assert_true (decoded.bool_to_msg.get (true) != null);
			assert_cmpint (decoded.bool_to_msg.get (true).int_value, CompareOperator.EQ, 7);
			assert_cmpstr (decoded.bool_to_msg.get (true).string_value, CompareOperator.EQ, "sev");
			assert_true (decoded.bool_to_msg.has_key (false));
			assert_true (decoded.bool_to_msg.get (false) != null);

			assert_true (decoded.str_to_ts.has_key ("now"));
			assert_true (decoded.str_to_ts.get ("now").to_unix () == 1000);
			assert_cmpint (decoded.str_to_ts.get ("now").get_microsecond (), CompareOperator.EQ, 500000);

			assert_true (decoded.str_to_dur.has_key ("wait"));
			assert_true (decoded.str_to_dur.get ("wait") == GLib.TimeSpan.SECOND + 1000);

			assert_true (decoded.str_to_int32_wrp.has_key ("zero"));
			assert_cmpint (decoded.str_to_int32_wrp.get ("zero"), CompareOperator.EQ, 0);
			assert_cmpint (decoded.str_to_int32_wrp.get ("val"), CompareOperator.EQ, 99);

			assert_true (decoded.str_to_int64_wrp.has_key ("big"));
			assert_true (decoded.str_to_int64_wrp.get ("big") == 9876543210987LL);

			assert_true (decoded.str_to_mask.has_key ("mask"));
			assert_cmpint (decoded.str_to_mask.get ("mask").size, CompareOperator.EQ, 1);
			assert_cmpstr (decoded.str_to_mask.get ("mask").get (0), CompareOperator.EQ, "foo.bar");
		});

		GLib.Test.add_func ("/protobuf-vala/maps/utf8_validation", () => {
			// Invalid UTF-8 in map string key (field 1: 0A 06 0A 02 FF FE 10 01) fails decode
			var bad_key = string_to_array ("0A060A02FFFE1001");
			var bad_key_buf = new DecodeBuffer (bad_key);
			var bad_key_msg = new Test.Maps.MapMessage ();
			assert_false (bad_key_msg.decode (bad_key_buf));
			assert_true (bad_key_buf.error);

			// Invalid UTF-8 in map string value (field 2: 12 06 08 01 12 02 C3 28) fails decode
			var bad_val = string_to_array ("120608011202C328");
			var bad_val_buf = new DecodeBuffer (bad_val);
			var bad_val_msg = new Test.Maps.MapMessage ();
			assert_false (bad_val_msg.decode (bad_val_buf));
			assert_true (bad_val_buf.error);

			// Invalid UTF-8 in map FieldMask value (field 8: 42 09 0A 01 6B 12 04 0A 02 FF FE) fails decode
			var bad_fm_val = string_to_array ("42090A016B12040A02FFFE");
			var bad_fm_val_buf = new DecodeBuffer (bad_fm_val);
			var bad_fm_val_msg = new Test.Maps.ExtendedMapMessage ();
			assert_false (bad_fm_val_msg.decode (bad_fm_val_buf));
			assert_true (bad_fm_val_buf.error);
		});

		return GLib.Test.run ();
	}

	private static void check_encode_map_message (string key, int32 val, string expected) {
		var value = new Test.Maps.MapMessage ();
		value.string_to_int.set (key, val);

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_map_message (string hex, string expected_key, int32 expected_val) {
		var data = string_to_array (hex);
		var buffer = new DecodeBuffer (data);
		var value = new Test.Maps.MapMessage.from_data (buffer);

		assert_true (!buffer.error);
		assert_true (value.string_to_int.has_key (expected_key));
		assert_cmpint (value.string_to_int.get (expected_key), CompareOperator.EQ, expected_val);
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
