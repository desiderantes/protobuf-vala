public static int main (string[] args)
{
    var buffer = new Protobuf.EncodeBuffer (1024);
    buffer.encode_varint (0);
    print_buffer (buffer);

    buffer.reset ();
    buffer.encode_varint (1);
    print_buffer (buffer);

    buffer.reset ();
    buffer.encode_varint (0x7F);
    print_buffer (buffer);

    buffer.reset ();
    buffer.encode_varint (0x80);
    print_buffer (buffer);

    return 0;
}

private void print_buffer (Protobuf.EncodeBuffer buffer)
{
    var data = buffer.data;
    for (var i = 0; i < data.length; i++)
        stderr.printf ("%02X", data[i]);
    stderr.printf ("\n");
}