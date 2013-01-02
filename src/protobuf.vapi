namespace Protobuf
{
    private int decode_varint (uint8[] buffer, size_t length, ref size_t offset)
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
    
    private double decode_double (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0.0; // FIXME
    }

    private float decode_float (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 0.0f; // FIXME
    }

    private int64 decode_int64 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    private uint64 decode_uint64 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    private int32 decode_int32 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    private uint64 decode_fixed64 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0; // FIXME
    }

    private uint32 decode_fixed32 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 4; // FIXME
    }

    private bool decode_bool (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset) != 0;
    }

    private string decode_string (uint8[] buffer, size_t length, size_t offset)
    {
        var value = new GLib.StringBuilder.sized (length - offset);
        while (offset < length)
        {
            value.append_c ((char) buffer[offset]);
            offset++;
        }

        return value.str;
    }

    private GLib.ByteArray decode_bytes (uint8[] buffer, size_t length, size_t offset)
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

    private uint32 decode_uint32 (uint8[] buffer, size_t length, size_t offset)
    {
        return decode_varint (buffer, length, ref offset);
    }

    private int32 decode_sfixed32 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 4;
        return 0; // FIXME
    }

    private int64 decode_sfixed64 (uint8[] buffer, size_t length, size_t offset)
    {
        offset += 8;
        return 0; // FIXME
    }

    private int32 decode_sint32 (uint8[] buffer, size_t length, size_t offset)
    {
        var value = decode_varint (buffer, length, ref offset);
        return (value >> 1) | ((value & 0x1) << 31);
    }

    private int64 decode_sint64 (uint8[] buffer, size_t length, size_t offset)
    {
        var value = decode_varint (buffer, length, ref offset);
        return (value >> 1) | ((value & 0x1) << 63);
    }

    private size_t get_value_length (int wire_type, out int varint, uint8[] buffer, size_t length, ref size_t offset)
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

    private size_t encode_varint (size_t value, uint8[] buffer, ref size_t offset)
    {
        var n_octets = 1;
        var v = value;
        while (v != 0)
        {
            v >>= 7;
            n_octets++;
        }
        offset -= n_octets;

        v = value;
        for (var i = 0; i < n_octets - 1; i++)
        {
            buffer[offset + i + 1] = 0x80 | (uint8) (v & 0x7F);
            v >>= 7;
        }
        buffer[offset + n_octets] = (uint8) (v & 0x7F);

        return n_octets;
    }

    private size_t encode_double (double value, uint8[] buffer, ref size_t offset)
    {
        offset -= 8;
        // FIXME
        return 8;
    }

    private size_t encode_float (float value, uint8[] buffer, ref size_t offset)
    {
        offset -= 4;
        // FIXME
        return 4;
    }

    private size_t encode_int64 (int64 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint ((size_t) value, buffer, ref offset);
    }

    private size_t encode_uint64 (uint64 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint ((size_t) value, buffer, ref offset);
    }

    private size_t encode_int32 (int32 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint (value, buffer, ref offset);
    }

    private size_t encode_fixed64 (uint64 value, uint8[] buffer, ref size_t offset)
    {
        offset -= 8;
        // FIXME
        return 8;
    }

    private size_t encode_fixed32 (uint32 value, uint8[] buffer, ref size_t offset)
    {
        offset -= 4;
        // FIXME
        return 4;
    }

    private size_t encode_bool (bool value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint (value ? 1 : 0, buffer, ref offset);
    }

    private size_t encode_string (string value, uint8[] buffer, ref size_t offset)
    {
        offset -= value.length;
        for (var i = 0; value[i] != '\0'; i++)
            buffer[offset + i + 1] = value[i];

        return value.length;
    }

    private size_t encode_bytes (GLib.ByteArray value, uint8[] buffer, ref size_t offset)
    {
        offset -= value.len;
        for (var i = 0; i < value.len; i++)
            buffer[offset + i + 1] = value.data[i];

        return value.len;
    }

    private size_t encode_uint32 (uint32 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint (value, buffer, ref offset);
    }

    private size_t encode_sfixed32 (int32 value, uint8[] buffer, ref size_t offset)
    {
        offset -= 4;
        // FIXME
        return 4;
    }

    private size_t encode_sfixed64 (int64 value, uint8[] buffer, ref size_t offset)
    {
        offset -= 8;
        // FIXME
        return 8;
    }

    private size_t encode_sint32 (int32 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint ((value << 1) | (value >> 31), buffer, ref offset);
    }

    private size_t encode_sint64 (int64 value, uint8[] buffer, ref size_t offset)
    {
        return encode_varint ((size_t) (value << 1) | (value >> 63), buffer, ref offset);
    }
}
