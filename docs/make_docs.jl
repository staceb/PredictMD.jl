import Documenter
import Literate
import PredictMD

srand(999)

ENV["PREDICTMD_IS_MAKE_DOCS"] = "true"

if is_windows()
    warn(
        string(
            "make_docs is not supported on Windows, so skipping",
            )
        )
else
    Documenter.makedocs(
        modules = [
            PredictMD,
            PredictMD.Clean,
            PredictMD.GPU,
            ],
        sitename = "PredictMD.jl",
        pages = Any[
            "index.md",
            "requirements_for_plotting.md",
            "library/internals.md",
            ],
        )
end

ENV["PREDICTMD_IS_MAKE_DOCS"] = "false"

