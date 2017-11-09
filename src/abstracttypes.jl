abstract type AbstractDataset
end

abstract type AbstractTabularDataset <: AbstractDataset
end

abstract type AbstractHoldoutTabularDataset <: AbstractTabularDataset
end

abstract type AbstractKFoldTabularDataset <: AbstractTabularDataset
end

abstract type AbstractModel
end

abstract type AbstractClassifier <: AbstractModel
end

abstract type AbstractSingleLabelClassifier <: AbstractClassifier
end

abstract type AbstractSingleLabelBinaryClassifier <:
    AbstractSingleLabelClassifier
end

abstract type AbstractRegression <: AbstractModel
end

abstract type AbstractSingleLabelRegression <: AbstractRegression
end

abstract type AbstractModelPerformance
end