"""
"""
struct ImmutablePredictProbaSingleLabelInt2StringTransformer <:
        AbstractEstimator
    index::T1 where T1 <: Integer
    levels::T2 where T2 <: AbstractVector
end

"""
"""
function set_feature_contrasts!(
        x::ImmutablePredictProbaSingleLabelInt2StringTransformer,
        feature_contrasts::AbstractFeatureContrasts,
        )
    return nothing
end

"""
"""
function get_underlying(
        x::ImmutablePredictProbaSingleLabelInt2StringTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

"""
"""
function get_history(
        x::ImmutablePredictProbaSingleLabelInt2StringTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

"""
"""
function parse_functions!(
        transformer::ImmutablePredictProbaSingleLabelInt2StringTransformer,
        )
    return nothing
end

"""
"""
function fit!(
        transformer::ImmutablePredictProbaSingleLabelInt2StringTransformer,
        varargs...;
        kwargs...
        )
    if length(varargs) == 1
        return varargs[1]
    else
        return varargs
    end
end

"""
"""
function predict(
        transformer::ImmutablePredictProbaSingleLabelInt2StringTransformer,
        varargs...;
        kwargs...
        )
    if length(varargs) == 1
        return varargs[1]
    else
        return varargs
    end
end

"""
"""
function predict_proba(
        transformer::ImmutablePredictProbaSingleLabelInt2StringTransformer,
        singlelabelprobabilities::Associative;
        kwargs...
        )
    labelint2stringmap = _getlabelint2stringmap(
        transformer.levels,
        transformer.index,
        )
    result = Dict()
    for key in keys(singlelabelprobabilities)
        result[labelint2stringmap[key]] = singlelabelprobabilities[key]
    end
    result = fix_dict_type(result)
    return result
end
