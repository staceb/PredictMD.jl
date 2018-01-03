import ClassImbalance
import DataFrames

function _calculate_smote_pct_under(
        ;
        pct_over::Real = 0,
        minority_to_majority_ratio::Real = 0,
        )
    if pct_over < 0
        error("pct_over must be >=0")
    end
    if minority_to_majority_ratio <= 0
        error("minority_to_majority_ratio must be >0")
    end
    result = 100*minority_to_majority_ratio*(100+pct_over)/pct_over
    return result
end

function smote(
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame,
        featurenames::VectorOfSymbols,
        labelname::Symbol;
        majorityclass::AbstractString = "",
        minorityclass::AbstractString = "",
        pct_over::Real = 0,
        minority_to_majority_ratio::Real = 0,
        k::Integer = 5,
        )
    result = smote(
        Base.GLOBAL_RNG,
        featuresdf,
        labelsdf,
        featurenames,
        labelname,
        majorityclass = majorityclass,
        minorityclass = minorityclass,
        pct_over = pct_over,
        minority_to_majority_ratio = minority_to_majority_ratio,
        k = k,
        )
    return result
end

function smote(
        rng::AbstractRNG,
        featuresdf::DataFrames.AbstractDataFrame,
        labelsdf::DataFrames.AbstractDataFrame,
        featurenames::VectorOfSymbols,
        labelname::Symbol;
        majorityclass::AbstractString = "",
        minorityclass::AbstractString = "",
        pct_over::Real = 0,
        minority_to_majority_ratio::Real = 0,
        k::Integer = 5,
        )
    if majorityclass == ""
        error("you need to specify majorityclass")
    end
    if minorityclass == ""
        error("you need to specify minorityclass")
    end
    pct_under = _calculate_smote_pct_under(
        ;
        pct_over = pct_over,
        minority_to_majority_ratio = minority_to_majority_ratio,
        )
    if size(featuresdf, 1) !== size(labelsdf, 1)
        error("size(featuresdf, 1) !== size(labelsdf, 1)")
    end
    if size(featuresdf, 1) == 0
        error("size(featuresdf, 1) == 0")
    end
    labelsstringarray = labelsdf[labelname]
    labelsbinaryarray = zeros(Int, length(labelsstringarray))
    for i = 1:length(labelsstringarray)
        # Paul's smote code assumes 1 = minority, 0 = majority
        if labelsstringarray[i] == minorityclass
            labelsbinaryarray[i] = 1
        elseif labelsstringarray[i] == majorityclass
            labelsbinaryarray[i] = 0
        else
            error("value in labels column is neither majority nor minority")
        end
    end
    smotedfeaturesdf, smotedlabelsbinaryarray = ClassImbalance.smote(
        featuresdf[featurenames],
        labelsbinaryarray;
        k = k,
        pct_over = pct_over,
        pct_under = pct_under,
        )
    smotedlabelsstringarray = Array{String}(length(smotedlabelsbinaryarray))
    for i = 1:length(smotedlabelsbinaryarray)
        if smotedlabelsbinaryarray[i] == 1
            smotedlabelsstringarray[i] = minorityclass
        elseif smotedlabelsbinaryarray[i] == 0
            smotedlabelsstringarray[i] = majorityclass
        else
            error("if you see this error, you will be very sad.")
        end
    end
    smotedlabelsdf = DataFrames.DataFrame()
    smotedlabelsdf[labelname] = smotedlabelsstringarray
    return smotedfeaturesdf, smotedlabelsdf
end
