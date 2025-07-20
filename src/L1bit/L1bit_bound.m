function [maxValue, bestStrategies] = L1bit_bound(mA, mB, oA, oB, n, inequalityTensor, varargin)
%findMaxInequality_Tensor Finds the max inequality value using a coefficient tensor.
%
%   (Version 3 - Corrected Indexing Bug)
%   This is a highly optimized function that leverages pre-computation to
%   dramatically accelerate the search for the maximum value of a linear
%   inequality. It provides robust user control over parallel execution.

%% 1. Input Parsing and Configuration
p = inputParser;
addParameter(p, 'UseParallel', true, @islogical);
parse(p, varargin{:});
useParallel = p.Results.UseParallel;

fprintf('--- Highly Optimized Tensor-Based Inequality Maximization (v3) ---\n');

if useParallel
    if isempty(gcp('nocreate')) 
        parpool; 
    else 
        fprintf('Using existing parallel pool.\n'); 
    end
else
    fprintf('Parallel computation disabled. Running sequentially.\n');
end

%% 2. Initialization and Parameter Calculation
numAliceInputs  = mA^n;
numBobInputs    = mB^n;
numAliceOutputs = oA^n;
numBobOutputs   = oB^n;

num_f_strat = vpa(numAliceOutputs)^vpa(numAliceInputs);
num_g_strat = vpa(numBobOutputs)^vpa(numBobInputs);
num_h_strat_canonical = vpa(2)^(vpa(numAliceInputs) - 1);
if numAliceInputs == 0, num_h_strat_canonical = 1; end
num_alice_canonical_strat = num_h_strat_canonical * num_f_strat;

fprintf('Scenario: (%d, %d, %d, %d), n=%d\n', mA, mB, oA, oB, n);
fprintf('Total canonical Alice strategies to check: %s\n', char(num_alice_canonical_strat));

%% 3. Pre-computation of Bob's Contributions
fprintf('Pre-computing Bob''s value contributions...\n');
tic;
BobValues = zeros(double(num_g_strat), numAliceInputs, numAliceOutputs);
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
            BobValues(g_idx, x_idx, a_idx) = sum(inequalityTensor(lin_indices));
        end
    end
end
fprintf('Pre-computation finished in %.2f seconds.\n', toc);

%% 4. Main Search Loop (Controlled Parallelism)
fprintf('Starting main search...\n');
results = cell(1, double(num_alice_canonical_strat));
mainLoopTic = tic;

if useParallel
    parfor canonical_idx = 1:double(num_alice_canonical_strat)
        results{canonical_idx} = calculate_best_response(canonical_idx, num_f_strat, ...
            numAliceInputs, numAliceOutputs, num_g_strat, BobValues);
    end
else
    for canonical_idx = 1:double(num_alice_canonical_strat)
        results{canonical_idx} = calculate_best_response(canonical_idx, num_f_strat, ...
            numAliceInputs, numAliceOutputs, num_g_strat, BobValues);
    end
end

fprintf('Main search complete in %.2f seconds. Aggregating results...\n', toc(mainLoopTic));

%% 5. Aggregate Results
maxValue = -inf;
bestStrategies = struct();

for i = 1:length(results)
    if ~isempty(results{i}) && results{i}.value > maxValue
        maxValue = results{i}.value;
        bestStrategies.h = results{i}.h - 1;
        bestStrategies.f = results{i}.f;
        bestStrategies.g_c0 = indexToStrategy(results{i}.g_c0_idx, numBobOutputs, numBobInputs);
        bestStrategies.g_c1 = indexToStrategy(results{i}.g_c1_idx, numBobOutputs, numBobInputs);
    end
end

fprintf('\n--- Search Complete ---\n');
fprintf('Maximum inequality value found: %f\n', maxValue);
end

%% --- Loop Body function with CORRECTED indexing ---
function result = calculate_best_response(canonical_idx, num_f_strat, ...
            numAliceInputs, numAliceOutputs, num_g_strat, BobValues)
    
    [h_func, f_func] = indexToCanonicalAliceStrategy(canonical_idx, num_f_strat, ...
                                                    numAliceInputs, numAliceOutputs);
    
    x_indices_c0 = find(h_func == 1);
    x_indices_c1 = find(h_func == 2);
    
    % --- Find best g for c=0 ---
    if isempty(x_indices_c0)
        max_val_c0 = 0; best_g_c0_idx = 1;
    else
        value_per_g_c0 = zeros(double(num_g_strat), 1);
        for g_idx = 1:double(num_g_strat)
            current_sum = 0;
            % *** THE FIX IS HERE: Loop through the (x, a) pairs ***
            for i = 1:length(x_indices_c0)
                x_val = x_indices_c0(i);
                a_val = f_func(x_val);
                current_sum = current_sum + BobValues(g_idx, x_val, a_val);
            end
            value_per_g_c0(g_idx) = current_sum;
        end
        [max_val_c0, best_g_c0_idx] = max(value_per_g_c0);
    end

    % --- Find best g for c=1 ---
    if isempty(x_indices_c1)
        max_val_c1 = 0; best_g_c1_idx = 1;
    else
        value_per_g_c1 = zeros(double(num_g_strat), 1);
        for g_idx = 1:double(num_g_strat)
            current_sum = 0;
            % *** THE FIX IS HERE: Loop through the (x, a) pairs ***
            for i = 1:length(x_indices_c1)
                x_val = x_indices_c1(i);
                a_val = f_func(x_val);
                current_sum = current_sum + BobValues(g_idx, x_val, a_val);
            end
            value_per_g_c1(g_idx) = current_sum;
        end
        [max_val_c1, best_g_c1_idx] = max(value_per_g_c1);
    end

    result = struct('value', max_val_c0 + max_val_c1, 'h', h_func, 'f', f_func, 'g_c0_idx', best_g_c0_idx, 'g_c1_idx', best_g_c1_idx);
end

% --- Helper functions (unchanged) ---
function strategy = indexToStrategy(index, base, len)
    if len == 0, strategy = []; return; end
    strategy = ones(1, len); idx = index - 1;
    for k = 1:len, strategy(k) = mod(idx, base) + 1; idx = floor(idx / base); if idx == 0, break; end; end
end
function [h_func, f_func] = indexToCanonicalAliceStrategy(canonical_idx, num_f_strat, numAliceInputs, numAliceOutputs)
    idx_0based = canonical_idx - 1;
    f_idx = mod(idx_0based, num_f_strat) + 1;
    h_canonical_part_idx = floor(idx_0based / num_f_strat) + 1;
    h_variable_part = indexToStrategy(h_canonical_part_idx, 2, numAliceInputs - 1);
    h_func = [1, h_variable_part];
    f_func = indexToStrategy(f_idx, numAliceOutputs, numAliceInputs);
end