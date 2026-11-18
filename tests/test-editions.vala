using Google.Protobuf;

public class TestEditions : Object {
	private static string plugin_path;

	public static int main (string[] args) {
		GLib.Test.init (ref args);

		if (args.length > 1) {
			plugin_path = args[1];
		}

		GLib.Test.add_func ("/protobuf-vala/editions/plugin_capabilities", () => {
			assert_true (plugin_path != null && plugin_path != "");

			// Empty request reports supported_features + min/max edition
			var empty_req = new Compiler.CodeGeneratorRequest ();
			var resp = run_plugin (empty_req);
			assert_cmpstr (resp.error, CompareOperator.EQ, "");
			assert_true ((resp.supported_features & Compiler.CodeGeneratorResponse.Feature.FEATURE_PROTO3_OPTIONAL) != 0);
			assert_true ((resp.supported_features & Compiler.CodeGeneratorResponse.Feature.FEATURE_SUPPORTS_EDITIONS) != 0);
			assert_cmpint (resp.minimum_edition, CompareOperator.EQ, (int32) Edition.EDITION_PROTO2);
			assert_cmpint (resp.maximum_edition, CompareOperator.EQ, (int32) Edition.EDITION_2024);

			// Unsupported future edition returns resp.error
			var bad_req = new Compiler.CodeGeneratorRequest ();
			bad_req.file_to_generate.append ("future.proto");
			var bad_file = new FileDescriptorProto ();
			bad_file.name = "future.proto";
			bad_file.syntax = "editions";
			bad_file.edition = Edition.EDITION_2026;
			bad_req.proto_file.append (bad_file);
			var bad_resp = run_plugin (bad_req);
			assert_true (bad_resp.error != "");
			assert_true (bad_resp.error.contains ("EDITION_2026"));

			// EDITION_UNKNOWN with syntax = "editions" also errors
			var unk_req = new Compiler.CodeGeneratorRequest ();
			unk_req.file_to_generate.append ("unk.proto");
			var unk_file = new FileDescriptorProto ();
			unk_file.name = "unk.proto";
			unk_file.syntax = "editions";
			unk_file.edition = Edition.EDITION_UNKNOWN;
			unk_req.proto_file.append (unk_file);
			var unk_resp = run_plugin (unk_req);
			assert_true (unk_resp.error != "");
		});

		GLib.Test.add_func ("/protobuf-vala/editions/2023_defaults", () => {
			// Unset EXPLICIT fields are null and encode nothing
			var empty = new Test.Editions2023.DefaultsMsg ();
			assert_true (empty.explicit_int == null);
			assert_true (empty.explicit_str == null);
			assert_true (empty.explicit_bytes == null);
			assert_true (empty.explicit_bool == null);
			assert_true (empty.explicit_enum == null);
			assert_true (empty.explicit_dur == null);
			assert_true (empty.explicit_mask == null);
			assert_cmpstr (empty.to_string (), CompareOperator.EQ, "");

			var ebuf = new EncodeBuffer ();
			empty.encode (ebuf);
			assert_cmpstr (buffer_to_string (ebuf), CompareOperator.EQ, "");

			// Explicitly set zero/empty values DO encode and roundtrip as non-null zeros
			var zeroes = new Test.Editions2023.DefaultsMsg ();
			zeroes.explicit_int = 0;
			zeroes.explicit_str = "";
			zeroes.explicit_bytes = new GLib.ByteArray ();
			zeroes.explicit_bool = false;
			zeroes.explicit_enum = Test.Editions2023.OpenEnum.OPEN_ZERO;
			zeroes.explicit_dur = (GLib.TimeSpan) 0;
			zeroes.explicit_mask = new Gee.ArrayList<string> ();
			zeroes.packed_ints.append (1);
			zeroes.packed_ints.append (2);
			zeroes.packed_ints.append (3);

			var zbuf = new EncodeBuffer ();
			zeroes.encode (zbuf);
			// field 1: 08 00
			// field 2: 12 00
			// field 3: 1A 00
			// field 4: 20 00
			// field 5: 28 00
			// field 6: 32 00
			// field 7: 3A 00
			// field 8 (packed): 42 03 01 02 03
			assert_cmpstr (buffer_to_string (zbuf), CompareOperator.EQ, "080012001A002000280032003A004203010203");

			var dz_buf = new DecodeBuffer (zbuf.data);
			var dz = new Test.Editions2023.DefaultsMsg.from_data (dz_buf);
			assert_true (!dz_buf.error);
			assert_true (dz.explicit_int != null && dz.explicit_int == 0);
			assert_true (dz.explicit_str != null && dz.explicit_str == "");
			assert_true (dz.explicit_bytes != null && dz.explicit_bytes.len == 0);
			assert_true (dz.explicit_bool != null && dz.explicit_bool == false);
			assert_true (dz.explicit_enum != null && dz.explicit_enum == Test.Editions2023.OpenEnum.OPEN_ZERO);
			assert_true (dz.explicit_dur != null && dz.explicit_dur == 0);
			assert_true (dz.explicit_mask != null && dz.explicit_mask.size == 0);
			assert_cmpuint (dz.packed_ints.length (), CompareOperator.EQ, 3);
			assert_cmpint (dz.packed_ints.nth_data (0), CompareOperator.EQ, 1);
			assert_cmpint (dz.packed_ints.nth_data (2), CompareOperator.EQ, 3);

			// Packed repeated field also decodes expanded wire format (field 8 wire_type 0: 40 0A 40 14)
			var exp_bytes = string_to_array ("400A4014");
			var exp_buf = new DecodeBuffer (exp_bytes);
			var exp_msg = new Test.Editions2023.DefaultsMsg.from_data (exp_buf);
			assert_true (!exp_buf.error);
			assert_cmpuint (exp_msg.packed_ints.length (), CompareOperator.EQ, 2);
			assert_cmpint (exp_msg.packed_ints.nth_data (0), CompareOperator.EQ, 10);
			assert_cmpint (exp_msg.packed_ints.nth_data (1), CompareOperator.EQ, 20);

			// OPEN enum accepts unknown value 99 (field 5: 28 63)
			var open_bytes = string_to_array ("2863");
			var open_buf = new DecodeBuffer (open_bytes);
			var open_msg = new Test.Editions2023.DefaultsMsg.from_data (open_buf);
			assert_true (!open_buf.error);
			assert_true (open_msg.explicit_enum != null);
			assert_cmpint ((int) open_msg.explicit_enum, CompareOperator.EQ, 99);

			// VERIFY UTF-8 accepts valid UTF-8 and rejects invalid UTF-8
			var valid_utf8 = new Test.Editions2023.DefaultsMsg ();
			valid_utf8.explicit_str = "héllo";
			valid_utf8.rep_strs.append ("world");
			valid_utf8.str_map.set ("k1", "v1");
			var vbuf = new EncodeBuffer ();
			valid_utf8.encode (vbuf);
			var dv_buf = new DecodeBuffer (vbuf.data);
			var dv = new Test.Editions2023.DefaultsMsg.from_data (dv_buf);
			assert_true (!dv_buf.error);
			assert_cmpstr (dv.explicit_str, CompareOperator.EQ, "héllo");
			assert_cmpstr (dv.str_map.get ("k1"), CompareOperator.EQ, "v1");

			// Invalid UTF-8 in singular string (field 2: 12 02 FF FE)
			var bad_str_bytes = string_to_array ("1202FFFE");
			var bad_str_buf = new DecodeBuffer (bad_str_bytes);
			var bad_str_msg = new Test.Editions2023.DefaultsMsg ();
			assert_false (bad_str_msg.decode (bad_str_buf));
			assert_true (bad_str_buf.error);

			// Invalid UTF-8 in repeated string (field 9: 4A 02 C3 28)
			var bad_rep_bytes = string_to_array ("4A02C328");
			var bad_rep_buf = new DecodeBuffer (bad_rep_bytes);
			var bad_rep_msg = new Test.Editions2023.DefaultsMsg ();
			assert_false (bad_rep_msg.decode (bad_rep_buf));
			assert_true (bad_rep_buf.error);

			// Invalid UTF-8 in map key (field 10: 52 08 0A 01 FF 12 03 61 62 63)
			var bad_mk_bytes = string_to_array ("52080A01FF1203616263");
			var bad_mk_buf = new DecodeBuffer (bad_mk_bytes);
			var bad_mk_msg = new Test.Editions2023.DefaultsMsg ();
			assert_false (bad_mk_msg.decode (bad_mk_buf));
			assert_true (bad_mk_buf.error);

			// Invalid UTF-8 in map value (field 10: 52 06 0A 01 61 12 01 FF)
			var bad_mv_bytes = string_to_array ("52060A01611201FF");
			var bad_mv_buf = new DecodeBuffer (bad_mv_bytes);
			var bad_mv_msg = new Test.Editions2023.DefaultsMsg ();
			assert_false (bad_mv_msg.decode (bad_mv_buf));
			assert_true (bad_mv_buf.error);

			// Invalid UTF-8 in FieldMask (field 7: 3A 04 0A 02 FF FE)
			var bad_fm_bytes = string_to_array ("3A040A02FFFE");
			var bad_fm_buf = new DecodeBuffer (bad_fm_bytes);
			var bad_fm_msg = new Test.Editions2023.DefaultsMsg ();
			assert_false (bad_fm_msg.decode (bad_fm_buf));
			assert_true (bad_fm_buf.error);
		});

		GLib.Test.add_func ("/protobuf-vala/editions/presence_and_inheritance", () => {
			var msg = new Test.Editions2023.ImplicitMsg ();
			assert_cmpint (msg.imp_int, CompareOperator.EQ, 0);
			assert_cmpstr (msg.imp_str, CompareOperator.EQ, "");
			assert_true (msg.imp_dur == 0);
			assert_true (msg.field_explicit_int == null);
			assert_cmpint (msg.req_int, CompareOperator.EQ, 0);
			assert_cmpstr (msg.req_str, CompareOperator.EQ, "");
			assert_true (msg.req_sub != null);

			// Implicit empty/zero fields are omitted, while LEGACY_REQUIRED zero/empty fields ARE emitted
			msg.imp_bytes = new GLib.ByteArray ();
			var buf = new EncodeBuffer ();
			msg.encode (buf);
			// field 8 (req_int=0): 40 00
			// field 9 (req_str=""): 4A 00
			// field 10 (req_sub={}): 52 00
			assert_cmpstr (buffer_to_string (buf), CompareOperator.EQ, "40004A005200");

			// Missing required field fails decode
			var missing_bytes = string_to_array ("40004A00");
			var missing_buf = new DecodeBuffer (missing_bytes); // missing field 10
			var missing_msg = new Test.Editions2023.ImplicitMsg ();
			assert_false (missing_msg.decode (missing_buf));
			assert_true (missing_buf.error);

			// Complete required fields + expanded & packed overrides + field-level explicit 0
			msg.field_explicit_int = 0;
			msg.expanded_ints.append (1);
			msg.expanded_ints.append (2);
			msg.field_packed_ints.append (3);
			msg.field_packed_ints.append (4);
			var buf2 = new EncodeBuffer ();
			msg.encode (buf2);
			// field 5 (expanded): 28 01 28 02
			// field 6 (explicit 0): 30 00
			// field 7 (packed): 3A 02 03 04
			// field 8..10: 40 00 4A 00 52 00
			assert_cmpstr (buffer_to_string (buf2), CompareOperator.EQ, "2801280230003A02030440004A005200");

			var d2_buf = new DecodeBuffer (buf2.data);
			var d2 = new Test.Editions2023.ImplicitMsg.from_data (d2_buf);
			assert_true (!d2_buf.error);
			assert_true (d2.field_explicit_int != null && d2.field_explicit_int == 0);
			assert_cmpuint (d2.expanded_ints.length (), CompareOperator.EQ, 2);
			assert_cmpuint (d2.field_packed_ints.length (), CompareOperator.EQ, 2);
		});

		GLib.Test.add_func ("/protobuf-vala/editions/closed_enums", () => {
			// Known values decode normally (plus alias CLOSED_ALIAS = 1)
			// field 1: 08 01, field 2 (packed): 12 02 01 02, field 3 (req): 18 02, field 4 (nested closed): 20 01, field 5 (open): 28 63
			var d_ok_bytes = string_to_array ("080112020102180220012863");
			var d_ok_buf = new DecodeBuffer (d_ok_bytes);
			var m_ok = new Test.Editions2023.ClosedScopeMsg.from_data (d_ok_buf);
			assert_true (!d_ok_buf.error);
			assert_true (m_ok.closed_singular == Test.Editions2023.ClosedEnum.CLOSED_ONE);
			assert_cmpuint (m_ok.closed_rep.length (), CompareOperator.EQ, 2);
			assert_true (m_ok.closed_req == Test.Editions2023.ClosedEnum.CLOSED_TWO);
			assert_true (m_ok.nested_closed == Test.Editions2023.ClosedScopeMsg.NestedClosedEnum.NC_ONE);
			// explicit_open references OPEN enum from inside CLOSED message scope -> keeps 99!
			assert_true (m_ok.explicit_open != null && (int) m_ok.explicit_open == 99);

			// Unknown values for CLOSED enums route to unknown_fields:
			// field 1 = 99 (08 63), field 2 packed = [1, 77, 2] (12 03 01 4D 02), field 3 = 1 (18 01), field 4 = 55 (20 37)
			var d_unk_bytes = string_to_array ("08631203014D0218012037");
			var d_unk_buf = new DecodeBuffer (d_unk_bytes);
			var m_unk = new Test.Editions2023.ClosedScopeMsg.from_data (d_unk_buf);
			assert_true (!d_unk_buf.error);
			assert_true (m_unk.closed_singular == null);
			assert_true (m_unk.nested_closed == null);
			assert_cmpuint (m_unk.closed_rep.length (), CompareOperator.EQ, 2);
			assert_true (m_unk.closed_rep.nth_data (0) == Test.Editions2023.ClosedEnum.CLOSED_ONE);
			assert_true (m_unk.closed_rep.nth_data (1) == Test.Editions2023.ClosedEnum.CLOSED_TWO);

			// Re-encoding preserves unknown enum values from unknown_fields!
			var re_buf = new EncodeBuffer ();
			m_unk.encode (re_buf);
			// Verify decoding again still produces same known fields and unknown fields preserved
			var hex = buffer_to_string (re_buf);
			assert_true (hex.contains ("0863"));
			assert_true (hex.contains ("104D"));
			assert_true (hex.contains ("2037"));

			// Required closed enum receiving unknown value 88 (18 58) does NOT satisfy presence -> decode fails
			var d_req_unk_bytes = string_to_array ("1858");
			var d_req_unk = new DecodeBuffer (d_req_unk_bytes);
			var m_req_unk = new Test.Editions2023.ClosedScopeMsg ();
			assert_false (m_req_unk.decode (d_req_unk));
			assert_true (d_req_unk.error);
		});

		GLib.Test.add_func ("/protobuf-vala/editions/utf8_validation_none", () => {
			// field 1: FF FE, field 2 map: key=FF, val=C3 28, field 3 StringValue: FF FE, field 4 FieldMask: C3 28
			var raw_bytes = string_to_array ("0A02FFFE12070A01FF1202C3281A040A02FFFE22040A02C328");
			var dbuf = new DecodeBuffer (raw_bytes);
			var msg = new Test.Editions2023.Utf8NoneMsg.from_data (dbuf);
			assert_true (!dbuf.error);
			assert_true (msg.raw_str != null);
			assert_cmpint (msg.raw_str.length, CompareOperator.EQ, 2);
			assert_cmpint (msg.raw_map.size, CompareOperator.EQ, 1);
			assert_true (msg.raw_str_wrp != null);
			assert_cmpint (msg.raw_str_wrp.length, CompareOperator.EQ, 2);
			assert_true (msg.raw_mask != null);
			assert_cmpint (msg.raw_mask.size, CompareOperator.EQ, 1);
			assert_cmpint (msg.raw_mask.get (0).length, CompareOperator.EQ, 2);

			var ebuf = new EncodeBuffer ();
			msg.encode (ebuf);
			var dbuf2 = new DecodeBuffer (ebuf.data);
			var msg2 = new Test.Editions2023.Utf8NoneMsg.from_data (dbuf2);
			assert_true (!dbuf2.error);
			assert_cmpint (msg2.raw_str.length, CompareOperator.EQ, 2);
			assert_cmpint (msg2.raw_map.size, CompareOperator.EQ, 1);
			assert_cmpint (msg2.raw_str_wrp.length, CompareOperator.EQ, 2);
			assert_cmpint (msg2.raw_mask.size, CompareOperator.EQ, 1);
		});

		GLib.Test.add_func ("/protobuf-vala/editions/2024_file_inheritance", () => {
			var msg = new Test.Editions2024.Ed2024Msg ();
			assert_true (msg.count == null);
			msg.count = 0;
			msg.file_expanded.append (10);
			msg.file_expanded.append (20);
			msg.kind = (Test.Editions2024.Ed2024Enum) 42;
			var ebuf = new EncodeBuffer ();
			msg.encode (ebuf);
			// field 1: 08 00
			// field 4 (file-level EXPANDED): 20 0A 20 14
			// field 5: 28 2A
			assert_cmpstr (buffer_to_string (ebuf), CompareOperator.EQ, "0800200A2014282A");

			// field 2 (raw_text inherits file-level utf8_validation = NONE) accepts invalid UTF-8 (12 01 FF)
			var ok_raw_bytes = string_to_array ("1201FF");
			var ok_raw = new DecodeBuffer (ok_raw_bytes);
			var m1 = new Test.Editions2024.Ed2024Msg.from_data (ok_raw);
			assert_true (!ok_raw.error);
			assert_true (m1.raw_text != null && m1.raw_text.length == 1);

			// field 3 (strict_text overrides to VERIFY) rejects invalid UTF-8 (1A 01 FF)
			var bad_strict_bytes = string_to_array ("1A01FF");
			var bad_strict = new DecodeBuffer (bad_strict_bytes);
			var m2 = new Test.Editions2024.Ed2024Msg ();
			assert_false (m2.decode (bad_strict));
			assert_true (bad_strict.error);
		});

		GLib.Test.add_func ("/protobuf-vala/editions/delimited_encoding", () => {
			var msg = new Test.Editions2023.DelimitedMsg ();
			msg.child = new Test.Editions2023.DelimitedChild ();
			msg.child.id = 7;
			msg.child.label = "hi";
			msg.child.nested = new Test.Editions2023.DelimitedChild.NestedDelimited ();
			msg.child.nested.code = 99;
			msg.child.empty_group = new Test.Editions2023.EmptyGroup ();
			msg.after_child = 12;

			var c1 = new Test.Editions2023.DelimitedChild ();
			c1.id = 1;
			var c2 = new Test.Editions2023.DelimitedChild ();
			c2.id = 2;
			msg.children.append (c1);
			msg.children.append (c2);

			msg.req_child.id = 5;

			msg.lp_child = new Test.Editions2023.DelimitedChild ();
			msg.lp_child.id = 8;

			var ebuf = new EncodeBuffer ();
			msg.encode (ebuf);
			var hex = buffer_to_string (ebuf);
			// field 1 start group = (1<<3)|3 = 0x0B, end group = (1<<3)|4 = 0x0C
			// nested field 3 start = 0x1B, code=99 (08 63), end = 0x1C
			// empty_group field 4 start = 0x23, end = 0x24
			// after_child field 2 = 10 0C
			// children field 3 start = 0x1B, end = 0x1C
			// req_child field 4 start = 0x23, end = 0x24
			// lp_child field 5 length-prefixed = 2A 02 08 08
			assert_cmpstr (
				hex,
				CompareOperator.EQ,
				"0B0807120268691B08631C23240C100C1B08011C1B08021C230805242A020808"
			);

			var dbuf = new DecodeBuffer (ebuf.data);
			var dec = new Test.Editions2023.DelimitedMsg.from_data (dbuf);
			assert_true (!dbuf.error);
			assert_true (dec.child != null);
			assert_cmpint (dec.child.id, CompareOperator.EQ, 7);
			assert_cmpstr (dec.child.label, CompareOperator.EQ, "hi");
			assert_true (dec.child.nested != null && dec.child.nested.code == 99);
			assert_true (dec.child.empty_group != null);
			assert_true (dec.after_child != null && dec.after_child == 12);
			assert_cmpuint (dec.children.length (), CompareOperator.EQ, 2);
			assert_cmpint (dec.children.nth_data (0).id, CompareOperator.EQ, 1);
			assert_cmpint (dec.children.nth_data (1).id, CompareOperator.EQ, 2);
			assert_cmpint (dec.req_child.id, CompareOperator.EQ, 5);
			assert_true (dec.lp_child != null && dec.lp_child.id == 8);

			// Truncated delimited group (missing END_GROUP 0C) fails decode
			var trunc_bytes = string_to_array ("0B080723080524");
			var trunc_buf = new DecodeBuffer (trunc_bytes);
			var m_trunc = new Test.Editions2023.DelimitedMsg ();
			assert_false (m_trunc.decode (trunc_buf));
			assert_true (trunc_buf.error);

			// Mismatched END_GROUP tag (starts field 1 = 0B, ends field 2 = 14) fails decode
			var mismatch_bytes = string_to_array ("0B08071423080524");
			var mismatch_buf = new DecodeBuffer (mismatch_bytes);
			var m_mismatch = new Test.Editions2023.DelimitedMsg ();
			assert_false (m_mismatch.decode (mismatch_buf));
			assert_true (mismatch_buf.error);

			// Unexpected END_GROUP inside LENGTH_PREFIXED field 5 (2A 01 0C) fails decode
			var unexp_bytes = string_to_array ("230805242A010C");
			var unexp_buf = new DecodeBuffer (unexp_bytes);
			var m_unexp = new Test.Editions2023.DelimitedMsg ();
			assert_false (m_unexp.decode (unexp_buf));
			assert_true (unexp_buf.error);

			// Unknown wire_type 3 group (field 99: (99<<3)|3 = 795 = 9B 06, end = 796 = 9C 06) before field 4 is skipped and preserved
			var unk_grp_hex = "9B0608011B08021C9C0623080524";
			var unk_bytes = string_to_array (unk_grp_hex);
			var unk_buf = new DecodeBuffer (unk_bytes);
			var m_unk_grp = new Test.Editions2023.DelimitedMsg.from_data (unk_buf);
			assert_true (!unk_buf.error);
			assert_cmpint (m_unk_grp.req_child.id, CompareOperator.EQ, 5);
			var unk_re = new EncodeBuffer ();
			m_unk_grp.encode (unk_re);
			assert_cmpstr (buffer_to_string (unk_re), CompareOperator.EQ, "230805249B0608011B08021C9C06");
		});

		return GLib.Test.run ();
	}

	private static Compiler.CodeGeneratorResponse run_plugin (Compiler.CodeGeneratorRequest req) {
		var req_buf = new EncodeBuffer ();
		req.encode (req_buf);
		try {
			var proc = new GLib.Subprocess (
				GLib.SubprocessFlags.STDIN_PIPE | GLib.SubprocessFlags.STDOUT_PIPE,
				plugin_path
			);
			GLib.Bytes? stdout_bytes = null;
			GLib.Bytes? stderr_bytes = null;
			var stdin_bytes = new GLib.Bytes (req_buf.data);
			proc.communicate (stdin_bytes, null, out stdout_bytes, out stderr_bytes);
			assert_true (proc.get_successful ());
			uint8[] resp_data = stdout_bytes.get_data ();
			var resp_buf = new DecodeBuffer (resp_data);
			var resp = new Compiler.CodeGeneratorResponse.from_data (resp_buf);
			assert_true (!resp_buf.error);
			return resp;
		} catch (Error e) {
			assert_not_reached ();
		}
	}

	private static string buffer_to_string (EncodeBuffer buffer) {
		var text = new StringBuilder ();
		foreach (var c in buffer.data)
			text.append_printf ("%02X", c);
		return text.str;
	}

	private static uint8[] string_to_array (string data) {
		var array = new uint8[data.length / 2];
		for (var i = 0; i < data.length; i += 2) {
			var v = 0;
			for (var j = 0; j < 2; j++) {
				var c = data[i + j];
				v <<= 4;
				if (c >= '0' && c <= '9')
					v |= c - '0';
				else if (c >= 'A' && c <= 'F')
					v |= c - 'A' + 10;
				else if (c >= 'a' && c <= 'f')
					v |= c - 'a' + 10;
			}
			array[i / 2] = (uint8) v;
		}
		return array;
	}
}
