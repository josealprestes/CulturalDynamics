using .CoreTypes

"""
    compliance_to_color(level::Int, Q::Int)

Map a compliance level to a color.

# Arguments
- `level`: Compliance level (1 to Q)
- `Q`: Maximum adherence level

# Returns
- RGB color: red (non-compliant) to green (compliant)
"""
function compliance_to_color(level::Int, Q::Int)
    # Normalize to [0, 1]
    t = (level - 1) / max(Q - 1, 1)
    
    # Red (non-compliant) to Green (compliant)
    r = 1.0 - t
    g = t
    b = 0.2
    
    return (r, g, b)
end

"""
    features_to_color(features::Vector{Int}, Q::Int)

Map a feature vector to a color using the first 3 features as RGB channels.
"""
function features_to_color(features::Vector{Int}, Q::Int)
    n = length(features)
    
    if n >= 3
        r = (features[1] - 1) / max(Q - 1, 1)
        g = (features[2] - 1) / max(Q - 1, 1)
        b = (features[3] - 1) / max(Q - 1, 1)
        return (r, g, b)
    elseif n == 2
        r = (features[1] - 1) / max(Q - 1, 1)
        g = (features[2] - 1) / max(Q - 1, 1)
        b = 0.5
        return (r, g, b)
    else
        t = (features[1] - 1) / max(Q - 1, 1)
        return (t, t, t)
    end
end
