# #################################
# # linktowaf
# #################################

# linktowaf(parent::Union{HDF5.File, HDF5.Group},
#           name::Union{AbstractString, Symbol},
#           waffile::AbstractString) =
# begin
#     wafinfo = waf_info(waffile)
#     HDF5.create_external_dataset(parent, string(name), waffile, wafinfo.eltype, Tuple(wafinfo.size), wafinfo.offset)
#     parent[string(name)]._attr.time = HDF5._nowstr()
#     Base.getproperty(parent, Symbol(name))
# end

# linktowaf(parent::Union{JLD.JldFile, JLD.JldGroup},
#           name::Union{AbstractString, Symbol},
#           waffile::AbstractString) =
#     linktowaf(parent.plain, name, waffile)

# linktowaf(filename::AbstractString,
#           name::Union{AbstractString, Symbol},
#           waffile::AbstractString) =
#     linktowaf((Base.Filesystem.splitext(filename)[2] == ".jld" ? openjld : openh5)(filename), name, waffile)
