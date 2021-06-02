
using SparseArrays
using MinimalRLCore

include("iht.jl")

# using MimimalRLCore
"""
    TileCoder(num_tilings, num_tiles, num_features, num_ints; wrap=false, wrapwidths=0.0)
Tile coder for coding all features together.
"""
mutable struct TileCoder{F}
    # Main Arguments
    tilings::Int
    tiles::Int
    dims::Int
    ints::Int

    # Optional Arguments
    wrap::Bool
    wrapwidths::Float64

    iht::TileCoding.IHT
    TileCoder{F}(num_tilings, num_tiles, num_features, num_ints=1; wrap=false, wrapwidths=0.0) where {F} =
        new{F}(num_tilings,
               num_tiles,
               num_features,
               num_ints,
               wrap,
               0.0,
               TileCoding.IHT(num_tilings*(num_tiles+1)^num_features * num_ints))
end

TileCoder(args...;kwargs...) = TileCoder{Vector{Int}}(args...; kwargs...)
SparseTileCoder(args...;kwargs...) = TileCoder{SparseVector{Int}}(args...; kwargs...)

function get_tc_indicies(fc::TileCoder, s; ints=[], readonly=false)
    if fc.wrap
        return 1 .+ TileCoding.tileswrap!(fc.iht, fc.tilings, s.*fc.tiles, fc.wrapwidths, ints, readonly)
    else
        return 1 .+ TileCoding.tiles!(fc.iht, fc.tilings, s.*fc.tiles, ints, readonly)
    end
end

MinimalRLCore.create_features(fc::TileCoder{Vector{Int}}, s; ints=[], readonly=false) = 
    get_tc_indicies(fc, s; ints=[], readonly=false)

function MinimalRLCore.create_features(fc::TileCoder{SparseVector{N}}, s; ints=[], readonly=false) where {N}
    idx = get_tc_indicies(fc, s; ints=[], readonly=false)
    s = spzeros(N, size(fc))
    s[idx] .= N(1)
    return s
end

# feature_size(fc::TileCoder) = fc.tilings*(fc.tiles+1)^fc.dims * fc.ints
Base.size(fc::TileCoder) = fc.tilings*(fc.tiles+1)^fc.dims * fc.ints

(fc::TileCoder)(s; ints=[], readonly=false) =
    create_features(fc, s; ints=ints, readonly=readonly)
