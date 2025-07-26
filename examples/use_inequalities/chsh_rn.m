%% One-round CHSH bound with one bit of communication
n = 1;
[I, dims] = chsh_ineq_rn(n);

started = tic;
[maxValue, bestStrategies] = L1bit_bound(I, dims);
elapsed = toc(started);

fprintf('CHSH r%d 1-bit bound: %g (expected 4), %.2f seconds.\n', ...
    n, maxValue, elapsed);
disp('Best strategies:');
disp(bestStrategies);
