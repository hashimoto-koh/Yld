macro rv(ex)
    args = reverse(ex.args)
    n = length(args)

    esc(quote m -> (ndims(m) == $(n)
                    ? m[$(args...)]
                    : (@view m[fill(:, ndims(m) - $(n))..., $(args...)]))
        end)
end

macro rx(ex)
    args = reverse(ex.args)
    n = length(args)

    esc(quote m -> (ndims(m) == $(n)
                    ? m[$(args...)]
                    : (m[fill(:, ndims(m) - $(n))..., $(args...)]))
        end)
end

macro lv(ex)
    args = ex.args
    n = length(args)

    esc(quote m -> (ndims(m) == $(n)
                    ? m[$(args...)]
                    : (@view m[$(args...), fill(:, ndims(m) - $(n))...]))
        end)
end

macro lx(ex)
    args = ex.args
    n = length(args)

    esc(quote m -> (ndims(m) == $(n)
                    ? m[$(args...)]
                    : (m[$(args...), fill(:, ndims(m) - $(n))...]))
        end)
end

macro idx(ex)
    return esc(@lx(ex))
end

macro idv(ex)
    return esc(@lv(ex))
end
