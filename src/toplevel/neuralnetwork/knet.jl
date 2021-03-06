import AutoGrad
import Knet
import ProgressMeter
import ValueHistories

"""
"""
mutable struct KnetModel <: AbstractEstimator
    name::T1 where T1 <: AbstractString
    isclassificationmodel::T2 where T2 <: Bool
    isregressionmodel::T3 where T3 <: Bool

    # hyperparameters (not learned from data):
    predict_function_source::T4 where T4 <: AbstractString
    loss_function_source::T5 where T5 <: AbstractString
    predict_function::T6 where T6 <: Union{Void, Function, Any}
    loss_function::T7 where T7 <: Union{Void, Function, Any}
    losshyperparameters::T8 where T8 <: Associative
    optimizationalgorithm::T9 where T9 <: Symbol
    optimizerhyperparameters::T10 where T10 <: Associative
    minibatchsize::T11 where T11 <: Integer
    maxepochs::T12 where T12 <: Integer
    printlosseverynepochs::T13 where T13 <: Integer

    # parameters (learned from data):
    modelweights::T14 where T14 <: AbstractArray
    modelweightoptimizers::T15 where T15 <: Any

    # learning state
    history::T16 where T16 <: ValueHistories.MultivalueHistory

    function KnetModel(
            ;
            name::AbstractString = "",
            predict_function_source::AbstractString = "",
            loss_function_source::AbstractString = "",
            predict_function::Function = identity,
            loss_function::Function = identity,
            losshyperparameters::Associative = Dict(),
            optimizationalgorithm::Symbol = :nothing,
            optimizerhyperparameters::Associative = Dict(),
            minibatchsize::Integer = 0,
            modelweights::AbstractArray = [],
            isclassificationmodel::Bool = false,
            isregressionmodel::Bool = false,
            maxepochs::Integer = 0,
            printlosseverynepochs::Integer = 0,
            )
        optimizersymbol2type = Dict()
        optimizersymbol2type[:Sgd] = Knet.Sgd
        optimizersymbol2type[:Momentum] = Knet.Momentum
        optimizersymbol2type[:Nesterov] = Knet.Nesterov
        optimizersymbol2type[:Rmsprop] = Knet.Rmsprop
        optimizersymbol2type[:Adagrad] = Knet.Adagrad
        optimizersymbol2type[:Adadelta] = Knet.Adadelta
        optimizersymbol2type[:Adam] = Knet.Adam
        optimizersymbol2type = fix_dict_type(optimizersymbol2type)
        modelweightoptimizers = Knet.optimizers(
            modelweights,
            optimizersymbol2type[optimizationalgorithm];
            optimizerhyperparameters...
            )
        lastepoch = 0
        lastiteration = 0
        history = ValueHistories.MVHistory()
        ValueHistories.push!(
            history,
            :epoch_at_iteration,
            0,
            0,
            )
        losshyperparameters = fix_dict_type(losshyperparameters)
        optimizerhyperparameters = fix_dict_type(optimizerhyperparameters)
        result = new(
            name,
            isclassificationmodel,
            isregressionmodel,
            predict_function_source,
            loss_function_source,
            predict_function,
            loss_function,
            losshyperparameters,
            optimizationalgorithm,
            optimizerhyperparameters,
            minibatchsize,
            maxepochs,
            printlosseverynepochs,
            modelweights,
            modelweightoptimizers,
            history,
            )
        return result
    end
end

"""
"""
function set_feature_contrasts!(
        x::KnetModel,
        feature_contrasts::AbstractFeatureContrasts,
        )
    return nothing
end

"""
"""
function get_underlying(
        x::KnetModel;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = (x.modelweights, x.modelweightoptimizers,)
    return result
end

"""
"""
function get_history(
        x::KnetModel;
        saving::Bool = false,
        loading::Bool = false,
        )
    result = x.history
    return result
end

function parse_functions!(estimator::KnetModel)
    estimator.predict_function = eval(
        parse(
            strip(
                estimator.predict_function_source
                )
            )
        )
    estimator.loss_function = eval(
        parse(
            strip(
                estimator.loss_function_source
                )
            )
        )
    return nothing
end

"""
"""
function fit!(
        estimator::KnetModel,
        training_features_array::AbstractArray,
        training_labels_array::AbstractArray,
        validation_features_array::Union{Void, AbstractArray} = nothing,
        validation_labels_array::Union{Void, AbstractArray} = nothing,
        )
    if is_nothing(validation_features_array) &&
            is_nothing(validation_labels_array)
        has_validation_data = false
    elseif !is_nothing(validation_features_array) &&
                !is_nothing(validation_labels_array)
        has_validation_data = true
    else
        error(
            string(
                "Either define both validation_features_array and ",
                "validation_labels_array, or define neither.",)
            )
    end
    training_features_array = Cfloat.(training_features_array)
    if estimator.isclassificationmodel && !estimator.isregressionmodel
        training_labels_array = Int.(training_labels_array)
    elseif !estimator.isclassificationmodel && estimator.isregressionmodel
        training_labels_array = Cfloat.(training_labels_array)
    else
        error(
            "Could not figure out if model is classification or regression"
            )
    end
    training_data = Knet.minibatch(
        training_features_array,
        training_labels_array,
        estimator.minibatchsize,
        )
    loss_function_gradient = Knet.grad(
        estimator.loss_function,
        2,
        )
    all_iterations_so_far, all_epochs_so_far = ValueHistories.get(
        estimator.history,
        :epoch_at_iteration,
        )
    last_iteration = all_iterations_so_far[end]
    last_epoch = all_epochs_so_far[end]
    info(
        string(
            "Starting to train Knet.jl model. Max epochs: ",
            estimator.maxepochs,
            ".",
            )
        )
    training_lossbeforetrainingstarts = estimator.loss_function(
        estimator.predict_function,
        estimator.modelweights,
        training_features_array,
        training_labels_array;
        estimator.losshyperparameters...
        )
    if has_validation_data
        validation_lossbeforetrainingstarts = estimator.loss_function(
           estimator.predict_function,
           estimator.modelweights,
           validation_features_array,
           validation_labels_array;
           estimator.losshyperparameters...
           )
    end
    if (estimator.printlosseverynepochs) > 0
        if has_validation_data
            info(
                string(
                    "Epoch: ",
                    last_epoch,
                    ". Loss (training set): ",
                    training_lossbeforetrainingstarts,
                    ". Loss (validation set): ",
                    validation_lossbeforetrainingstarts,
                    ".",
                    )
                )
        else
            info(
                string(
                    "Epoch: ",
                    lastepoch,
                    ". Loss: ",
                    lossbeforetrainingstarts,
                    "."
                    )
                )
        end
    end
    while last_epoch < estimator.maxepochs
        for (x_training, y_training) in training_data
            grads = loss_function_gradient(
                estimator.predict_function,
                estimator.modelweights,
                x_training,
                y_training;
                estimator.losshyperparameters...
                )
            Knet.update!(
                estimator.modelweights,
                grads,
                estimator.modelweightoptimizers,
                )
            last_iteration += 1
            training_currentiterationloss = estimator.loss_function(
                estimator.predict_function,
                estimator.modelweights,
                x_training,
                y_training;
                estimator.losshyperparameters...
                )
            ValueHistories.push!(
                estimator.history,
                :training_loss_at_iteration,
                last_iteration,
                training_currentiterationloss,
                )
        end # end for
        last_epoch += 1
        ValueHistories.push!(
            estimator.history,
            :epoch_at_iteration,
            last_iteration,
            last_epoch,
            )
        training_currentepochloss = estimator.loss_function(
            estimator.predict_function,
            estimator.modelweights,
            training_features_array,
            training_labels_array;
            estimator.losshyperparameters...
            )
        ValueHistories.push!(
            estimator.history,
            :training_loss_at_epoch,
            last_epoch,
            training_currentepochloss,
            )
        if has_validation_data
            validation_currentepochloss = estimator.loss_function(
                estimator.predict_function,
                estimator.modelweights,
                validation_features_array,
                validation_labels_array;
                estimator.losshyperparameters...
                )
            ValueHistories.push!(
                estimator.history,
                :validation_loss_at_epoch,
                last_epoch,
                validation_currentepochloss,
                )
        end
        printlossthisepoch = (estimator.printlosseverynepochs > 0) &&
            ( (last_epoch == estimator.maxepochs) ||
                ( (last_epoch %
                    estimator.printlosseverynepochs) == 0 ) )
        if printlossthisepoch
            if has_validation_data
                info(
                   string(
                       "Epoch: ",
                       last_epoch,
                       ". Loss (training set): ",
                       training_currentepochloss,
                       ". Loss (validation set): ",
                       validation_currentepochloss,
                       ".",
                       ),
                   )
            else
                info(
                   string(
                       "Epoch: ",
                       last_epoch,
                       ". Loss: ",
                       training_currentepochloss,
                       ".",
                       ),
                   )
            end
        end
    end # end while
    info(string("Finished training Knet.jl model."))
    return estimator
end

"""
"""
function predict(
        estimator::KnetModel,
        featuresarray::AbstractArray,
        )
    if estimator.isclassificationmodel
        probabilitiesassoc = predict_proba(
            estimator,
            featuresarray,
            )
        predictionsvector = singlelabelprobabilitiestopredictions(
            probabilitiesassoc
            )
        return predictionsvector
    elseif estimator.isregressionmodel
        output = estimator.predict_function(
            estimator.modelweights,
            featuresarray;
            )
        outputtransposed = transpose(output)
        result = convert(Array, outputtransposed)
        return result
    else
        error("unable to predict")
    end
end

"""
"""
function predict_proba(
        estimator::KnetModel,
        featuresarray::AbstractArray,
        )
    if estimator.isclassificationmodel
        output = estimator.predict_function(
            estimator.modelweights,
            featuresarray;
            probabilities = true,
            )
        outputtransposed = transpose(output)
        numclasses = size(outputtransposed, 2)
        result = Dict()
        for i = 1:numclasses
            result[i] = outputtransposed[:, i]
        end
        return result
    elseif estimator.isregressionmodel
        error("predict_proba is not defined for regression models")
    else
        error("unable to predict")
    end
end

"""
"""
function _singlelabelmulticlassdataframeknetclassifier_Knet(
        featurenames::AbstractVector,
        singlelabelname::Symbol,
        singlelabellevels::AbstractVector;
        name::AbstractString = "",
        predict_function_source::AbstractString = "",
        loss_function_source::AbstractString = "",
        losshyperparameters::Associative = Dict(),
        optimizationalgorithm::Symbol = :nothing,
        optimizerhyperparameters::Associative = Dict(),
        minibatchsize::Integer = 0,
        modelweights::AbstractArray = [],
        maxepochs::Integer = 0,
        printlosseverynepochs::Integer = 0,
        feature_contrasts::Union{Void, AbstractFeatureContrasts} =
            nothing,
        )
    labelnames = [singlelabelname]
    labellevels = Dict()
    labellevels[singlelabelname] = singlelabellevels
    labellevels = fix_dict_type(labellevels)
    dftransformer_index = 1
    dftransformer_transposefeatures = true
    dftransformer_transposelabels = true
    dftransformer = MutableDataFrame2ClassificationKnetTransformer(
        featurenames,
        labelnames,
        labellevels,
        dftransformer_index;
        transposefeatures = dftransformer_transposefeatures,
        transposelabels = dftransformer_transposelabels,
        )
    knetestimator = KnetModel(
        ;
        name = name,
        predict_function_source = predict_function_source,
        loss_function_source = loss_function_source,
        losshyperparameters = losshyperparameters,
        optimizationalgorithm = optimizationalgorithm,
        optimizerhyperparameters = optimizerhyperparameters,
        minibatchsize = minibatchsize,
        modelweights = modelweights,
        isclassificationmodel = true,
        isregressionmodel = false,
        maxepochs = maxepochs,
        printlosseverynepochs = printlosseverynepochs,
        )
    predprobalabelfixer =
            ImmutablePredictProbaSingleLabelInt2StringTransformer(
                        1,
                        singlelabellevels
                        )
    predictlabelfixer =
            ImmutablePredictionsSingleLabelInt2StringTransformer(
                        1,
                        singlelabellevels
                        )
    probapackager = ImmutablePackageSingleLabelPredictProbaTransformer(
        singlelabelname,
        )
    predpackager = ImmutablePackageSingleLabelPredictionTransformer(
        singlelabelname,
        )
    finalpipeline = SimplePipeline(
        Fittable[
            dftransformer,
            knetestimator,
            predprobalabelfixer,
            predictlabelfixer,
            probapackager,
            predpackager
            ];
        name = name,
        )
    if !is_nothing(feature_contrasts)
        set_feature_contrasts!(finalpipeline, feature_contrasts)
    end
    return finalpipeline
end

"""
"""
function singlelabelmulticlassdataframeknetclassifier(
        featurenames::AbstractVector,
        singlelabelname::Symbol,
        singlelabellevels::AbstractVector;
        package::Symbol = :none,
        name::AbstractString = "",
        predict_function_source::AbstractString = "",
        loss_function_source::AbstractString = "",
        losshyperparameters::Associative = Dict(),
        optimizationalgorithm::Symbol = :nothing,
        optimizerhyperparameters::Associative = Dict(),
        minibatchsize::Integer = 0,
        modelweights::AbstractArray = [],
        maxepochs::Integer = 0,
        printlosseverynepochs::Integer = 0,
        feature_contrasts::Union{Void, AbstractFeatureContrasts} =
            nothing,
        )
    if package == :Knetjl
        result = _singlelabelmulticlassdataframeknetclassifier_Knet(
            featurenames,
            singlelabelname,
            singlelabellevels;
            name = name,
            predict_function_source = predict_function_source,
            loss_function_source = loss_function_source,
            losshyperparameters = losshyperparameters,
            optimizationalgorithm = optimizationalgorithm,
            optimizerhyperparameters = optimizerhyperparameters,
            minibatchsize = minibatchsize,
            modelweights = modelweights,
            maxepochs = maxepochs,
            printlosseverynepochs = printlosseverynepochs,
            feature_contrasts = feature_contrasts
            )
        return result
    else
        error("$(package) is not a valid value for package")
    end
end

"""
"""
function _singlelabeldataframeknetregression_Knet(
        featurenames::AbstractVector,
        singlelabelname::Symbol;
        name::AbstractString = "",
        predict_function_source::AbstractString = "",
        loss_function_source::AbstractString = "",
        losshyperparameters::Associative = Dict(),
        optimizationalgorithm::Symbol = :nothing,
        optimizerhyperparameters::Associative = Dict(),
        minibatchsize::Integer = 0,
        modelweights::AbstractArray = [],
        maxepochs::Integer = 0,
        printlosseverynepochs::Integer = 0,
        feature_contrasts::Union{Void, AbstractFeatureContrasts} =
            nothing,
        )
    labelnames = [singlelabelname]
    dftransformer_index = 1
    dftransformer_transposefeatures = true
    dftransformer_transposelabels = true
    dftransformer = MutableDataFrame2RegressionKnetTransformer(
        featurenames,
        labelnames;
        transposefeatures = true,
        transposelabels = true,
        )
    knetestimator = KnetModel(
        ;
        name = name,
        predict_function_source = predict_function_source,
        loss_function_source = loss_function_source,
        losshyperparameters = losshyperparameters,
        optimizationalgorithm = optimizationalgorithm,
        optimizerhyperparameters = optimizerhyperparameters,
        minibatchsize = minibatchsize,
        modelweights = modelweights,
        isclassificationmodel = false,
        isregressionmodel = true,
        maxepochs = maxepochs,
        printlosseverynepochs = printlosseverynepochs,
        )
    predpackager = ImmutablePackageMultiLabelPredictionTransformer(
        [singlelabelname,],
        )
    finalpipeline = SimplePipeline(
        Fittable[
            dftransformer,
            knetestimator,
            predpackager,
            ];
        name = name,
        )
    if !is_nothing(feature_contrasts)
        set_feature_contrasts!(finalpipeline, feature_contrasts)
    end
    return finalpipeline
end

"""
"""
function singlelabeldataframeknetregression(
        featurenames::AbstractVector,
        singlelabelname::Symbol;
        package::Symbol = :none,
        name::AbstractString = "",
        predict_function_source::AbstractString = "",
        loss_function_source::AbstractString = "",
        losshyperparameters::Associative = Dict(),
        optimizationalgorithm::Symbol = :nothing,
        optimizerhyperparameters::Associative = Dict(),
        minibatchsize::Integer = 0,
        modelweights::AbstractArray = [],
        maxepochs::Integer = 0,
        printlosseverynepochs::Integer = 0,
        feature_contrasts::Union{Void, AbstractFeatureContrasts} =
            nothing,
        )
    if package == :Knetjl
        result = _singlelabeldataframeknetregression_Knet(
            featurenames,
            singlelabelname;
            name = name,
            predict_function_source = predict_function_source,
            loss_function_source = loss_function_source,
            losshyperparameters = losshyperparameters,
            optimizationalgorithm = optimizationalgorithm,
            optimizerhyperparameters = optimizerhyperparameters,
            minibatchsize = minibatchsize,
            modelweights = modelweights,
            maxepochs = maxepochs,
            printlosseverynepochs = printlosseverynepochs,
            feature_contrasts = feature_contrasts
            )
        return result
    else
        error("$(package) is not a valid value for package")
    end
end
