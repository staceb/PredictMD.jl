###### Beginning of file

import PredictMD

#### Begin project-specific settings

PROJECT_OUTPUT_DIRECTORY = PredictMD.directory(
    homedir(),
    "Desktop",
    "breast_cancer_biopsy_example",
    )

#### End project-specific settings

#### Begin data preprocessing code

import CSV
import DataFrames
import RDatasets
import StatsBase

srand(999)

df = RDatasets.dataset("MASS", "biopsy")

categoricalfeaturenames = Symbol[]
continuousfeaturenames = Symbol[
    :V1,
    :V2,
    :V3,
    :V4,
    :V5,
    :V6,
    :V7,
    :V8,
    :V9,
    ]
featurenames = vcat(categoricalfeaturenames, continuousfeaturenames)

singlelabelname = :Class
negativeclass = "benign"
positiveclass = "malignant"
singlelabellevels = [negativeclass, positiveclass]

labelnames = [singlelabelname]

df = df[:, vcat(featurenames, labelnames)]
DataFrames.dropmissing!(df)
PredictMD.shuffle_rows!(df)

features_df = df[featurenames]
labels_df = df[labelnames]

(trainingandvalidation_features_df,
    trainingandvalidation_labels_df,
    testing_features_df,
    testing_labels_df,) = PredictMD.split_data(
        features_df,
        labels_df,
        0.75,
        )
(training_features_df,
    training_labels_df,
    validation_features_df,
    validation_labels_df,) = PredictMD.split_data(
        trainingandvalidation_features_df,
        trainingandvalidation_labels_df,
        2/3,
        )

trainingandvalidation_features_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "trainingandvalidation_features_df.csv",
    )
trainingandvalidation_labels_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "trainingandvalidation_labels_df.csv",
    )
testing_features_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "testing_features_df.csv",
    )
testing_labels_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "testing_labels_df.csv",
    )
training_features_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "training_features_df.csv",
    )
training_labels_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "training_labels_df.csv",
    )
validation_features_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "validation_features_df.csv",
    )
validation_labels_df_filename = joinpath(
    PROJECT_OUTPUT_DIRECTORY,
    "validation_labels_df.csv",
    )
CSV.write(
    trainingandvalidation_features_df_filename,
    trainingandvalidation_features_df,
    )
CSV.write(
    trainingandvalidation_labels_df_filename,
    trainingandvalidation_labels_df,
    )
CSV.write(
    testing_features_df_filename,
    testing_features_df,
    )
CSV.write(
    testing_labels_df_filename,
    testing_labels_df,
    )
CSV.write(
    training_features_df_filename,
    training_features_df,
    )
CSV.write(
    training_labels_df_filename,
    training_labels_df,
    )
CSV.write(
    validation_features_df_filename,
    validation_features_df,
    )
CSV.write(
    validation_labels_df_filename,
    validation_labels_df,
    )

#### End data preprocessing code

###### End of file
