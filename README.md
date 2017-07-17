# DataArraysBinning.jl
Helper functions to pre-process continuous data by quantizing it into discrete bins.

DataFrames and DataArrays are super useful. However, there are some problems that are hard to work on with them. The problem I had when I opted to create this solution was I had a small sample of slot machine data, 1M rows, and there was a similarity index that was floating numbers between 0.0 and 1.0. 0.2999 is different than 0.2998 and 3.0 which means that, though they are very close, a lot of analysis functions will miss the bigger picture. The way this can be solved is by binning. So imagine being able to take an array with millions of these values and properly binning them.

```julia
da = DataArray(rand(10000000))
group_bins(da, :X, range(0.0, 0.5, 20))
```
