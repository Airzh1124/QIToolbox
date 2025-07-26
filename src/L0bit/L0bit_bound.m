function [maxValue, bestStrategies] = L0bit_bound(inequalityTensor, dims, options)
%L0BIT_BOUND Maximize an inequality over deterministic local strategies.
%   [MAXVALUE, BESTSTRATEGIES] = L0BIT_BOUND(I, DIMS) searches a scenario
%   whose coefficient tensor I has dimensions [oA^n, oB^n, mA^n, mB^n].
%   DIMS must contain scalar positive integers mA, mB, oA, oB, and n.
%
%   L0BIT_BOUND(..., 'UseParallel', true) uses Parallel Computing Toolbox.
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

numAliceStrategies = numAliceOutputs^numAliceInputs;
numBobStrategies = numBobOutputs^numBobInputs;
assertStrategyCount(numAliceStrategies, 'Alice');
assertStrategyCount(numBobStrategies, 'Bob');

fprintf('0-bit search: %g Alice strategies, %g Bob strategies.\n', ...
    numAliceStrategies, numBobStrategies);
if options.UseParallel && isempty(gcp('nocreate'))
    parpool;
end

valuesPerG = zeros(numBobStrategies, 1);
searchTimer = tic;
if options.UseParallel
    parfor gIndex = 1:numBobStrategies
        response = aliceResponse(gIndex, inequalityTensor, numAliceOutputs, ...
            numBobOutputs, numAliceInputs, numBobInputs);
        valuesPerG(gIndex) = sum(max(response, [], 1));
    end
else
    for gIndex = 1:numBobStrategies
        response = aliceResponse(gIndex, inequalityTensor, numAliceOutputs, ...
            numBobOutputs, numAliceInputs, numBobInputs);
        valuesPerG(gIndex) = sum(max(response, [], 1));
    end
end

[maxValue, bestGIndex] = max(valuesPerG);
bestResponse = aliceResponse(bestGIndex, inequalityTensor, numAliceOutputs, ...
    numBobOutputs, numAliceInputs, numBobInputs);
[~, bestF] = max(bestResponse, [], 1);

bestStrategies.f = bestF;
bestStrategies.g = indexToStrategy(bestGIndex, numBobOutputs, numBobInputs);
fprintf('Maximum inequality value: %g (%.2f seconds).\n', maxValue, toc(searchTimer));
end

function response = aliceResponse(gIndex, inequalityTensor, numAliceOutputs, ...
        numBobOutputs, numAliceInputs, numBobInputs)
    g = indexToStrategy(gIndex, numBobOutputs, numBobInputs);
    y = (1:numBobInputs)';
    response = zeros(numAliceOutputs, numAliceInputs);
    for x = 1:numAliceInputs
        for a = 1:numAliceOutputs
            indices = sub2ind(size(inequalityTensor), ...
                repmat(a, numBobInputs, 1), g(:), ...
                repmat(x, numBobInputs, 1), y);
            response(a, x) = sum(inequalityTensor(indices));
        end
    end
end

function assertStrategyCount(count, party)
    assert(isfinite(count) && count <= flintmax, 'QIToolbox:StrategySpaceTooLarge', ...
        '%s strategy count is too large for reliable exhaustive indexing.', party);
end
