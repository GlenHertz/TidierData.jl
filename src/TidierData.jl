module TidierData

using DataFrames
using MacroTools
using Chain
using Statistics
using Cleaner
using Reexport

# Exporting `Cols` because `summarize(!!vars, funs))` with multiple interpolated
# columns requires `Cols()` to be nested within `Cols()`, so `Cols` needs to be exported.
@reexport using DataFrames: DataFrame, Cols, describe, nrow, proprow, Not, Between, select
@reexport using Chain
@reexport using Statistics
@reexport using ShiftedArrays: lag, lead

export TidierData_set, across, desc, n, row_number, starts_with, ends_with, matches, if_else, case_when, ntile, 
      as_float, as_integer, as_string, is_float, is_string, is_categorical, is_integer, @select, @transmute, @rename, @mutate, @summarize, @summarise, @filter,
      @group_by, @ungroup, @slice, @arrange, @distinct, @pull, @left_join, @right_join, @inner_join, @full_join,
      @pivot_wider, @pivot_longer, @bind_rows, @bind_cols, @clean_names, @count, @tally, @drop_na, @glimpse, @separate,
      @unite, @summary, @fill_missing

# Package global variables
const code = Ref{Bool}(false) # output DataFrames.jl code?
const log = Ref{Bool}(false) # output tidylog output? (not yet implemented)

# Expose the global do-not-vectorize "list"
const not_vectorized = Ref{Vector{Symbol}}([:Ref, :Set, :Cols, :(:), :∘, :lag, :lead, :ntile, :repeat, :across, :desc, :mean, :std, :var, :median, :first, :last, :minimum, :maximum, :sum, :length, :skipmissing, :quantile, :passmissing, :cumsum, :cumprod, :accumulate])

# Includes
include("docstrings.jl")
include("parsing.jl")
include("joins.jl")
include("binding.jl")
include("pivots.jl")
include("compound_verbs.jl")
include("clean_names.jl")
include("conditionals.jl")
include("pseudofunctions.jl")
include("helperfunctions.jl")
include("ntile.jl")
include("type_conversions.jl")
include("separate_unite.jl")
include("summary.jl")
include("is_type.jl")

# Function to set global variables
"""
$docstring_TidierData_set
"""
function TidierData_set(option::AbstractString, value::Bool)
  if option == "code"
    code[] = value
  elseif option == "log"
    throw("Logging is not enabled yet")
  else
    throw("That is not a valid option.")
  end
end

"""
$docstring_select
"""
macro select(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end    
        end
        select($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        select($(tidy_exprs...))
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_transmute
"""
macro transmute(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end    
        end
        select($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        select($(tidy_exprs...))
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_rename
"""
macro rename(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end    
        end
        rename($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        rename($(tidy_exprs...))
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_mutate
"""
macro mutate(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end    
        end
        transform($(tidy_exprs...); ungroup = false)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        transform($(tidy_exprs...))
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_summarize
"""
macro summarize(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs; summarize = true)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs; autovec=false)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if length(col_names) == 1
            @chain _ begin
              combine(_, $(tidy_exprs...); ungroup = true)
              select(_, Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
            end
          else
            @chain _ begin
              combine(_, $(tidy_exprs...); ungroup = true)
              select(_, Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
              groupby(_, col_names[1:end-1]; sort = true)
            end
          end
        end
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end  
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end  
        end
        combine($(tidy_exprs...))
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_summarize
"""
macro summarise(df, exprs...)
  :(@summarize($(esc(df)), $(exprs...)))
end

"""
$docstring_filter
"""
macro filter(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs; subset=true)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n; ungroup = false)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number; ungroup = false)
          else
            _
          end    
        end
        subset($(tidy_exprs...); skipmissing = true, ungroup = false)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")); ungroup = false)
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        subset($(tidy_exprs...); skipmissing = true)
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_group_by
"""
macro group_by(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  grouping_exprs = parse_group_by.(exprs)

  df_expr = quote
    @chain $(esc(df)) begin
      @chain _ begin
        if $any_found_n
          transform(_, nrow => :TidierData_n)
        else
          _
        end
      end
      @chain _ begin
        if $any_found_row_number
          transform(_, eachindex => :TidierData_row_number)
        else
          _
        end
      end
      transform($(tidy_exprs...))
      select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      groupby(Cols($(grouping_exprs...)); sort = true)
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_ungroup
"""
macro ungroup(df)
  :(DataFrame($(esc(df))))
end

"""
$docstring_slice
"""
macro slice(df, exprs...)
  df_expr = quote
    local interpolated_indices = parse_slice_n.($exprs, nrow(DataFrame($(esc(df)))))
    local original_indices = [eval.(interpolated_indices)...]
    local clean_indices = Int64[]
    for index in original_indices
      if index isa Number
        push!(clean_indices, index)
      else
        append!(clean_indices, collect(index))
      end
    end
    
    if all(clean_indices .> 0)
      if $(esc(df)) isa GroupedDataFrame
        combine($(esc(df)); ungroup = false) do sdf
          sdf[clean_indices, :]
        end
      else
        combine($(esc(df))) do sdf
          sdf[clean_indices, :]
        end
      end
    elseif all(clean_indices .< 0)
      clean_indices = -clean_indices
      if $(esc(df)) isa GroupedDataFrame
        combine($(esc(df)); ungroup = true) do sdf
          sdf[Not(clean_indices), :]
        end
      else
        combine($(esc(df))) do sdf
          sdf[Not(clean_indices), :]
        end
      end
    else
      throw("@slice() indices must either be all positive or all negative.")
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_arrange
"""
macro arrange(df, exprs...)
  arrange_exprs = parse_desc.(exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      
      @chain $(esc(df)) begin
        DataFrame # remove grouping
        sort([$(arrange_exprs...)]) # Must use [] instead of Cols() here
        groupby(col_names; sort = true) # regroup
      end
    else
      sort($(esc(df)), [$(arrange_exprs...)]) # Must use [] instead of Cols() here
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_distinct
"""
macro distinct(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]
  any_found_n = any([i[2] for i in interpolated_exprs])
  any_found_row_number = any([i[3] for i in interpolated_exprs])

  tidy_exprs = parse_tidy.(tidy_exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      @chain $(esc(df)) begin
        DataFrame # remove grouping because `unique()` does not work on GroupDataFrames
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end    
        end
        @chain _ begin
          if length([$tidy_exprs...]) == 0
            unique(_)
          else
            unique(_, Cols($(tidy_exprs...)))
          end
        end
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
        groupby(col_names; sort = true) # regroup
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $any_found_n
            transform(_, nrow => :TidierData_n)
          else
            _
          end
        end
        @chain _ begin
          if $any_found_row_number
            transform(_, eachindex => :TidierData_row_number)
          else
            _
          end
        end
        @chain _ begin
          if length([$tidy_exprs...]) == 0
            unique(_)
          else
            unique(_, Cols($(tidy_exprs...)))
          end
        end
        select(Cols(Not(r"^(TidierData_n|TidierData_row_number)$")))
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_pull
"""
macro pull(df, column)
  column, found_n, found_row_number = parse_interpolation(column)
  column = parse_tidy(column)
  vec_expr = quote
    $(esc(df))[:, $column]
  end
  if code[]
    @info MacroTools.prettify(vec_expr)
  end
  return vec_expr
end

"""
$docstring_drop_na
"""
macro drop_na(df, exprs...)
  interpolated_exprs = parse_interpolation.(exprs)

  tidy_exprs = [i[1] for i in interpolated_exprs]

  tidy_exprs = parse_tidy.(tidy_exprs)
  num_exprs = length(exprs)
  df_expr = quote
    if $(esc(df)) isa GroupedDataFrame
      local col_names = groupcols($(esc(df)))
      @chain $(esc(df)) begin
        DataFrame # remove grouping because `dropmissing()` does not work on GroupDataFrames
        @chain _ begin
          if $num_exprs == 0
            dropmissing(_)
          else
            dropmissing(_, Cols($(tidy_exprs...)))
          end
        end
        groupby(col_names; sort = true) # regroup
      end
    else
      @chain $(esc(df)) begin
        @chain _ begin
          if $num_exprs == 0
            dropmissing(_)
          else
            dropmissing(_, Cols($(tidy_exprs...)))
          end
        end
      end
    end
  end
  if code[]
    @info MacroTools.prettify(df_expr)
  end
  return df_expr
end

"""
$docstring_glimpse
"""
macro glimpse(df, width = 80)
  df_expr = quote
    # DataFrame() needed to handle grouped data frames
    println("Rows: ", nrow(DataFrame($(esc(df)))))
    println("Columns: ", ncol(DataFrame($(esc(df)))))

    if $(esc(df)) isa GroupedDataFrame
      println("Groups: ", join(string.(groupcols($(esc(df)))), ", "), " [", length(keys($(esc(df)))), "]")
    end

    for (name, col) in pairs(eachcol(DataFrame($(esc(df)))))
      rpad("." * string(name), 15) *
      rpad(eltype(col), 15) *
      join(col, ", ") |>
      x -> first(x, $width) |> # show the first $width number of characters
      println
    end
  end 
  return df_expr
end

end