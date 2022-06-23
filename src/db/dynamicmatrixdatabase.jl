# This file is a part of SimilaritySearch.jl


"""
    struct DynamicMatrixDatabase{DType,Dim} <: AbstractDatabase

A dynamic matrix with elements of type `DType` and dimension `Dim` 
"""
struct DynamicMatrixDatabase{DType,Dim} <: AbstractDatabase
    data::Vector{DType}
end

#
# Dynamic matrix-like dataset, i.e., columns are objects. Stored as a large vector to support appending items
#

"""
    eltype(db::DynamicMatrixDatabase{DType,Dim})

The type of stored elements `AbstractVector{DType}`
"""
@inline Base.eltype(db::DynamicMatrixDatabase{DType,Dim}) where {DType,Dim} = AbstractVector{DType}

"""
    DynamicMatrixDatabase(matrix::AbstractMatrix{DType})

Creates a `DynamicMatrixDatabase` from a matrix-like object. Please see [`AbstractDatabase`](@ref) for general usage.
"""
DynamicMatrixDatabase(matrix::AbstractMatrix{DType}) where DType = DynamicMatrixDatabase{DType,size(matrix, 1)}(vec(matrix))

"""
    DynamicMatrixDatabase(::Type{DType}, Dim::Integer)

Creates an empty `DynamicMatrixDatabase` such that `length(db[i]) == Dim` and `eltype(db[i]) == DType`
"""
DynamicMatrixDatabase(::Type{DType}, Dim::Integer) where DType = DynamicMatrixDatabase{DType,Dim}(Vector{DType}(undef, 0))

"""
    DynamicMatrixDatabase(V::DynamicMatrixDatabase{DType,Dim})    

Creates a `DynamicMatrixDatabase` from another `DynamicMatrixDatabase`, they will share their internal data. Please see [`AbstractDatabase`](@ref) for general usage.
"""
DynamicMatrixDatabase(V::DynamicMatrixDatabase{DType,Dim}) where {DType,Dim} = DynamicMatrixDatabase{DType,Dim}(V.data)

@inline function Base.getindex(db::DynamicMatrixDatabase{DType,Dim}, i::Integer) where {DType,Dim}
    ep = i * Dim
    @inbounds @view db.data[(ep - Dim + 1):ep]
end
@inline Base.setindex!(db::DynamicMatrixDatabase, value, i) = @inbounds (db.data[i] .= value)

@inline Base.length(db::DynamicMatrixDatabase{DType,Dim}) where {DType,Dim} = length(db.data) ÷ Dim
@inline function Base.push!(db::DynamicMatrixDatabase{DType,Dim}, v) where {DType,Dim}
    append!(db.data, v)
    db
end

@inline Base.append!(a::DynamicMatrixDatabase{DType,Dim}, b::DynamicMatrixDatabase{DType2,Dim})  where {DType,Dim,DType2} = append!(a.data, b.data)
@inline function Base.append!(db::DynamicMatrixDatabase{DType,Dim}, B) where {DType,Dim}
    sizehint!(db.data, length(db.data) + Dim * length(B))
    for b in B
        push!(db, b)
    end

    db
end