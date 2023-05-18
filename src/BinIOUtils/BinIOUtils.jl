module BinIOUtils

import ..InfoUtils

include("helper.jl")

include("array_from_fstream.jl")

include("array_to_fstream.jl")

include("from.jl")
export from

include("to.jl")
export to

include("waf.jl")
export loadwaf

include("png.jl")
include("tiff.jl")
include("cine.jl")
include("mraw.jl")
include("raw.jl")

import Mmap.sync!
export sync!

end