% Script to run the tensor-based search

% --- Define Scenario ---
mA = 3; mB = 3; oA = 4; oB = 4; n = 1;

% --- 1. Create the Inequality Tensor 'I' ---
fprintf('Creating magic inequality tensor...\n');

%chsh_ineq_2
I = magic_ineq_r1();

% --- 2. Run the search ---
tic;
% Run sequentially for this small problem
[maxVal, best] = L0bit_bound(mA, mB, oA, oB, n, I, 'UseParallel', false);
toc;

% Display results
disp('Best strategies found:');
disp(best);