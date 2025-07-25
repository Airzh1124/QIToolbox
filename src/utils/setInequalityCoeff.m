function I = setInequalityCoeff(I, value, a, b, x, y, dims)
%SETINEQUALITYCOEFF Set one coefficient using per-round one-based indices.
%   I = SETINEQUALITYCOEFF(I, VALUE, A, B, X, Y, DIMS) maps each index
%   vector to MATLAB's column-major product-space order and assigns VALUE.

requiredFields = {'mA', 'mB', 'oA', 'oB', 'n'};
assert(isstruct(dims) && isscalar(dims) && all(isfield(dims, requiredFields)), ...
    'QIToolbox:InvalidDimensions', 'dims must contain mA, mB, oA, oB, and n.');
validateattributes(value, {'numeric'}, {'scalar', 'real', 'finite'}, mfilename, 'value');
assert(all([numel(a), numel(b), numel(x), numel(y)] == dims.n), ...
    'QIToolbox:InvalidIndexLength', 'A, B, X, and Y must each contain dims.n values.');
validateIndex(a, dims.oA, 'a');
validateIndex(b, dims.oB, 'b');
validateIndex(x, dims.mA, 'x');
validateIndex(y, dims.mB, 'y');

I(sequenceIndex(a, dims.oA), sequenceIndex(b, dims.oB), ...
    sequenceIndex(x, dims.mA), sequenceIndex(y, dims.mB)) = value;
end

function validateIndex(values, upperBound, name)
    assert(isnumeric(values) && isreal(values) && all(isfinite(values)) && ...
        all(values == fix(values)) && all(values >= 1 & values <= upperBound), ...
        'QIToolbox:InvalidIndex', '%s values must be integers between 1 and the corresponding dimension.', name);
end

function index = sequenceIndex(values, base)
    index = 1 + sum((values(:)' - 1) .* base.^(0:numel(values) - 1));
end
