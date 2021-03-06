"""
"""
function _getlabelstring2intmap(
        levels::AbstractVector,
        index::Integer,
        )
    result = Dict()
    if length(levels) == 0
        error("length(levels) == 0")
    end
    for i = 1:length(levels)
        result[levels[i]] = i - 1 + index
    end
    result = fix_dict_type(result)
    return result
end

"""
"""
function _getlabelint2stringmap(
        levels::AbstractVector,
        index::Integer,
        )
    result = Dict()
    if length(levels) == 0
        error("length(levels) == 0")
    end
    for i = 1:length(levels)
        result[i - 1 + index] = levels[i]
    end
    result = fix_dict_type(result)
    return result
end
