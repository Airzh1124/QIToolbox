function I = setInequalityCoeff(I, value, a_vec, b_vec, x_vec, y_vec, dims)
%setInequalityCoeff (v3 - FINAL, Corrected Syntax) Sets a single 
%   coefficient in the inequality tensor using vector subscripts.
%
%   This version fixes the "chaining outputs" syntax error by using
%   intermediate variables for the cell arrays.

    n = length(x_vec);
    
    % --- Input Validation ---
    assert(all(a_vec <= dims.oA & a_vec >= 1), 'Invalid a_vec: An element exceeds output dimension oA=%d.', dims.oA);
    assert(all(b_vec <= dims.oB & b_vec >= 1), 'Invalid b_vec: An element exceeds output dimension oB=%d.', dims.oB);
    assert(all(x_vec <= dims.mA & x_vec >= 1), 'Invalid x_vec: An element exceeds input dimension mA=%d.', dims.mA);
    assert(all(y_vec <= dims.mB & y_vec >= 1), 'Invalid y_vec: An element exceeds input dimension mB=%d.', dims.mB);
    assert(length(a_vec)==n && length(b_vec)==n && length(y_vec)==n, 'All input/output vectors must have the same length n.');

    % Define dimensions of the product spaces
    dims_A = repmat(dims.oA, 1, n);
    dims_B = repmat(dims.oB, 1, n);
    dims_X = repmat(dims.mA, 1, n);
    dims_Y = repmat(dims.mB, 1, n);

    % --- Convert to linear indices (ROBUST 2-STEP METHOD) ---
    
    % For Alice's output
    a_cell = num2cell(a_vec);
    a_idx = sub2ind(dims_A, a_cell{:});

    % For Bob's output
    b_cell = num2cell(b_vec);
    b_idx = sub2ind(dims_B, b_cell{:});

    % For Alice's input
    x_cell = num2cell(x_vec);
    x_idx = sub2ind(dims_X, x_cell{:});

    % For Bob's input
    y_cell = num2cell(y_vec);
    y_idx = sub2ind(dims_Y, y_cell{:});
    
    % Set the value
    I(a_idx, b_idx, x_idx, y_idx) = value;
end