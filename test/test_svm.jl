srand(999)

import DataFrames
import StatsBase

num_rows = 10_000
dataframe, label_variables, feature_variables =
    AluthgeSinhaBase.generatefaketabulardata1(num_rows)

StatsBase.countmap(dataframe[:mylabel1])

tabular_dataset = HoldoutTabularDataset(
    dataframe,
    label_variables,
    feature_variables;
    training=0.5,
    validation=0.2,
    testing=0.3,
    )

svm_binary_classifier = BinarySVM(
    tabular_dataset,
    :mylabel1,
    )

@test(
    typeof(svm_binary_classifier) <:
        AbstractSingleLabelBinaryClassifier
    )

performance(svm_binary_classifier)

##############################################################################

num_rows = 10_000
dataframe, label_variables, feature_variables =
    AluthgeSinhaBase.generatefaketabulardata2(num_rows)

StatsBase.countmap(dataframe[:y])

tabular_dataset = HoldoutTabularDataset(
    dataframe,
    label_variables,
    feature_variables;
    training=1/3,
    validation=1/3,
    testing=1/3,
    )

svm_binary_classifier = BinarySVM(
    tabular_dataset,
    :y,
    )

@test(
    typeof(svm_binary_classifier) <:
        AbstractSingleLabelBinaryClassifier
    )

x = performance(svm_binary_classifier)

##############################################################################

num_rows = 10_000
dataframe, label_variables, feature_variables =
    AluthgeSinhaBase.generatefaketabulardata3(num_rows)

StatsBase.countmap(dataframe[:deathoutcome])

tabular_dataset = HoldoutTabularDataset(
    dataframe,
    label_variables,
    feature_variables;
    training=0.7,
    testing=0.3,
    )

svm_binary_classifier = BinarySVM(
    tabular_dataset,
    :deathoutcome,
    )

@test(
    typeof(svm_binary_classifier) <:
        AbstractSingleLabelBinaryClassifier
    )

performance(svm_binary_classifier)
