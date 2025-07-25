function [inequalityTensor, dims] = chsh_ineq_rn(n)
%CHSH_INEQ_RN Construct the n-round parallel CHSH winning tensor.
%   [I, DIMS] = CHSH_INEQ_RN(N) returns a tensor with dimensions
%   [2^N, 2^N, 2^N, 2^N]. A coefficient is one exactly when every round
%   satisfies a = x*y + b (mod 2), and zero otherwise.

arguments
    n (1,1) double {mustBeInteger, mustBePositive}
end

dims = struct('mA', 2, 'mB', 2, 'oA', 2, 'oB', 2, 'n', n);
inequalityTensor = zeros(dims.oA^n, dims.oB^n, dims.mA^n, dims.mB^n);

for xIndex = 0:(dims.mA^n - 1)
    x = decimalToSequence(xIndex, n, dims.mA);
    for yIndex = 0:(dims.mB^n - 1)
        y = decimalToSequence(yIndex, n, dims.mB);
        for bIndex = 0:(dims.oB^n - 1)
            b = decimalToSequence(bIndex, n, dims.oB);
            a = mod(x .* y + b, 2);
            inequalityTensor = setInequalityCoeff(inequalityTensor, 1, ...
                a + 1, b + 1, x + 1, y + 1, dims);
        end
    end
end
end

function sequence = decimalToSequence(number, length, base)
% Return a fixed-width, most-significant-position-first digit sequence.
sequence = zeros(1, length);
for position = length:-1:1
    sequence(position) = mod(number, base);
    number = floor(number / base);
end
end
