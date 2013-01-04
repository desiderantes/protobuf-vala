namespace Protobuf
{
    public class DecodeBuffer
    {
        public uint8[] buffer;
        public size_t read_index;

        public DecodeBuffer (size_t size)
        {
            buffer = new uint8[size];
        }

        public uint64 decode_varint ()
        {
            uint64 value = 0;
            var shift = 0;
    
            while (true)
            {
                var b = buffer[read_index];
                read_index++;
                value = value | (b & 0x7F) << shift;
                if ((b & 0x80) == 0)
                    return value;
                shift += 7;
            }
        }
    
        public double decode_double ()
        {
            var v = decode_fixed64 ();
            return *((double*) (&v));
        }
    
        public float decode_float ()
        {
            var v = decode_fixed32 ();
            return *((float*) (&v));
        }
    
        public int64 decode_int64 ()
        {
            var v = decode_varint ();
            return *((int64*) (&v));
        }
    
        public uint64 decode_uint64 ()
        {
            return decode_varint ();
        }
    
        public int32 decode_int32 ()
        {
            var v = decode_varint ();
            return *((int32*) (&v));
        }
    
        public uint64 decode_fixed64 ()
        {
            var v = (uint64) buffer[read_index] | (uint64) buffer[read_index+1] << 8 | (uint64) buffer[read_index+2] << 16 | (uint64) buffer[read_index+3] << 24 | (uint64) buffer[read_index+4] << 32 | (uint64) buffer[read_index+5] << 40 | (uint64) buffer[read_index+6] << 48 | (uint64) buffer[read_index+7] << 56;
            read_index += 8;
            return v;
        }
    
        public uint32 decode_fixed32 ()
        {
            var v = (uint32) buffer[read_index] | (uint32) buffer[read_index+1] << 8 | (uint32) buffer[read_index+2] << 16 | (uint32) buffer[read_index+3] << 24;
            read_index += 4;
            return v;
        }
    
        public bool decode_bool ()
        {
            return decode_varint () != 0;
        }
    
        public string decode_string (size_t length)
        {
            var value = new GLib.StringBuilder.sized (length);
            for (var i = 0; i < length; i++)
                value.append_c ((char) buffer[read_index + i]);
            read_index += length;
    
            return value.str;
        }
    
        public GLib.ByteArray decode_bytes (size_t length)
        {
            var data = new uint8[length];
            for (var i = 0; i < length; i++)
                data[i] = buffer[read_index + i];
            read_index += length;
    
            return new ByteArray.take (data);
        }
    
        public uint32 decode_uint32 ()
        {
            return (uint32) decode_varint ();
        }
    
        public int32 decode_sfixed32 ()
        {
            var v = decode_fixed32 ();
            return *((int32*) (&v));
        }
    
        public int64 decode_sfixed64 ()
        {
            var v = decode_fixed64 ();
            return *((int64*) (&v));
        }
    
        public int32 decode_sint32 ()
        {
            var value = (uint32) decode_varint ();
            var v = (int32) (value >> 1);
            if ((value & 0x1) != 0)
                return -(v + 1);
            else
                return v;
        }
    
        public int64 decode_sint64 ()
        {
            var value = (uint64) decode_varint ();
            var v = (int64) (value >> 1);
            if ((value & 0x1) != 0)
                return -(v + 1);
            else
                return v;
        }
    
        public void decode_unknown (uint64 wire_type)
        {
            switch (wire_type)
            {
            case 0: //varint
                decode_varint ();
                break;
            case 1: //64-bit
                read_index += 8;
                break;
            case 2: //length-delimited
                var length = decode_varint ();
                read_index += (size_t) length;
                break;
            case 5: //32-bit
                read_index += 4;
                break;
            default: //FIXME: throw error
                GLib.stderr.printf ("Unknown wire type %llu\n", wire_type);
                break;
            }
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

        public size_t encode_varint (uint64 value)
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
            return encode_fixed64 (*((uint64*) (&value)));
        }

        public size_t encode_float (float value)
        {
            return encode_fixed32 (*((uint32*) (&value)));
        }

        public size_t encode_int64 (int64 value)
        {
            return encode_varint (*((uint64*) (&value)));
        }

        public size_t encode_uint64 (uint64 value)
        {
            return encode_varint (value);
        }

        public size_t encode_int32 (int32 value)
        {
            return encode_int64 (value);
        }

        public size_t encode_fixed64 (uint64 value)
        {
            write_index -= 8;
            buffer[write_index + 1] = (uint8) value;
            buffer[write_index + 2] = (uint8) (value >> 8);
            buffer[write_index + 3] = (uint8) (value >> 16);
            buffer[write_index + 4] = (uint8) (value >> 24);
            buffer[write_index + 5] = (uint8) (value >> 32);
            buffer[write_index + 6] = (uint8) (value >> 40);
            buffer[write_index + 7] = (uint8) (value >> 48);
            buffer[write_index + 8] = (uint8) (value >> 56);
            return 8;
        }

        public size_t encode_fixed32 (uint32 value)
        {
            write_index -= 4;
            buffer[write_index + 1] = (uint8) value;
            buffer[write_index + 2] = (uint8) (value >> 8);
            buffer[write_index + 3] = (uint8) (value >> 16);
            buffer[write_index + 4] = (uint8) (value >> 24);
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
            return encode_fixed32 (*((uint32*) (&value)));
        }

        public size_t encode_sfixed64 (int64 value)
        {
            return encode_fixed64 (*((uint64*) (&value)));
        }

        public size_t encode_sint32 (int32 value)
        {
            return encode_varint ((value << 1) ^ (value >> 31));
        }

        public size_t encode_sint64 (int64 value)
        {
            return encode_varint ((size_t) ((value << 1) ^ (value >> 63)));
        }

        // FIXME: Double size when run out of space
        private void allocate (size_t size)
        {
        }
    }
}
