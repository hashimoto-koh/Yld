#################################
# type_typeidx
#################################

type_typeidx(tp::Type) =
begin
    tp <: Complex && (return UInt16(type_typeidx(tp.parameters[1]) + 4))

    typeidx = 0
    tp <: Integer && (typeidx += (tp <: Signed) ? 1 : 3)
    typeidx += sizeof(tp) * 256
    return UInt16(typeidx)
end

#################################
# typeidx_type
#################################

typeidx_type(tidx::UInt16) =
begin
    tidx & 4 != 0 && (return Complex{typeidx_type(tidx-UInt16(4))})

    isint = tidx & 1 == 1
    sz = tidx ÷ 256
    if isint
        signed = tidx & 2 == 0
        if signed
            sz == 1 && (return Int8)
            sz == 2 && (return Int16)
            sz == 4 && (return Int32)
            sz == 8 && (return Int64)
            sz == 16 && (return Int128)
            error("invalid typeidx: 0b$(string(tidx,base=2))")
        else
            sz == 1 && (return UInt8)
            sz == 2 && (return UInt16)
            sz == 4 && (return UInt32)
            sz == 8 && (return UInt64)
            sz == 16 && (return UInt128)
            error("invalid typeidx: 0b$(string(tidx,base=2))")
        end
    end
    sz == 2 && (return Float16)
    sz == 4 && (return Float32)
    sz == 8 && (return Float64)
    error("invalid typeidx: 0b$(string(tidx,base=2))")
end
