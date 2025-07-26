function [maxValue, bestStrategies] = L1bit_bound(inequalityTensor, dims, options)
%L1BIT_BOUND Maximize an inequality with one bit from Alice to Bob.
%   [MAXVALUE, BESTSTRATEGIES] = L1BIT_BOUND(I, DIMS) searches a scenario
%   whose coefficient tensor I has dimensions [oA^n, oB^n, mA^n, mB^n].
%   DIMS must contain scalar positive integers mA, mB, oA, oB, and n.
%
%   BESTSTRATEGIES contains Alice's message h (encoded as 0 or 1), Alice's
%   output f, and Bob's responses g_c0 and g_c1 for each message value.
%   L1BIT_BOUND(..., 'UseParallel', true) uses Parallel Computing Toolbox.
%   Serial execution is the default.

arguments
    inequalityTensor double
    dims (1,1) struct
    options.UseParallel (1,1) logical = false
end

requiredFields = {'mA', 'mB', 'oA', 'oB', 'n'};
assert(all(isfield(dims, requiredFields)), ...
    'QIToolbox:InvalidDimensions', 'dims must contain mA, mB, oA, oB, and n.');
for field = requiredFields
    validateattributes(dims.(field{1}), {'numeric'}, ...
        {'scalar', 'integer', 'positive', 'finite'}, mfilename, ['dims.' field{1}]);
end
validateattributes(inequalityTensor, {'double'}, {'real', 'finite'}, mfilename, 'I');

numAliceInputs = dims.mA^dims.n;
numBobInputs = dims.mB^dims.n;
numAliceOutputs = dims.oA^dims.n;
numBobOutputs = dims.oB^dims.n;
expectedSize = [numAliceOutputs, numBobOutputs, numAliceInputs, numBobInputs];
assert(ndims(inequalityTensor) <= 4 && ...
    isequal([size(inequalityTensor, 1), size(inequalityTensor, 2), ...
    size(inequalityTensor, 3), size(inequalityTensor, 4)], expectedSize), ...
    'QIToolbox:InvalidTensorSize', 'I must have size [oA^n, oB^n, mA^n, mB^n].');

numFStrategies = numAliceOutputs^numAliceInputs;
numGStrategies = numBobOutputs^numBobInputs;
numMessageStrategies = 2^(numAliceInputs - 1);
numAliceStrategies = numMessageStrategies * numFStrategies;
assertStrategyCount(numFStrategies, 'Alice output');
assertStrategyCount(numGStrategies, 'Bob');
assertStrategyCount(numAliceStrategies, 'canonical Alice');

fprintf('1-bit search: %g canonical Alice strategies, %g Bob strategies.\n', ...
    numAliceStrategies, numGStrategies);
if options.UseParallel && isempty(gcp('nocreate'))
    parpool;
end

bobValues = precomputeBobValues(inequalityTensor, numAliceInputs, ...
    numAliceOutputs, numBobInputs, numBobOutputs, numGStrategies);
values = zeros(numAliceStrategies, 1);
bestGC0 = ones(numAliceStrategies, 1);
bestGC1 = ones(numAliceStrategies, 1);
searchTimer = tic;

if options.UseParallel
    parfor canonicalIndex = 1:numAliceStrategies
        [values(canonicalIndex), bestGC0(canonicalIndex), bestGC1(canonicalIndex)] = ...
            bestResponse(canonicalIndex, numFStrategies, numAliceInputs, ...
                numAliceOutputs, numGStrategies, bobValues);
    end
else
    for canonicalIndex = 1:numAliceStrategies
        [values(canonicalIndex), bestGC0(canonicalIndex), bestGC1(canonicalIndex)] = ...
            bestResponse(canonicalIndex, numFStrategies, numAliceInputs, ...
                numAliceOutputs, numGStrategies, bobValues);
    end
end

[maxValue, bestCanonicalIndex] = max(values);
[h, f] = canonicalAliceStrategy(bestCanonicalIndex, numFStrategies, ...
    numAliceInputs, numAliceOutputs);
bestStrategies.h = h - 1;
bestStrategies.f = f;
bestStrategies.g_c0 = indexToStrategy(bestGC0(bestCanonicalIndex), ...
    numBobOutputs, numBobInputs);
bestStrategies.g_c1 = indexToStrategy(bestGC1(bestCanonicalIndex), ...
    numBobOutputs, numBobInputs);
fprintf('Maximum inequality value: %g (%.2f seconds).\n', maxValue, toc(searchTimer));
end

function bobValues = precomputeBobValues(inequalityTensor, numAliceInputs, ...
        numAliceOutputs, numBobInputs, numBobOutputs, numGStrategies)
    bobValues = zeros(numGStrategies, numAliceInputs, numAliceOutputs);
    y = (1:numBobInputs)';
    for gIndex = 1:numGStrategies
        g = indexToStrategy(gIndex, numBobOutputs, numBobInputs);
        for x = 1:numAliceInputs
            for a = 1:numAliceOutputs
                indices = sub2ind(size(inequalityTensor), ...
                    repmat(a, numBobInputs, 1), g(:), ...
                    repmat(x, numBobInputs, 1), y);
                bobValues(gIndex, x, a) = sum(inequalityTensor(indices));
            end
        end
    end
end

function [value, bestG0, bestG1] = bestResponse(canonicalIndex, ...
        numFStrategies, numAliceInputs, numAliceOutputs, numGStrategies, bobValues)
    [h, f] = canonicalAliceStrategy(canonicalIndex, numFStrategies, ...
        numAliceInputs, numAliceOutputs);
    [value0, bestG0] = bestBobResponse(find(h == 1), f, numGStrategies, bobValues);
    [value1, bestG1] = bestBobResponse(find(h == 2), f, numGStrategies, bobValues);
    value = value0 + value1;
end

function [value, bestG] = bestBobResponse(xIndices, f, numGStrategies, bobValues)
    if isempty(xIndices)
        value = 0;
        bestG = 1;
        return;
    end

    values = zeros(numGStrategies, 1);
    for g = 1:numGStrategies
        for x = xIndices(:)'
            values(g) = values(g) + bobValues(g, x, f(x));
        end
    end
    [value, bestG] = max(values);
end

function [h, f] = canonicalAliceStrategy(canonicalIndex, numFStrategies, ...
        numAliceInputs, numAliceOutputs)
    zeroBasedIndex = canonicalIndex - 1;
    fIndex = mod(zeroBasedIndex, numFStrategies) + 1;
    hIndex = floor(zeroBasedIndex / numFStrategies) + 1;
    h = [1, indexToStrategy(hIndex, 2, numAliceInputs - 1)];
    f = indexToStrategy(fIndex, numAliceOutputs, numAliceInputs);
end

function assertStrategyCount(count, label)
    assert(isfinite(count) && count <= flintmax, 'QIToolbox:StrategySpaceTooLarge', ...
        '%s strategy count is too large for reliable exhaustive indexing.', label);
end
