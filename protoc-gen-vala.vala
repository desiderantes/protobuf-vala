public class ProtocVala
{
}

public static int main (string[] args)
{
    var buf = new uint8[1024];
    while (true)
    {
        var n_read = stdin.read (buf);
        stderr.printf ("%zu\n", n_read);

        if (n_read <= 0)
            return 0;
    }
}
