%% One-round Hardy local bound
[I, dims] = hardy_ineq_r1();

started = tic;
[localBound, bestStrategies] = L0bit_bound(I, dims);
elapsed = toc(started);
fprintf('Hardy r1 local bound: %g (expected 0), %.2f seconds.\n', ...
    localBound, elapsed);
disp('Best strategies:');
disp(bestStrategies);

%% Optional quantum bound with Moment v0.9.0-beta and CVX 2.2
if exist('LocalityScenario', 'class') ~= 8 || exist('cvx_begin', 'file') == 0
    warning('QIToolbox:MissingQuantumDependencies', ...
        'Skipping quantum bound: install Moment v0.9.0-beta and CVX 2.2.');
    return;
end

scenario = LocalityScenario(2);
Alice = scenario.Parties(1);
Bob = scenario.Parties(2);
Alice.AddMeasurement(2);
Alice.AddMeasurement(2);
Bob.AddMeasurement(2);
Bob.AddMeasurement(2);

matrix = scenario.MomentMatrix(2);
constraints = [scenario.getPMO([[1, 1, 1]; [2, 1, 1]]), ...
               scenario.getPMO([[1, 2, 1]; [2, 1, 2]]), ...
               scenario.getPMO([[1, 1, 2]; [2, 2, 1]])];
objective = scenario.getPMO([[1, 2, 1]; [2, 2, 1]]);

cvx_begin sdp
    scenario.cvxVars('a');
    M = matrix.Apply(a);
    a(1) == 1;
    M >= 0;
    for index = 1:numel(constraints)
        constraints(index).Apply(a) == 0;
    end
    maximize(objective.Apply(a));
cvx_end

quantumBound = cvx_optval;
fprintf('Hardy r1 local bound: %g; quantum bound: %.8g.\n', ...
    localBound, quantumBound);
