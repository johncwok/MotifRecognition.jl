using Combinatorics
using Distributions
using DataStructures
using Random

"""
    S_matrix(ts, window)

Returns S matrix containing all segments of length 'window' in 'ts'.
Done with a sliding window.
"""
function S_matrix(ts, window)
    S = Array{typeof(ts[1]),2}(undef, length(ts) - window, window)
    for index in 1:length(ts) - window
        S[index,:] = ts[index:index+window-1]
    end
    return S
end

"""
Returns all possible masks of length d among the possible w positions.
positive masks: the indexes represent the columns that are KEPT.
"""
function get_masks(w, d)
    if d >= w
        error("d must be smaller than w")
    end
    return collect(combinations(collect(1:w), w - d))
end

"""
Returns a masked version of the S matrix.
"""
function apply_mask(mask, S)
    masked_S = Array{typeof(S[1, 1]),2}(undef, size(S)[1], length(mask))
    for (index, value) in enumerate(mask)
        masked_S[:, index] = S[:, value]
    end
    return masked_S
end

"""
    update_c_matrix!(collision_matrix, masked_S)

Updates the collision matrix by adding 1 in the row where repetitions of a motif are found.
The row are the index of the repetitions, the column represent the first found motif of this type.
"""
function update_c_matrix!(collision_matrix, masked_S)
    masked_S_list = [masked_S[index,:] for index in 1:size(masked_S)[1]]
    count = counter(masked_S_list)
    for motif in keys(count)
        if count[motif] > 1
            positions = findall(x -> x == motif, masked_S_list)
            for p in positions
                collision_matrix[p, positions[1]] += 1
            end
        end
    end
end

"""
Returns dictionnary containing the probability of each symbol found in ts.
"""
function symbol_probabilities(ts)
    proba = values(counter(ts))
    proba = proba./sum(proba)
end

"""
    match_pobability(l, d, p, iter)

Returns the probability of two random generated words of length 'w' from alphabet having probabilities 'p'
to match up to 'd' error. 't' is the size of the masked words.
Example:
Alphabet = {a,b,c} with probabilities [0.25, 0.25. 0.5], l = 8 and d = 3.
We sample from this distribution 'iter' words of length l = 8 and look how many of them match up to d = 3 errors.
"""
function match_pobability(w, d, p, t)
    p_symbol_match = sum(p.*p)
    p_symbol_mismatch = 1 - p_symbol_match
    match_proba = 0
    for i in 1:d
        match_proba += binomial(w, i)*p_symol_match^(w-i)*p_symbol_mismatch^i*(1-i/w)^t
    end
end


"""
    significance_threshold(l, p, w, d, t)

Computes the expectation value of collision matrix entries for random words.
This is a conservative estimate that assumes all symbols are equiprobable
inputs (Int):
l : total length (size(S)[1])
p : probabilities of different symbols in alphabet.
w : motif size (window size)
d : # of allowed errors between motifs
t : length of projections (after applying mask.)
returns (Int):
E : expecation value of collision entires.
"""
function significance_threshold(l, p, w, d, t)
    k = binomial(l, 2)
    average_match = k*match_probability(w, d, p, t)
    return floor(average_match)
end



"""
    collision_matrix(ts, w, d)

Constructs and returns the collision matrix of time-series 'ts'.
inputs (Int):
ts : input time-series
w : motif size (window size)
d : # of allowed errors between motifs
t : length of projections after applying mask. default to w - d.
returns (Int):
C : collision matrix
"""
function collision_matrix(ts, w, d, t = w - d)
    C = zeros(size(ts)[1] - w, size(ts)[1] - w)

    return C
end

test = ["a","b","c","d","a","b","c","a","b","c","a","b","c","a","b","c"]
s = S_matrix(test, 4)
