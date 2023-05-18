###############################
# haspkg
###############################

import Pkg

haspkg(pkg::Symbol) = haspkg(string(pkg))
haspkg(pkg::AbstractString) = pkg ∈ keys(Pkg.project().dependencies)

