% Script to run the tensor-based search


% --- 1. Create the Inequality Tensor 'I' ---
fprintf('Creating CHSH inequality tensor...\n');

%chsh_ineq_2
[I,dims] = chsh_ineq_rn(n);

% --- 2. Run the search ---
tic;
% Run sequentially for this small problem
[maxVal, best] = L1bit_bound(dims.mA, dims.mB, dims.oA, dims.oB, n, I, 'UseParallel', false);
toc;

% Display results
disp('Best strategies found:');
disp(best);