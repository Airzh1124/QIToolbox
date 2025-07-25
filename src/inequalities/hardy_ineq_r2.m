function [inequalityTensor, dims] = hardy_ineq_r2()
%HARDY_INEQ_R2 Construct the two-round Hardy inequality tensor.
%   Objective events receive coefficient one and forbidden events receive a
%   large negative penalty.

dims = struct('mA', 2, 'mB', 2, 'oA', 2, 'oB', 2, 'n', 2);
inequalityTensor = zeros(dims.oA^dims.n, dims.oB^dims.n, ...
    dims.mA^dims.n, dims.mB^dims.n);
penalty = -1e10;

for x = 1:dims.mA
    for y = 1:dims.mB
        for a = 1:dims.oA
            for b = 1:dims.oB
                inequalityTensor = setInequalityCoeff(inequalityTensor, 1, ...
                    [1, a], [1, b], [2, x], [2, y], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, 1, ...
                    [a, 1], [b, 1], [x, 2], [y, 2], dims);
            end
        end
    end
end

for x = 1:dims.mA
    for y = 1:dims.mB
        for a = 1:dims.oA
            for b = 1:dims.oB
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [1, a], [1, b], [1, x], [1, y], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [a, 1], [b, 1], [x, 1], [y, 1], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [1, a], [2, b], [2, x], [1, y], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [a, 1], [b, 2], [x, 2], [y, 1], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [2, a], [1, b], [1, x], [2, y], dims);
                inequalityTensor = setInequalityCoeff(inequalityTensor, penalty, ...
                    [a, 2], [b, 1], [x, 1], [y, 2], dims);
            end
        end
    end
end
end
