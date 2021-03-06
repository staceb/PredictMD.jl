import DataFrames
import StatsModels

"""
"""
mutable struct MutableDataFrame2DecisionTreeTransformer <:
        AbstractEstimator
    featurenames::T1 where T1 <: AbstractVector
    singlelabelname::T2 where T2 <: Symbol
    levels::T3 where T3 <: AbstractVector
    dffeaturecontrasts::T4 where T4 <: AbstractFeatureContrasts
    function MutableDataFrame2DecisionTreeTransformer(
            featurenames::AbstractVector,
            singlelabelname::Symbol;
            levels::AbstractVector = [],
            )
        result = new(
            featurenames,
            singlelabelname,
            levels,
            )
        return result
    end
end

"""
"""
function set_feature_contrasts!(
        x::MutableDataFrame2DecisionTreeTransformer,
        feature_contrasts::AbstractFeatureContrasts,
        )
    x.dffeaturecontrasts = feature_contrasts
    return nothing
end

"""
"""
function get_underlying(
        x::MutableDataFrame2DecisionTreeTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.dffeaturecontrasts
    return result
end

"""
"""
function get_history(
        x::MutableDataFrame2DecisionTreeTransformer;
        saving::Bool = false,
        loading::Bool = false,
        )
    return nothing
end

"""
"""
function transform(
        transformer::MutableDataFrame2DecisionTreeTransformer,
        features_df::DataFrames.AbstractDataFrame,
        labels_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    singlelabelname = transformer.singlelabelname
    labelsarray = convert(Array, labels_df[singlelabelname])
    modelformula = generate_formula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        features_df;
        contrasts = transformer.dffeaturecontrasts.contrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    return featuresarray, labelsarray
end

"""
"""
function transform(
        transformer::MutableDataFrame2DecisionTreeTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    modelformula = generate_formula(
        transformer.featurenames[1],
        transformer.featurenames;
        intercept = false
        )
    modelframe = StatsModels.ModelFrame(
        modelformula,
        features_df;
        contrasts = transformer.dffeaturecontrasts.contrasts,
        )
    modelmatrix = StatsModels.ModelMatrix(modelframe)
    featuresarray = modelmatrix.m
    return featuresarray
end

"""
"""
function parse_functions!(
    transformer::MutableDataFrame2DecisionTreeTransformer,
    )
    return nothing
end

"""
"""
function fit!(
        transformer::MutableDataFrame2DecisionTreeTransformer,
        features_df::DataFrames.AbstractDataFrame,
        labels_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, features_df, labels_df)
end

"""
"""
function predict(
        transformer::MutableDataFrame2DecisionTreeTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, features_df)
end

"""
"""
function predict_proba(
        transformer::MutableDataFrame2DecisionTreeTransformer,
        features_df::DataFrames.AbstractDataFrame;
        kwargs...
        )
    return transform(transformer, features_df)
end
