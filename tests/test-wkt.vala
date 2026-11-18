using Google.Protobuf;

public class TestWkt : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/wkt/timestamp_and_duration", () => {
			check_encode_wkt_message (new GLib.DateTime.from_unix_utc (1000), "0A0308E807");
			check_decode_wkt_message ("0A0308E807", 1000);

			// Timestamp with sub-second nanoseconds (500ms = 500,000 us = 500,000,000 ns)
			var dt_nsec = new GLib.DateTime.from_unix_utc (1000).add_full (0, 0, 0, 0, 0, 0.5);
			check_encode_wkt_message (dt_nsec, "0A0908E8071080CAB5EE01");

			var data = string_to_array ("0A0908E8071080CAB5EE01");
			var buffer = new DecodeBuffer (data);
			var msg = new Test.Wkt.WktMessage.from_data (buffer);
			assert_true (!buffer.error);
			assert_true (msg.timestamp != null);
			assert_true (msg.timestamp.to_unix () == 1000);
			assert_cmpint (msg.timestamp.get_microsecond (), CompareOperator.EQ, 500000);

			// Malformed wire length (0xFFFFFFFFFFFFFFFF) on Duration sets error safely
			var d_bad_dur = string_to_array ("12FFFFFFFFFFFFFFFFFF01");
			var b_bad_dur = new DecodeBuffer (d_bad_dur);
			var m_bad_dur = new Test.Wkt.WktMessage ();
			assert_false (m_bad_dur.decode (b_bad_dur));
			assert_true (b_bad_dur.error);
		});

		GLib.Test.add_func ("/protobuf-vala/wkt/wrappers", () => {
			// Unset wrappers emit nothing
			var msg1 = new Test.Wkt.WrapperMessage ();
			var buf1 = new EncodeBuffer ();
			msg1.encode (buf1);
			assert_cmpstr (buffer_to_string (buf1), CompareOperator.EQ, "");

			// Wrappers set to values emit submessages
			var msg2 = new Test.Wkt.WrapperMessage ();
			msg2.wrp_int32 = 42;
			msg2.wrp_string = "hi";
			msg2.wrp_bool = true;
			var buf2 = new EncodeBuffer ();
			var n2 = msg2.encode (buf2);
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "0A02082A3A02080142040A026869");
			assert_cmpuint ((uint) n2, CompareOperator.EQ, (uint) buf2.data.length);

			// Decode: unset wrappers remain null
			var d1 = string_to_array ("");
			var b1 = new DecodeBuffer (d1);
			var dec1 = new Test.Wkt.WrapperMessage.from_data (b1);
			assert_true (dec1.wrp_int32 == null);
			assert_true (dec1.wrp_string == null);
			assert_true (dec1.wrp_bool == null);

			// Decode: populated wrapper fields unbox properly
			var d2 = string_to_array ("0A02082A3A02080142040A026869");
			var b2 = new DecodeBuffer (d2);
			var dec2 = new Test.Wkt.WrapperMessage.from_data (b2);
			assert_true (dec2.wrp_int32 != null);
			assert_cmpint (dec2.wrp_int32, CompareOperator.EQ, 42);
			assert_true (dec2.wrp_bool != null);
			assert_cmpstr (dec2.wrp_string, CompareOperator.EQ, "hi");

			// Empty wrapper submessages decode to non-null zero values
			var d3 = string_to_array ("0A003A0042004A00");
			var b3 = new DecodeBuffer (d3);
			var dec3 = new Test.Wkt.WrapperMessage.from_data (b3);
			assert_true (!b3.error);
			assert_true (dec3.wrp_int32 != null);
			assert_cmpint (dec3.wrp_int32, CompareOperator.EQ, 0);
			assert_true (dec3.wrp_bool != null);
			assert_false (dec3.wrp_bool);
			assert_true (dec3.wrp_string != null);
			assert_cmpstr (dec3.wrp_string, CompareOperator.EQ, "");
			assert_true (dec3.wrp_bytes != null);
			assert_cmpuint (dec3.wrp_bytes.len, CompareOperator.EQ, 0);
		});

		GLib.Test.add_func ("/protobuf-vala/wkt/field_mask", () => {
			var msg = new Test.Wkt.FieldMaskMessage ();
			msg.update_mask.add ("foo.bar");
			msg.update_mask.add ("baz");
			var buf = new EncodeBuffer ();
			var n = msg.encode (buf);
			// field 1 (FieldMask) -> 0A 0E (len 14): 0A 07 'foo.bar' 0A 03 'baz'
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "0A0E0A07666F6F2E6261720A0362617A");
			assert_cmpuint ((uint) n, CompareOperator.EQ, (uint) buf.data.length);

			var d = string_to_array ("0A0E0A07666F6F2E6261720A0362617A");
			var b = new DecodeBuffer (d);
			var dec = new Test.Wkt.FieldMaskMessage.from_data (b);
			assert_true (!b.error);
			assert_cmpint (dec.update_mask.size, CompareOperator.EQ, 2);
			assert_cmpstr (dec.update_mask.get (0), CompareOperator.EQ, "foo.bar");
			assert_cmpstr (dec.update_mask.get (1), CompareOperator.EQ, "baz");
		});

		GLib.Test.add_func ("/protobuf-vala/wkt/nested_container", () => {
			var container = new Test.Wkt.NestedWktContainer ();
			container.wkt_msg = new Test.Wkt.WktMessage ();
			container.wkt_msg.timestamp = new GLib.DateTime.from_unix_utc (1000);
			container.wrp_msg = new Test.Wkt.WrapperMessage ();
			container.wrp_msg.wrp_int32 = 42;
			container.fm_msg = new Test.Wkt.FieldMaskMessage ();
			container.fm_msg.update_mask.add ("baz");

			var buf = new EncodeBuffer ();
			var n = container.encode (buf);
			assert_cmpuint ((uint) n, CompareOperator.EQ, (uint) buf.data.length);
			// wkt_msg: 0A 05 (0A 03 08 E807)
			// wrp_msg: 12 04 (0A 02 08 2A)
			// fm_msg:  1A 07 (0A 05 0A 03 62617A)
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "0A050A0308E80712040A02082A1A070A050A0362617A");

			var d = string_to_array ("0A050A0308E80712040A02082A1A070A050A0362617A");
			var b = new DecodeBuffer (d);
			var dec = new Test.Wkt.NestedWktContainer.from_data (b);
			assert_true (!b.error);
			assert_true (dec.wkt_msg != null);
			assert_true (dec.wkt_msg.timestamp != null);
			assert_true (dec.wkt_msg.timestamp.to_unix () == 1000);
			assert_true (dec.wrp_msg != null);
			assert_true (dec.wrp_msg.wrp_int32 != null);
			assert_cmpint (dec.wrp_msg.wrp_int32, CompareOperator.EQ, 42);
			assert_true (dec.fm_msg != null);
			assert_cmpint (dec.fm_msg.update_mask.size, CompareOperator.EQ, 1);
			assert_cmpstr (dec.fm_msg.update_mask.get (0), CompareOperator.EQ, "baz");
		});

		GLib.Test.add_func ("/protobuf-vala/wkt/repeated_roundtrip", () => {
			var msg = new Test.Wkt.RepeatedWktMessage ();
			msg.timestamps.append (new GLib.DateTime.from_unix_utc (1000));
			msg.timestamps.append (new GLib.DateTime.from_unix_utc (2000).add_full (0, 0, 0, 0, 0, 0.25));
			msg.durations.append ((GLib.TimeSpan) 0);
			msg.durations.append (2 * GLib.TimeSpan.SECOND + 500000);
			msg.int32_wrappers.append (0);
			msg.int32_wrappers.append (42);
			msg.int64_wrappers.append (-1234567890123LL);
			msg.double_wrappers.append (1.5);
			msg.string_wrappers.append ("");
			msg.string_wrappers.append ("ok");
			var fm1 = new Gee.ArrayList<string> ();
			fm1.add ("a.b");
			var fm2 = new Gee.ArrayList<string> ();
			msg.masks.append (fm1);
			msg.masks.append (fm2);

			var enc = new EncodeBuffer ();
			var n = msg.encode (enc);
			assert_cmpuint ((uint) n, CompareOperator.EQ, (uint) enc.data.length);

			var dec_buf = new DecodeBuffer (enc.data);
			var decoded = new Test.Wkt.RepeatedWktMessage.from_data (dec_buf);
			assert_true (!dec_buf.error);
			assert_cmpuint (decoded.timestamps.length (), CompareOperator.EQ, 2);
			assert_true (decoded.timestamps.nth_data (0).to_unix () == 1000);
			assert_true (decoded.timestamps.nth_data (1).to_unix () == 2000);
			assert_cmpint (decoded.timestamps.nth_data (1).get_microsecond (), CompareOperator.EQ, 250000);

			assert_cmpuint (decoded.durations.length (), CompareOperator.EQ, 2);
			assert_true (decoded.durations.nth_data (0) == 0);
			assert_true (decoded.durations.nth_data (1) == 2 * GLib.TimeSpan.SECOND + 500000);

			assert_cmpuint (decoded.int32_wrappers.length (), CompareOperator.EQ, 2);
			assert_cmpint (decoded.int32_wrappers.nth_data (0), CompareOperator.EQ, 0);
			assert_cmpint (decoded.int32_wrappers.nth_data (1), CompareOperator.EQ, 42);

			assert_cmpuint (decoded.int64_wrappers.length (), CompareOperator.EQ, 1);
			assert_true (decoded.int64_wrappers.nth_data (0) == -1234567890123LL);

			assert_cmpuint (decoded.double_wrappers.length (), CompareOperator.EQ, 1);
			assert_true (decoded.double_wrappers.nth_data (0) == 1.5);

			assert_cmpuint (decoded.string_wrappers.length (), CompareOperator.EQ, 2);
			assert_cmpstr (decoded.string_wrappers.nth_data (0), CompareOperator.EQ, "");
			assert_cmpstr (decoded.string_wrappers.nth_data (1), CompareOperator.EQ, "ok");

			assert_cmpuint (decoded.masks.length (), CompareOperator.EQ, 2);
			assert_cmpint (decoded.masks.nth_data (0).size, CompareOperator.EQ, 1);
			assert_cmpstr (decoded.masks.nth_data (0).get (0), CompareOperator.EQ, "a.b");
			assert_cmpint (decoded.masks.nth_data (1).size, CompareOperator.EQ, 0);

			var s = decoded.to_string ();
			assert_true (s.contains ("timestamps:"));
			assert_true (s.contains ("masks { paths: [\"a.b\"] }"));
		});

		GLib.Test.add_func ("/protobuf-vala/wkt/utf8_validation", () => {
			// Valid multi-byte UTF-8 roundtrips on StringValue and FieldMask
			var wrp_msg = new Test.Wkt.WrapperMessage ();
			wrp_msg.wrp_string = "héllo";
			var wrp_enc = new EncodeBuffer ();
			wrp_msg.encode (wrp_enc);
			var wrp_dbuf = new DecodeBuffer (wrp_enc.data);
			var wrp_dec = new Test.Wkt.WrapperMessage.from_data (wrp_dbuf);
			assert_true (!wrp_dbuf.error);
			assert_cmpstr (wrp_dec.wrp_string, CompareOperator.EQ, "héllo");

			// Invalid UTF-8 in singular StringValue (field 8: 42 04 0A 02 FF FE) fails decode
			var bad_str_wrp = string_to_array ("42040A02FFFE");
			var bad_str_wrp_buf = new DecodeBuffer (bad_str_wrp);
			var bad_str_wrp_msg = new Test.Wkt.WrapperMessage ();
			assert_false (bad_str_wrp_msg.decode (bad_str_wrp_buf));
			assert_true (bad_str_wrp_buf.error);

			// Invalid UTF-8 in repeated StringValue (field 6: 32 04 0A 02 C3 28) fails decode
			var bad_rep_wrp = string_to_array ("32040A02C328");
			var bad_rep_wrp_buf = new DecodeBuffer (bad_rep_wrp);
			var bad_rep_wrp_msg = new Test.Wkt.RepeatedWktMessage ();
			assert_false (bad_rep_wrp_msg.decode (bad_rep_wrp_buf));
			assert_true (bad_rep_wrp_buf.error);

			// Invalid UTF-8 in singular FieldMask (field 1: 0A 04 0A 02 FF FE) fails decode
			var bad_fm = string_to_array ("0A040A02FFFE");
			var bad_fm_buf = new DecodeBuffer (bad_fm);
			var bad_fm_msg = new Test.Wkt.FieldMaskMessage ();
			assert_false (bad_fm_msg.decode (bad_fm_buf));
			assert_true (bad_fm_buf.error);

			// Invalid UTF-8 in repeated FieldMask (field 7: 3A 04 0A 02 C3 28) fails decode
			var bad_rep_fm = string_to_array ("3A040A02C328");
			var bad_rep_fm_buf = new DecodeBuffer (bad_rep_fm);
			var bad_rep_fm_msg = new Test.Wkt.RepeatedWktMessage ();
			assert_false (bad_rep_fm_msg.decode (bad_rep_fm_buf));
			assert_true (bad_rep_fm_buf.error);
		});

		return GLib.Test.run ();
	}

	private static void check_encode_wkt_message (GLib.DateTime dt, string expected) {
		var value = new Test.Wkt.WktMessage ();
		value.timestamp = dt;

		var buffer = new EncodeBuffer ();
		value.encode (buffer);
		assert_cmpstr (buffer_to_string (buffer), CompareOperator.EQ, expected);
	}

	private static void check_decode_wkt_message (string hex, int64 expected_unix_sec) {
		var data = string_to_array (hex);
		var buffer = new DecodeBuffer (data);
		var value = new Test.Wkt.WktMessage.from_data (buffer);

		assert_true (!buffer.error);
		assert_true (value.timestamp != null);
		assert_true (value.timestamp.to_unix () == expected_unix_sec);
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
