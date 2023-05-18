
type_str(t) = begin
    t == Int8 && (return "I1")
    t == Int16 && (return "I2")
    t == Int32 && (return "I4")
    t == Int64 && (return "I8")
    t == UInt8 && (return "U1")
    t == UInt16 && (return "U2")
    t == UInt32 && (return "U4")
    t == UInt64 && (return "U8")
    t == Float16 && (return "F2")
    t == Float32 && (return "F4")
    t == Float64 && (return "F8")
    t == ComplexF16 && (return "C2")
    t == ComplexF32 && (return "C4")
    t == ComplexF64 && (return "C8")
    (t <: Complex) && (return "C{$(type_str(t.parameters[1]))}")
    (t <: AbstractVector) && (return "V{$(type_str(t.parameters[1]))}")
    (t <: AbstractMatrix) && (return "M{$(type_str(t.parameters[1]))}")
    (t <: AbstractArray) && (return "A{$(type_str(t.parameters[1])), $(t.parameters[2])}")
    return string(t)
end

typeof_str(x) = type_str(typeof(x))

