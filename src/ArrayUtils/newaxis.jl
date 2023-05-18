###############################
# newaxis
###############################
"""
    newaxis

    python-like newaxis

# Example
a[:, newaxis, newaxis, :] == addaxis(a, 2,3)
"""
const newaxis = [CartesianIndex()]
