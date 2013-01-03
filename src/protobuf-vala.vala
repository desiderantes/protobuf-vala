namespace Protobuf
{
    public int decode_varint (uint8[] buffer, size_t length, ref size_t offset)
    {
        int value = 0;
        var shift = 0;

        while (true)
        {
            var b = buffer[offset];
            offset++;
            value = value | (b & 0x7F) << shift;
            if ((b & 0x80) == 0)
                return value;
            shift += 7;
        }
    }

    public double decode_double (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0.0; // FIXME
    }

    public float decode_float (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 0.0f; // FIXME
    }

    public int64 decode_int64 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    public uint64 decode_uint64 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    public int32 decode_int32 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    public uint64 decode_fixed64 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0; // FIXME
    }

    public uint32 decode_fixed32 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 4; // FIXME
    }

    public bool decode_bool (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset) != 0;
    }

    public string decode_string (uint8[] buffer, size_t length, size_t offset)
    {
        var value = new GLib.StringBuilder.sized (length - offset);
        while (offset < length)
        {
            value.append_c ((char) buffer[offset]);
            offset++;
        }

        return value.str;
    }

    public GLib.ByteArray decode_bytes (uint8[] buffer, size_t length, size_t offset)
    {
        var value = new GLib.ByteArray.sized ((uint) (length - offset));
        var start = offset;
        for (var i = start; i < length; i++)
        {
            value.data[i - start] = buffer[i];
            offset++;
        }

        return value;
    }

    public uint32 decode_uint32 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    public int32 decode_sfixed32 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 0; // FIXME
    }

    public int64 decode_sfixed64 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0; // FIXME
    }

    public int32 decode_sint32 (uint8[] buffer, size_t length, size_t offset)
    {
        var value = decode_varint (buffer, length, ref offset);
        return (value >> 1) | ((value & 0x1) << 31);
    }

    public int64 decode_sint64 (uint8[] buffer, size_t length, size_t offset)
    {
        var value = decode_varint (buffer, length, ref offset);
        return (value >> 1) | ((value & 0x1) << 63);
    }

    public size_t get_value_length (int wire_type, out int varint, uint8[] buffer, size_t length, ref size_t offset)
    {
        varint = 0;
        switch (wire_type)
        {
        case 0: //varint
            var o = offset;
            varint = decode_varint (buffer, length, ref o);
            return o - offset;
        case 1: //64-bit
            return 8;
        case 2: //length-delimited
            return decode_varint (buffer, length, ref offset);
        case 5: //32-bit
            return 4;
        default: //FIXME: throw error
            GLib.stderr.printf ("Unknown wire type %d\n", wire_type);
            return 0;
        }
    }

    public class EncodeBuffer
    {
        private uint8[] buffer;
        public size_t write_index; // FIXME: Should be private

        public unowned uint8[] data
        {
            get
            {
                unowned uint8[] v = (uint8[]) ((uint8*) buffer + write_index + 1);
                v.length = buffer.length - (int) write_index - 1;
                return v;
            }
        }

        public EncodeBuffer (size_t size)
        {
            buffer = new uint8[size];
            reset ();
        }

        public void reset ()
        {
            write_index = buffer.length - 1;
        }

        public size_t encode_varint (size_t value)
        {
            var n_octets = 0;
            var v = value;
            do
            {
                v >>= 7;
                n_octets++;
            } while (v != 0);
            write_index -= n_octets;

            v = value;
            for (var i = 0; i < n_octets - 1; i++)
            {
                buffer[write_index + i + 1] = 0x80 | (uint8) (v & 0x7F);
                v >>= 7;
            }
            buffer[write_index + n_octets] = (uint8) (v & 0x7F);

            return n_octets;
        }

        public size_t encode_double (double value)
        {
            write_index -= 8;
            var v = *((uint64*) (&value));
            buffer[write_index + 1] = (uint8) v;
            buffer[write_index + 2] = (uint8) (v >> 8);
            buffer[write_index + 3] = (uint8) (v >> 16);
            buffer[write_index + 4] = (uint8) (v >> 24);
            buffer[write_index + 5] = (uint8) (v >> 32);
            buffer[write_index + 6] = (uint8) (v >> 40);
            buffer[write_index + 7] = (uint8) (v >> 48);
            buffer[write_index + 8] = (uint8) (v >> 56);
            return 8;
        }

        public size_t encode_float (float value)
        {
            write_index -= 4;
            var v = *((uint32*) (&value));
            buffer[write_index + 1] = (uint8) v;
            buffer[write_index + 2] = (uint8) (v >> 8);
            buffer[write_index + 3] = (uint8) (v >> 16);
            buffer[write_index + 4] = (uint8) (v >> 24);
            return 4;
        }

        public size_t encode_int64 (int64 value)
        {
            return encode_varint ((size_t) value);
        }

        public size_t encode_uint64 (uint64 value)
        {
            return encode_varint ((size_t) value);
        }

        public size_t encode_int32 (int32 value)
        {
            return encode_varint (value);
        }

        public size_t encode_fixed64 (uint64 value)
        {
            write_index -= 8;
            // FIXME
            return 8;
        }

        public size_t encode_fixed32 (uint32 value)
        {
            write_index -= 4;
            // FIXME
            return 4;
        }

        public size_t encode_bool (bool value)
        {
            return encode_varint (value ? 1 : 0);
        }

        public size_t encode_string (string value)
        {
            write_index -= value.length;
            for (var i = 0; value[i] != '\0'; i++)
                buffer[write_index + i + 1] = value[i];

            return value.length;
        }

        public size_t encode_bytes (GLib.ByteArray value)
        {
            write_index -= value.len;
            for (var i = 0; i < value.len; i++)
                buffer[write_index + i + 1] = value.data[i];

            return value.len;
        }

        public size_t encode_uint32 (uint32 value)
        {
            return encode_varint (value);
        }

        public size_t encode_sfixed32 (int32 value)
        {
            write_index -= 4;
            // FIXME
            return 4;
        }

        public size_t encode_sfixed64 (int64 value)
        {
            write_index -= 8;
            // FIXME
            return 8;
        }

        public size_t encode_sint32 (int32 value)
        {
            return encode_varint ((value << 1) ^ (value >> 31));
        }

        public size_t encode_sint64 (int64 value)
        {
            return encode_varint ((size_t) ((value << 1) ^ (value >> 63)));
        }
    }
}
