function quantumBound = hardy_r2_quantum_bound()
%HARDY_R2_QUANTUM_BOUND Compute the Hardy r2 NPA bound with Moment and CVX.

assert(exist('LocalityScenario', 'class') == 8 && exist('cvx_begin', 'file') ~= 0, ...
    'QIToolbox:MissingQuantumDependencies', ...
    'Install Moment v0.9.0-beta and CVX 2.2 before computing the quantum bound.');

scenario = LocalityScenario(2);
alice = scenario.Parties(1);
bob = scenario.Parties(2);
for measurement = 1:4
    alice.AddMeasurement(4);
    bob.AddMeasurement(4);
end
matrix = scenario.MomentMatrix(1);

constraints = cell(1, 96);
count = 1;
blocks = {
    1:2,   1:2,   1:2,   1:2;
    1:2,   3:4,   3:4,   1:2;
    3:4,   1:2,   1:2,   3:4;
    1:2:3, 1:2:3, 1:2:3, 1:2:3;
    1:2:3, 2:2:4, 2:2:4, 1:2:3;
    2:2:4, 1:2:3, 1:2:3, 2:2:4
};
for block = 1:size(blocks, 1)
    for a = blocks{block, 1}
        for b = blocks{block, 2}
            for x = blocks{block, 3}
                for y = blocks{block, 4}
                    constraints{count} = scenario.getPMO([[1, x, a]; [2, y, b]]);
                    count = count + 1;
                end
            end
        end
    end
end

objectives = cell(1, 33);
count = 1;
for a = 1:2
    for b = 1:2
        for x = 3:4
            for y = 3:4
                objectives{count} = scenario.getPMO([[1, x, a]; [2, y, b]]);
                count = count + 1;
            end
        end
    end
end
for a = 1:2:3
    for b = 1:2:3
        for x = 2:2:4
            for y = 2:2:4
                objectives{count} = scenario.getPMO([[1, x, a]; [2, y, b]]);
                count = count + 1;
            end
        end
    end
end
objectives{count} = scenario.getPMO([[1, 4, 1]; [2, 4, 1]]);

cvx_begin sdp
    scenario.cvxVars('a');
    M = matrix.Apply(a);
    a(1) == 1;
    M >= 0;
    for index = 1:numel(constraints)
        constraints{index}.Apply(a) == 0;
    end
    objective = 0;
    for index = 1:numel(objectives) - 1
        objective = objective + objectives{index}.Apply(a);
    end
    objective = objective - objectives{end}.Apply(a);
    maximize(objective);
cvx_end

quantumBound = cvx_optval;
end
