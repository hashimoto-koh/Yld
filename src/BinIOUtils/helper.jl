###############################
# _force_ext
###############################

_force_ext(filename::AbstractString, ext::AbstractString, forcename::Bool) =
        (forcename || "." * ext == splitext(filename)[2]
         ? filename : filename * "." * ext)
_force_ext(filename::AbstractString, ext::AbstractString, forcename) =
    _force_ext(filename, ext, toBool(forcename))

