using Google.Protobuf;

private static FieldDescriptorProto make_field (
	string name,
	int32 number,
	FieldDescriptorProto.Type type,
	FieldDescriptorProto.Label label = FieldDescriptorProto.Label.LABEL_OPTIONAL,
	string type_name = "",
	FeatureSet? features = null
) {
	var f = new FieldDescriptorProto ();
	f.name = name;
	f.number = number;
	f.type = type;
	f.label = label;
	f.type_name = type_name;
	if (features != null) {
		f.options = new FieldOptions ();
		f.options.features = features;
	}
	return f;
}

private static void add_map_field (
	DescriptorProto parent,
	string pkg_prefix,
	string name,
	int32 number,
	string entry_name,
	FieldDescriptorProto.Type key_type = FieldDescriptorProto.Type.TYPE_STRING,
	FieldDescriptorProto.Type val_type = FieldDescriptorProto.Type.TYPE_STRING,
	string val_type_name = ""
) {
	var entry = new DescriptorProto ();
	entry.name = entry_name;
	entry.options = new MessageOptions ();
	entry.options.map_entry = true;
	entry.field.append (make_field ("key", 1, key_type));
	entry.field.append (make_field ("value", 2, val_type, FieldDescriptorProto.Label.LABEL_OPTIONAL, val_type_name));
	parent.nested_type.append (entry);

	parent.field.append (make_field (
		name,
		number,
		FieldDescriptorProto.Type.TYPE_MESSAGE,
		FieldDescriptorProto.Label.LABEL_REPEATED,
		"%s.%s.%s".printf (pkg_prefix, parent.name, entry_name)
	));
}

private static EnumValueDescriptorProto make_enum_val (string name, int32 number) {
	var v = new EnumValueDescriptorProto ();
	v.name = name;
	v.number = number;
	return v;
}

private static FileDescriptorProto build_editions2023_file () {
	var file = new FileDescriptorProto ();
	file.name = "editions.proto";
	file.package = "test.editions2023";
	file.syntax = "editions";
	file.edition = Edition.EDITION_2023;

	var open_enum = new EnumDescriptorProto ();
	open_enum.name = "OpenEnum";
	open_enum.value.append (make_enum_val ("OPEN_ZERO", 0));
	open_enum.value.append (make_enum_val ("OPEN_ONE", 1));
	open_enum.value.append (make_enum_val ("OPEN_TWO", 2));
	file.enum_type.append (open_enum);

	var closed_enum = new EnumDescriptorProto ();
	closed_enum.name = "ClosedEnum";
	closed_enum.options = new EnumOptions ();
	closed_enum.options.allow_alias = true;
	closed_enum.options.features = new FeatureSet ();
	closed_enum.options.features.enum_type = FeatureSet.EnumType.CLOSED;
	closed_enum.value.append (make_enum_val ("CLOSED_ZERO", 0));
	closed_enum.value.append (make_enum_val ("CLOSED_ONE", 1));
	closed_enum.value.append (make_enum_val ("CLOSED_ALIAS", 1));
	closed_enum.value.append (make_enum_val ("CLOSED_TWO", 2));
	file.enum_type.append (closed_enum);

	var empty_group = new DescriptorProto ();
	empty_group.name = "EmptyGroup";
	file.message_type.append (empty_group);

	var delimited_child = new DescriptorProto ();
	delimited_child.name = "DelimitedChild";
	var nested_delimited = new DescriptorProto ();
	nested_delimited.name = "NestedDelimited";
	nested_delimited.field.append (make_field ("code", 1, FieldDescriptorProto.Type.TYPE_INT32));
	delimited_child.nested_type.append (nested_delimited);
	delimited_child.field.append (make_field ("id", 1, FieldDescriptorProto.Type.TYPE_INT32));
	delimited_child.field.append (make_field ("label", 2, FieldDescriptorProto.Type.TYPE_STRING));
	var delim_feat = new FeatureSet ();
	delim_feat.message_encoding = FeatureSet.MessageEncoding.DELIMITED;
	delimited_child.field.append (make_field (
		"nested",
		3,
		FieldDescriptorProto.Type.TYPE_MESSAGE,
		FieldDescriptorProto.Label.LABEL_OPTIONAL,
		".test.editions2023.DelimitedChild.NestedDelimited",
		delim_feat
	));
	delimited_child.field.append (make_field (
		"empty_group",
		4,
		FieldDescriptorProto.Type.TYPE_MESSAGE,
		FieldDescriptorProto.Label.LABEL_OPTIONAL,
		".test.editions2023.EmptyGroup",
		delim_feat
	));
	file.message_type.append (delimited_child);

	var sub_msg = new DescriptorProto ();
	sub_msg.name = "SubMsg";
	sub_msg.field.append (make_field ("value", 1, FieldDescriptorProto.Type.TYPE_INT32));
	file.message_type.append (sub_msg);

	var defaults_msg = new DescriptorProto ();
	defaults_msg.name = "DefaultsMsg";
	defaults_msg.field.append (make_field ("explicit_int", 1, FieldDescriptorProto.Type.TYPE_INT32));
	defaults_msg.field.append (make_field ("explicit_str", 2, FieldDescriptorProto.Type.TYPE_STRING));
	defaults_msg.field.append (make_field ("explicit_bytes", 3, FieldDescriptorProto.Type.TYPE_BYTES));
	defaults_msg.field.append (make_field ("explicit_bool", 4, FieldDescriptorProto.Type.TYPE_BOOL));
	defaults_msg.field.append (make_field ("explicit_enum", 5, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.OpenEnum"));
	defaults_msg.field.append (make_field ("explicit_dur", 6, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".google.protobuf.Duration"));
	defaults_msg.field.append (make_field ("explicit_mask", 7, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".google.protobuf.FieldMask"));
	defaults_msg.field.append (make_field ("packed_ints", 8, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_REPEATED));
	defaults_msg.field.append (make_field ("rep_strs", 9, FieldDescriptorProto.Type.TYPE_STRING, FieldDescriptorProto.Label.LABEL_REPEATED));
	add_map_field (defaults_msg, ".test.editions2023", "str_map", 10, "StrMapEntry");
	file.message_type.append (defaults_msg);

	var implicit_msg = new DescriptorProto ();
	implicit_msg.name = "ImplicitMsg";
	implicit_msg.options = new MessageOptions ();
	implicit_msg.options.features = new FeatureSet ();
	implicit_msg.options.features.field_presence = FeatureSet.FieldPresence.IMPLICIT;
	implicit_msg.options.features.repeated_field_encoding = FeatureSet.RepeatedFieldEncoding.EXPANDED;
	implicit_msg.field.append (make_field ("imp_int", 1, FieldDescriptorProto.Type.TYPE_INT32));
	implicit_msg.field.append (make_field ("imp_str", 2, FieldDescriptorProto.Type.TYPE_STRING));
	implicit_msg.field.append (make_field ("imp_bytes", 3, FieldDescriptorProto.Type.TYPE_BYTES));
	implicit_msg.field.append (make_field ("imp_dur", 4, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".google.protobuf.Duration"));
	implicit_msg.field.append (make_field ("expanded_ints", 5, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_REPEATED));
	var explicit_feat = new FeatureSet ();
	explicit_feat.field_presence = FeatureSet.FieldPresence.EXPLICIT;
	implicit_msg.field.append (make_field ("field_explicit_int", 6, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_OPTIONAL, "", explicit_feat));
	var packed_feat = new FeatureSet ();
	packed_feat.repeated_field_encoding = FeatureSet.RepeatedFieldEncoding.PACKED;
	implicit_msg.field.append (make_field ("field_packed_ints", 7, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_REPEATED, "", packed_feat));
	var req_feat = new FeatureSet ();
	req_feat.field_presence = FeatureSet.FieldPresence.LEGACY_REQUIRED;
	implicit_msg.field.append (make_field ("req_int", 8, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_OPTIONAL, "", req_feat));
	implicit_msg.field.append (make_field ("req_str", 9, FieldDescriptorProto.Type.TYPE_STRING, FieldDescriptorProto.Label.LABEL_OPTIONAL, "", req_feat));
	implicit_msg.field.append (make_field ("req_sub", 10, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.SubMsg", req_feat));
	file.message_type.append (implicit_msg);

	var closed_scope = new DescriptorProto ();
	closed_scope.name = "ClosedScopeMsg";
	closed_scope.options = new MessageOptions ();
	closed_scope.options.features = new FeatureSet ();
	closed_scope.options.features.enum_type = FeatureSet.EnumType.CLOSED;
	var nested_closed_enum = new EnumDescriptorProto ();
	nested_closed_enum.name = "NestedClosedEnum";
	nested_closed_enum.value.append (make_enum_val ("NC_ZERO", 0));
	nested_closed_enum.value.append (make_enum_val ("NC_ONE", 1));
	nested_closed_enum.value.append (make_enum_val ("NC_TWO", 2));
	closed_scope.enum_type.append (nested_closed_enum);
	closed_scope.field.append (make_field ("closed_singular", 1, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.ClosedEnum"));
	closed_scope.field.append (make_field ("closed_rep", 2, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_REPEATED, ".test.editions2023.ClosedEnum"));
	closed_scope.field.append (make_field ("closed_req", 3, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.ClosedEnum", req_feat));
	closed_scope.field.append (make_field ("nested_closed", 4, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.ClosedScopeMsg.NestedClosedEnum"));
	closed_scope.field.append (make_field ("explicit_open", 5, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.OpenEnum"));
	file.message_type.append (closed_scope);

	var utf8_none_msg = new DescriptorProto ();
	utf8_none_msg.name = "Utf8NoneMsg";
	utf8_none_msg.options = new MessageOptions ();
	utf8_none_msg.options.features = new FeatureSet ();
	utf8_none_msg.options.features.utf8_validation = FeatureSet.Utf8Validation.NONE;
	utf8_none_msg.field.append (make_field ("raw_str", 1, FieldDescriptorProto.Type.TYPE_STRING));
	add_map_field (utf8_none_msg, ".test.editions2023", "raw_map", 2, "RawMapEntry");
	utf8_none_msg.field.append (make_field ("raw_str_wrp", 3, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".google.protobuf.StringValue"));
	utf8_none_msg.field.append (make_field ("raw_mask", 4, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".google.protobuf.FieldMask"));
	file.message_type.append (utf8_none_msg);

	var delimited_msg = new DescriptorProto ();
	delimited_msg.name = "DelimitedMsg";
	delimited_msg.field.append (make_field ("child", 1, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.DelimitedChild", delim_feat));
	delimited_msg.field.append (make_field ("after_child", 2, FieldDescriptorProto.Type.TYPE_INT32));
	delimited_msg.field.append (make_field ("children", 3, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_REPEATED, ".test.editions2023.DelimitedChild", delim_feat));
	var req_delim_feat = new FeatureSet ();
	req_delim_feat.message_encoding = FeatureSet.MessageEncoding.DELIMITED;
	req_delim_feat.field_presence = FeatureSet.FieldPresence.LEGACY_REQUIRED;
	delimited_msg.field.append (make_field ("req_child", 4, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.DelimitedChild", req_delim_feat));
	delimited_msg.field.append (make_field ("lp_child", 5, FieldDescriptorProto.Type.TYPE_MESSAGE, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2023.DelimitedChild"));
	file.message_type.append (delimited_msg);

	return file;
}

private static FileDescriptorProto build_editions2024_file () {
	var file = new FileDescriptorProto ();
	file.name = "editions2024.proto";
	file.package = "test.editions2024";
	file.syntax = "editions";
	file.edition = Edition.EDITION_2024;
	file.options = new FileOptions ();
	file.options.features = new FeatureSet ();
	file.options.features.repeated_field_encoding = FeatureSet.RepeatedFieldEncoding.EXPANDED;
	file.options.features.utf8_validation = FeatureSet.Utf8Validation.NONE;

	var ed_enum = new EnumDescriptorProto ();
	ed_enum.name = "Ed2024Enum";
	ed_enum.value.append (make_enum_val ("E24_ZERO", 0));
	ed_enum.value.append (make_enum_val ("E24_ONE", 1));
	file.enum_type.append (ed_enum);

	var msg = new DescriptorProto ();
	msg.name = "Ed2024Msg";
	msg.field.append (make_field ("count", 1, FieldDescriptorProto.Type.TYPE_INT32));
	msg.field.append (make_field ("raw_text", 2, FieldDescriptorProto.Type.TYPE_STRING));
	var verify_feat = new FeatureSet ();
	verify_feat.utf8_validation = FeatureSet.Utf8Validation.VERIFY;
	msg.field.append (make_field ("strict_text", 3, FieldDescriptorProto.Type.TYPE_STRING, FieldDescriptorProto.Label.LABEL_OPTIONAL, "", verify_feat));
	msg.field.append (make_field ("file_expanded", 4, FieldDescriptorProto.Type.TYPE_INT32, FieldDescriptorProto.Label.LABEL_REPEATED));
	msg.field.append (make_field ("kind", 5, FieldDescriptorProto.Type.TYPE_ENUM, FieldDescriptorProto.Label.LABEL_OPTIONAL, ".test.editions2024.Ed2024Enum"));
	file.message_type.append (msg);

	return file;
}

public static int main (string[] args) {
	if (args.length < 3) {
		GLib.stderr.printf ("Usage: %s <protoc-gen-vala> <outdir>\n", args[0]);
		return 1;
	}

	var plugin_path = args[1];
	var outdir = args[2];

	var req = new Compiler.CodeGeneratorRequest ();
	req.file_to_generate.append ("editions.proto");
	req.file_to_generate.append ("editions2024.proto");
	req.proto_file.append (build_editions2023_file ());
	req.proto_file.append (build_editions2024_file ());

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
		if (!proc.get_successful ()) {
			GLib.stderr.printf ("protoc-gen-vala failed with exit status %d\n", proc.get_exit_status ());
			return 1;
		}
		var resp_buf = new DecodeBuffer (stdout_bytes.get_data ());
		var resp = new Compiler.CodeGeneratorResponse.from_data (resp_buf);
		if (resp_buf.error) {
			GLib.stderr.printf ("Failed to decode CodeGeneratorResponse\n");
			return 1;
		}
		if (resp.error != "") {
			GLib.stderr.printf ("CodeGeneratorResponse error: %s\n", resp.error);
			return 1;
		}
		foreach (var f in resp.file) {
			var out_path = Path.build_filename (outdir, f.name);
			GLib.FileUtils.set_contents (out_path, f.content);
		}
	} catch (Error e) {
		GLib.stderr.printf ("Error invoking protoc-gen-vala: %s\n", e.message);
		return 1;
	}

	return 0;
}
