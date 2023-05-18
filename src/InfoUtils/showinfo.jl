###############################
# NamedTuple
###############################

import ..TypeUtils: typeof_str

Base.show(io::IO, ::MIME"text/plain", x::NamedTuple) = printnmdtpl(io, x)

printnmdtpl(io, tpl::NamedTuple) = _printnmdtpl(io, tpl, " ")

_printnmdtpl(io, d::NamedTuple, k="", str="") = begin
    (k != "" || str != "") && Base.println(io, str * "📂 $(k):")
    for (k,v) in pairs(d) _printnmdtpl(io, v, k, str * "  ") end
end

_printnmdtpl(io, d::AbstractVector{Any}, k="", str="") = for (i, v) in enumerate(d) _printnmdtpl(io, v, i, str) end

_printnmdtpl(io, d, k::Integer, str="") = Base.println(io, str * "🏷️  $(k) [$(typeof_str(d))]: " * string(d))

_printnmdtpl(io, d::AbstractArray{T}, k="", str="") where T <: Number =

println(io, str * "🔢 $(k) [$(typeof_str(d)) | $(size(d))]" * ": " * (length(d)<20 ? string(d) : "......."))

_printnmdtpl(io, d::AbstractString, k="", str="") = Base.println(io, str * "🏷️  $(k): " * d)

_printnmdtpl(io, d::DataType, k="", str="") = Base.println(io, str * "🏷️  $(k): " * string(d))

_printnmdtpl(io, d, k="", str="") = Base.println(io, str * "🏷️  $(k) [$(typeof_str(d))]" * ": " * string(d))

