###############################
# toBool
###############################

toBool(x::Integer) = x != 0
toBool(::Nothing) = false
toBool(x::Bool) = x

