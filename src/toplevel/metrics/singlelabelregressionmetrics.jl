import DataFrames
import MLBase
import StatsBase

"""
"""
function singlelabelregressionytrue(
        labels::AbstractVector;
        floattype::Type = Cfloat,
        )
    if !(floattype <: AbstractFloat)
        error("!(floattype <: AbstractFloat)")
    end
    result = floattype.(labels)
    return result
end

"""
"""
function singlelabelregressionypred(
        labels::AbstractVector;
        floattype::Type = Cfloat,
        )
    if !(floattype <: AbstractFloat)
        error("!(floattype <: AbstractFloat)")
    end
    result = floattype.(labels)
    return result
end

"""
"""
function _singlelabelregressionmetrics(
        estimator::Fittable,
        features_df::DataFrames.AbstractDataFrame,
        labels_df::DataFrames.AbstractDataFrame,
        singlelabelname::Symbol,
        )
    ytrue = singlelabelregressionytrue(
        labels_df[singlelabelname],
        )
    predictionsalllabels = predict(estimator, features_df)
    ypred = singlelabelregressionypred(
        predictionsalllabels[singlelabelname],
        )
    results = Dict()
    results[:r2_score] = r2_score(
        ytrue,
        ypred,
        )
    results[:mean_square_error] = mean_square_error(
        ytrue,
        ypred,
        )
    results[:root_mean_square_error] = root_mean_square_error(
        ytrue,
        ypred,
        )
    results = fix_dict_type(results)
    return results
end

"""
"""
function singlelabelregressionmetrics(
        estimator::Fittable,
        features_df::DataFrames.AbstractDataFrame,
        labels_df::DataFrames.AbstractDataFrame,
        singlelabelname::Symbol,
        )
    vectorofestimators = Fittable[estimator]
    result = singlelabelregressionmetrics(
        vectorofestimators,
        features_df,
        labels_df,
        singlelabelname,
        )
    return result
end

"""
"""
function singlelabelregressionmetrics(
        vectorofestimators::AbstractVector{Fittable},
        features_df::DataFrames.AbstractDataFrame,
        labels_df::DataFrames.AbstractDataFrame,
        singlelabelname::Symbol;
        kwargs...
        )
    metricsforeachestimator = [
        _singlelabelregressionmetrics(
            est,
            features_df,
            labels_df,
            singlelabelname,
            )
            for est in vectorofestimators
        ]
    result = DataFrames.DataFrame()
    result[:metric] = [
        "R^2 (coefficient of determination)",
        "Mean squared error (MSE)",
        "Root mean square error (RMSE)",
        ]
    for i = 1:length(vectorofestimators)
        result[Symbol(vectorofestimators[i].name)] = [
            metricsforeachestimator[i][:r2_score],
            metricsforeachestimator[i][:mean_square_error],
            metricsforeachestimator[i][:root_mean_square_error],
            ]
    end
    return result
end
