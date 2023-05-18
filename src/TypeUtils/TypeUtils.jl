module TypeUtils

include("typeidx.jl")
export type_typeidx, typeidx_type

include("typealiase.jl")
export C2, C4, C8, F2, F4, F8, I1, I2, I4, I8, U1, U2, U4, U8
export VC2, VC4, VC8, VF2, VF4, VF8, VI1, VI2, VI4, VI8, VU1, VU2, VU4, VU8
export MC2, MC4, MC8, MF2, MF4, MF8, MI1, MI2, MI4, MI8, MU1, MU2, MU4, MU8
export A3, A4, A5
export AC2, AC4, AC8, AF2, AF4, AF8, AI1, AI2, AI4, AI8, AU1, AU2, AU4, AU8
export VC, VF, VI, VU, MC, MF, MI, MU, AC, AF, AI, AU
export OAry, ORng
export SVec, SMat, SAry, MVec, MMat, Mary

include("typestr.jl")
export type_str, typeof_str

end