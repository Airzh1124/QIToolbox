%% One-round reformulation of the two-round Hardy 1-bit bound
[I, dims] = hardy_ineq_r2_reformulation();

started = tic;
[localBound, bestStrategies] = L1bit_bound(I, dims);
elapsed = toc(started);
fprintf('Reformulated Hardy r2 1-bit bound: %g (expected 4), %.2f seconds.\n', ...
    localBound, elapsed);
disp('Best strategies:');
disp(bestStrategies);

%% Optional quantum bound with Moment v0.9.0-beta and CVX 2.2
if exist('LocalityScenario', 'class') ~= 8 || exist('cvx_begin', 'file') == 0
    warning('QIToolbox:MissingQuantumDependencies', ...
        'Skipping quantum bound: install Moment v0.9.0-beta and CVX 2.2.');
else
    quantumBound = hardy_r2_quantum_bound();
    fprintf('Reformulated Hardy r2 1-bit bound: %g; quantum bound: %.8g.\n', ...
        localBound, quantumBound);
end
