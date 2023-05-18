###############################
# exe
###############################
"""
    exe(f, a...)

# Examples
```
julia> exe(3,4,5) do x, y, z
            sin.((x,y,z)), cos.((x,y,z)), tan.((x,y,z))
        end
```
"""
exe(f::Function, a...; ka...) = f(a...; ka...)
