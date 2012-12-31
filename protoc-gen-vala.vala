public class ProtocVala
{
}

public static int main (string[] args)
{
    var buf = new uint8[1024];
    var n_read = stdin.read (buf); // FIXME: Read all
    if (n_read < 0)
        return 1;
    buf.length = (int) n_read;

    var req = new CodeGeneratorRequest ();
    req.decode (buf, n_read);

    stderr.printf ("{ %s }\n", req.to_string ());

    var resp = new CodeGeneratorResponse ();
    
    foreach (var f in req.proto_file)
    {
        var out_file = new CodeGeneratorResponse.File ();

        if (f.name.has_suffix (".proto"))
            out_file.name = f.name.substring (0, f.name.length - 6) + ".pb.vala";
        else
            out_file.name = f.name + ".vala";
    
        out_file.content = "TEST";
        resp.file.append (out_file);
    }

    var rbuf = new uint8[65535];
    var n_written = resp.encode (rbuf, rbuf.length - 1);
    unowned uint8[] start = (uint8[]) ((uint8*) rbuf + rbuf.length - n_written);
    start.length = (int) n_written;

    stdout.write (start);
    stdout.flush ();

    return 0;
}
