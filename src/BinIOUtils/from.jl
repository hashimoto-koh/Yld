from(file::AbstractString; ka...) =
begin
    if !Base.Filesystem.isfile(file)
        f = Glob.glob(basename(file) * "*",
                      dirname(file) == "" ? "./" : dirname(file))
        length(f) == 1 && (return info(f[1]))
        length(f) == 0 && error("$file does not exist.")
        error("$file is ambiguous.")
    end
    ext = Base.Filesystem.splitext(file)[2]
    @assert (length(ext) > 1) "$file : the filename has no extenstion."
    from(Val(ext[2:end]), filename; ka...)
end