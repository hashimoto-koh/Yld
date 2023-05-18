#################################
# make_tmpfile_path
#################################

import UUIDs: uuid1

make_tmpfile_path(; dir="/tmp/", pre="", ext="") =
begin
    (!isa(dir, AbstractString) ||
     !isa(pre, AbstractString) ||
     !isa(ext, AbstractString)) &&
        (return make_tmpfile_path(; dir=string(dir), pre=string(pre), ext=string(ext)))

    length(ext) > 1 && ext[begin] == '.' && (ext = ext[2:end])

    length(dir) == 0 && (return make_tmpfile_path(; dir="./", pre, ext))
    dir[end] != '/'  && (dir = dir * "/")

    !isdir(dir) && mkpath(dir)
    dir * pre * string(uuid1()) * (length(ext) == 0 ? "" : "." * ext)
end

