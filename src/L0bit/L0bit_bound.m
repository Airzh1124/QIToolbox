function [maxValue, bestStrategies] = L0bit_bound(mA, mB, oA, oB, n, inequalityTensor, varargin)
%findMaxInequality_NoComm_Tensor Finds the max inequality value for a scenario
%   with NO communication, using a highly optimized tensor-based method.
%
%   [maxValue, bestStrategies] = findMaxInequality_NoComm_Tensor(mA, mB, oA, oB, n, inequalityTensor, Name, Value)
%
%   INPUTS:
%   mA, mB, oA, oB, n: Scenario parameters.
%   inequalityTensor: A tensor 'I' of size (oA^n, oB^n, mA^n, mB^n).
%
%   OPTIONAL NAME-VALUE PAIRS:
%   'UseParallel': A logical true/false to enable/disable parallel computation.
%                  Default is true.

%% 1. Input Parsing and Configuration
p = inputParser;
addParameter(p, 'UseParallel', true, @islogical);
parse(p, varargin{:});
useParallel = p.Results.UseParallel;

fprintf('--- Optimized Tensor-Based Maximization (No Communication) ---\n');
if useParallel && isempty(gcp('nocreate')), parpool; end

%% 2. Initialization
numAliceInputs  = mA^n;
numBobInputs    = mB^n;
numAliceOutputs = oA^n;
numBobOutputs   = oB^n;

num_f_strat = vpa(numAliceOutputs)^vpa(numAliceInputs);
num_g_strat = vpa(numBobOutputs)^vpa(numBobInputs);

fprintf('Scenario: (%d, %d, %d, %d), n=%d\n', mA, mB, oA, oB, n);
fprintf('Total Alice strategies (f): %s\n', char(num_f_strat));
fprintf('Total Bob strategies   (g): %s\n', char(num_g_strat));
fprintf('We will loop over g and find the best f for each.\n');

%% 3. Pre-computation of Alice's Response Values
fprintf('Pre-computing Alice''s response values for each of Bob''s strategies...\n');
tic;
% AliceResponseValue(a_idx, g_idx, x_idx) = sum over y of I(a_idx, g_func(y), x_idx, y)
AliceResponseValue = zeros(numAliceOutputs, double(num_g_strat), numAliceInputs);
y_indices = (1:numBobInputs)';

for g_idx = 1:double(num_g_strat)
    g_func = indexToStrategy(g_idx, numBobOutputs, numBobInputs);
    for x_idx = 1:numAliceInputs
        for a_idx = 1:numAliceOutputs
            lin_indices = sub2ind(size(inequalityTensor), ...
                                  repmat(a_idx, numBobInputs, 1), ...
                                  g_func(y_indices)', ...
                                  repmat(x_idx, numBobInputs, 1), ...
                                  y_indices);
            AliceResponseValue(a_idx, g_idx, x_idx) = sum(inequalityTensor(lin_indices));
        end
    end
end
fprintf('Pre-computation finished in %.2f seconds.\n', toc);

%% 4. Main Search Loop (Iterating over Bob's strategies)
fprintf('Starting main search...\n');
% valuesPerG will store the max value achievable for each of Bob's strategies
valuesPerG = zeros(double(num_g_strat), 1);
mainLoopTic = tic;

if useParallel
    parfor g_idx = 1:double(num_g_strat)
        % For this fixed g, find the total value of Alice's best response.
        % Alice's best response is to choose, for each x, the 'a' that
        % maximizes her value from the pre-computed table.
        best_vals_for_each_x = max(AliceResponseValue(:, g_idx, :), [], 1);
        valuesPerG(g_idx) = sum(best_vals_for_each_x);
    end
else
    for g_idx = 1:double(num_g_strat)
        best_vals_for_each_x = max(AliceResponseValue(:, g_idx, :), [], 1);
        valuesPerG(g_idx) = sum(best_vals_for_each_x);
    end
end

fprintf('Main search complete in %.2f seconds. Aggregating results...\n', toc(mainLoopTic));

%% 5. Find Maximum Value and Optimal Strategies
[maxValue, best_g_idx] = max(valuesPerG);

% Now that we have the best g, we need to reconstruct the best f that goes with it.
best_f_func = zeros(1, numAliceInputs);
for x_idx = 1:numAliceInputs
    % Find the index 'a' that gives the max value for this x and best g.
    [~, best_a_idx] = max(AliceResponseValue(:, best_g_idx, x_idx));
    best_f_func(x_idx) = best_a_idx;
end

best_g_func = indexToStrategy(best_g_idx, numBobOutputs, numBobInputs);

bestStrategies.f = best_f_func;
bestStrategies.g = best_g_func;

fprintf('\n--- Search Complete ---\n');
fprintf('Maximum inequality value found: %f\n', maxValue);
end

% --- Helper function (unchanged) ---
function strategy = indexToStrategy(index, base, len)
    if len == 0, strategy = []; return; end
    strategy = ones(1, len); idx = index - 1;
    for k = 1:len, strategy(k) = mod(idx, base) + 1; idx = floor(idx / base); if idx == 0, break; end; end
end