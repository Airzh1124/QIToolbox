% Local scenario

% --- Define Scenario ---

% --- 1. Create the Inequality Tensor 'I' ---
fprintf('Creating CHSH inequality tensor...\n');

%hardy inequality with parallel repetition = 2
[I,dims] = hardy_ineq_r1();

% --- 2. Run the search ---
tic;
[local_bound, best] = L0bit_bound(dims.mA, dims.mB, dims.oA, dims.oB, dims.n, I, 'UseParallel', false);
toc;

% Display results
disp('Best strategies found:');
disp(best);


%%

%Quantum Scenario

scenario = LocalityScenario(2);
Alice = scenario.Parties(1);
Bob = scenario.Parties(2);

% Each party with two measurements, 4 inputs, 4 outputs
A0 = Alice.AddMeasurement(2);
A1 = Alice.AddMeasurement(2);

B0 = Bob.AddMeasurement(2);
B1 = Bob.AddMeasurement(2);


% Make moment matrix
matrix = scenario.MomentMatrix(2);

constraints = [scenario.getPMO([[1,1,1];[2,1,1]]),...
               scenario.getPMO([[1,2,1];[2,1,2]]),...
               scenario.getPMO([[1,1,2];[2,2,1]]),...
              ];
               
objectives = scenario.getPMO([[1,2,1];[2,2,1]]);

% Define and solve SDP
cvx_begin sdp

    % Declare basis variables a (real) and b (imaginary)
    scenario.cvxVars('a');
    
    % Compose moment matrix from these basis variables
    M = matrix.Apply(a);

    % Normalization
    a(1) == 1;

    % Positivity
    M >= 0;
    
    for i=1:3
        constraints(i).Apply(a) == 0;
    end
    

    obj = objectives.Apply(a);
    

    maximize(obj);
cvx_end;


quantum_bound = cvx_optval;
