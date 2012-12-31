public class ProtocVala
{
}

public static int main (string[] args)
{
    var buf = new uint8[1024];
    var n_read = stdin.read (buf); // FIXME: Read all
    stderr.printf ("%zu\n", n_read);
    if (n_read < 0)
        return 1;

    //for (var i = 0; i < n_read; i++)
    //    stderr.printf ("%02X", buf[i]);
    //stderr.printf ("\n");

    var req = new CodeGeneratorRequest ();
    req.decode (buf, n_read);

    stderr.printf ("{ %s }\n", req.to_string ());

    var resp = new CodeGeneratorResponse ();
    var f = new File ();
    f.name = "test.pb.vala";
    f.content = "TEST";
    resp.file.append (f);

    var rbuf = new uint8[65535];
    var n_written = resp.encode (rbuf, rbuf.length - 1);
    unowned uint8[] start = (uint8[]) ((uint8*) rbuf + rbuf.length - n_written);

    for (var i = 0; i < n_written; i++)
        stderr.printf ("%02X", start[i]);
    stderr.printf ("\n");

    stdout.write (start, n_written);

    return 0;
}
