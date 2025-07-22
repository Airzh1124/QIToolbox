
% Local Scenario

% --- Define Scenario ---

% --- 1. Create the Inequality Tensor 'I' ---
fprintf('Creating Hardy inequality tensor...\n');

%chsh_ineq_2
[I,dims] = hardy_ineq_r2_reformulation();


% --- 2. Run the search ---
tic;
% Run sequentially for this small problem
[local_bound, best] = L1bit_bound(dims.mA, dims.mB, dims.oA, dims.oB, dims.n, I, 'UseParallel', false);
toc;

% Display results
disp('Best strategies found:');
disp(best);

%%

% Quantum Scenario

scenario = LocalityScenario(2);
Alice = scenario.Parties(1);
Bob = scenario.Parties(2);

% Each party with two measurements, 4 inputs, 4 outputs
A0 = Alice.AddMeasurement(4);
A1 = Alice.AddMeasurement(4);
A2 = Alice.AddMeasurement(4);
A3 = Alice.AddMeasurement(4);
B0 = Bob.AddMeasurement(4);
B1 = Bob.AddMeasurement(4);
B2 = Bob.AddMeasurement(4);
B3 = Bob.AddMeasurement(4);

% Make moment matrix
matrix = scenario.MomentMatrix(1);

constraints = cell(1,16*6); %6 constraints, each constraints contain 16 terms

count = 1;

%1
for a = 1:2
    for b = 1:2
        for x = 1:2
            for y = 1:2
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%2
for a = 1:2
    for b = 3:4
        for x = 3:4
            for y = 1:2
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%3
for a = 3:4
    for b = 1:2
        for x = 1:2
            for y = 3:4
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%4
for a = 1:2:3
    for b = 1:2:3
        for x = 1:2:3
            for y = 1:2:3
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%5
for a = 1:2:3
    for b = 2:2:4
        for x = 2:2:4
            for y = 1:2:3
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%6
for a = 2:2:4
    for b = 1:2:3
        for x = 1:2:3
            for y = 2:2:4
                constraints{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end


%set objective
count = 1;
objectives = cell(1,16*2+1);
%1
for a = 1:2
    for b = 1:2
        for x = 3:4
            for y = 3:4
                objectives{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%2
for a = 1:2:3
    for b = 1:2:3
        for x = 2:2:4
            for y = 2:2:4
                objectives{count} = scenario.getPMO([[1,x,a];[2,y,b]]);
                count = count+1;
            end
        end
    end
end
%3
objectives{count} = scenario.getPMO([[1,4,1];[2,4,1]]);


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
    
    for i=1:size(constraints,2)
        constraints{i}.Apply(a) == 0;
    end
    

    obj = 0;
    for i=1:size(objectives,2)
        if i == 33 
            obj = obj - objectives{i}.Apply(a);
        else
            obj = obj + objectives{i}.Apply(a);
        end
    end

    maximize(obj);
cvx_end;


quantum_bound = cvx_optval;

fprintf("local bound = %d, quantum bound = %d \n",local_bound,quantum_bound);