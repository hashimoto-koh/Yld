readhead(fstream) =
begin
    seekstart(fstream)
    tp = typeidx_type(read(fstream, UInt16))
    dim = Int(read(fstream, UInt16))
    shape = reverse(Tuple(Int(read(fstream, UInt32)) for i ∈ 1:dim))
    offset = let
        o = 2 + 2 + 4dim
        nbyte = sizeof(tp)
        o + ((o % nbyte == 0) ? 0 : nbyte - o % nbyte)
    end
    (;tp, dim, shape, offset)
end

writehead(fstream, T::DataType, shape::Tuple) =
begin
    write(fstream,
          type_typeidx(T),
          UInt16(length(shape)),
          UInt32.(reverse(shape))...)
    offset = 2 + 2 + 4 * length(shape)
    nbyte = sizeof(T)
    (offset % nbyte != 0) && [write(fstream, '0') for _ in 1:(nbyte-offset%nbyte)]
end