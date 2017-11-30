### Binning
# A bin is a range of values between which values are grouped. Bins range from
# 1 to however many bins are selected. This allows for continuous data to be used
# for classification or histograms or other analysis.

using DataFrames

SampleSpaceTooSmall = AssertionError("equalfrequencylimits(dv, bins) -> bins is not less than the length of dv. Reduce bins.")
BinWidthTooSmall = AssertionError("equalfrequencylimits(dv, bins) -> The calculated width of the bins is too small for sample space. Add more data or reduce bins.")

function equaldistancelimits(dv::Vector{<:AbstractFloat}, bins::Signed)
    min = minimum(dv); max = maximum(dv); binwidth = (max-min)/bins
    return(min:binwidth:max)
end

function equalfrequencylimits(dv::Vector{<:AbstractFloat}, bins::Signed)
    if bins > length(dv)
        throw(SampleSpaceTooSmall)
    end
    sorteddv = sort(dv)
    elements = length(dv); binwidth = div(elements, bins)
    if binwidth < 1
        throw(BinWidthTooSmall)
    end
    binrange = zeros(Float64, bins)
    for i in 1:bins
        binrange[i] = dv[i*binwidth]
    end
    if mod(elements,bins) > 0 binrange[end] = dv[end] end
    return binrange
end

function find_bin(x::AbstractFloat, limits::Vector{<:AbstractFloat})
    bin = length(limits) + 1
    for i in 1:length(limits)
        if x < limits[i]
            bin = i
            break
        end
    end
    bin
end

function find_bin(x::AbstractFloat, limits::StepRangeLen{<:AbstractFloat})
    bin = length(limits) + 1
    for i in 1:length(limits)
        if x < limits[i]
            bin = i
            break
        end
    end
    bin
end

function find_bins(dv::Vector{<:AbstractFloat}, limits::Vector{<:AbstractFloat})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

function find_bins(dv::Vector{<:AbstractFloat}, limits::StepRangeLen{<:AbstractFloat})
    vbins = zeros(Int64, length(dv))
    for i in 1:length(dv)
        vbins[i] = find_bin(dv[i], limits)
    end
    vbins
end

function group_bins{T}(df::AbstractDataFrame, col::T, limits::Vector{AbstractFloat})
    n_bins = length(limits) + 1

    vbins = find_bins(df[col], limits)
    (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)

    # Remove zero-length groupings
    starts = _uniqueofsorted(starts)
    ends = [starts[2:end] - 1]
    GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
end

function group_bins{T}(df::AbstractDataFrame, col::T, limits::StepRangeLen{AbstractFloat})
    n_bins = length(limits) + 1

    vbins = find_bins(df[col], limits)
    (idx, starts) = DataArrays.groupsort_indexer(vbins, n_bins)

    # Remove zero-length groupings
    starts = unique(starts)
    ends = [starts[2:end] - 1]
    GroupedDataFrame(df, [col], idx, starts[1:end-1], ends)
end

x = [0.62, 0.99, 0.52, 0.03, 0.55, 0.74, 0.49, 0.31, 0.62, 0.19]
x_df = DataFrame(X=x, Y=rand(10))

group_bins(x_df, :X, range(0.0, 0.5, 20))
