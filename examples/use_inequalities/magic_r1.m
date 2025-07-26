%% One-round Magic Square local bound
[I, dims] = magic_ineq_r1();

started = tic;
[maxValue, bestStrategies] = L0bit_bound(I, dims);
elapsed = toc(started);

fprintf('Magic Square r1 local bound: %g (expected 8), %.2f seconds.\n', ...
    maxValue, elapsed);
disp('Best strategies:');
disp(bestStrategies);
