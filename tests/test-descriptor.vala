using Google.Protobuf;

public class TestDescriptor : Object {
	public static int main (string[] args) {
		GLib.Test.init (ref args);

		GLib.Test.add_func ("/protobuf-vala/descriptor/oneof_index_nullable", () => {
			// Unset oneof_index remains null (distinct from 0)
			var f_unset = new FieldDescriptorProto ();
			f_unset.name = "plain";
			f_unset.number = 1;
			assert_true (f_unset.oneof_index == null);

			var buf1 = new EncodeBuffer ();
			f_unset.encode (buf1);
			var d1 = new FieldDescriptorProto.from_data (new DecodeBuffer (buf1.data));
			assert_true (d1.oneof_index == null);
			assert_false (d1.to_string ().contains ("oneof_index:"));

			// oneof_index == 0 is preserved on wire and after decode
			var f_zero = new FieldDescriptorProto ();
			f_zero.name = "in_first_oneof";
			f_zero.number = 2;
			f_zero.oneof_index = 0;
			var buf2 = new EncodeBuffer ();
			f_zero.encode (buf2);
			var dec_buf2 = new DecodeBuffer (buf2.data);
			var d2 = new FieldDescriptorProto.from_data (dec_buf2);
			assert_true (!dec_buf2.error);
			assert_true (d2.oneof_index != null);
			assert_cmpint (d2.oneof_index, CompareOperator.EQ, 0);
			assert_true (d2.to_string ().contains ("oneof_index: 0"));

			// oneof_index == 2 roundtrips properly
			var f_two = new FieldDescriptorProto ();
			f_two.name = "in_third_oneof";
			f_two.number = 3;
			f_two.oneof_index = 2;
			var buf3 = new EncodeBuffer ();
			f_two.encode (buf3);
			var dec_buf3 = new DecodeBuffer (buf3.data);
			var d3 = new FieldDescriptorProto.from_data (dec_buf3);
			assert_true (!dec_buf3.error);
			assert_true (d3.oneof_index != null);
			assert_cmpint (d3.oneof_index, CompareOperator.EQ, 2);
		});

		return GLib.Test.run ();
	}
}
