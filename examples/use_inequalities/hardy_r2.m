% Script to run the tensor-based search

% --- Define Scenario ---
% Set number of parallel reptition 
n = 2;

% --- 1. Create the Inequality Tensor 'I' ---
fprintf('Creating CHSH inequality tensor...\n');

%chsh_ineq_2
[I,dims] = hardy_ineq_r2();


% --- 2. Run the search ---
tic;
% Run sequentially for this small problem
[maxVal, best] = L1bit_bound(dims.mA, dims.mB, dims.oA, dims.oB, n, I, 'UseParallel', false);
toc;

% Display results
disp('Best strategies found:');
disp(best);