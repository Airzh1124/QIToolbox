function [inequalityTensor, dims] = magic_ineq_r1()
%MAGIC_INEQ_R1 Construct the one-round Magic Square winning tensor.

dims = struct('mA', 3, 'mB', 3, 'oA', 4, 'oB', 4, 'n', 1);
inequalityTensor = zeros(dims.oA, dims.oB, dims.mA, dims.mB);

aliceOutputs = [0, 0, 0;
                0, 1, 1;
                1, 0, 1;
                1, 1, 0];
bobOutputs = [0, 0, 1;
              0, 1, 0;
              1, 0, 0;
              1, 1, 1];

for x = 1:dims.mA
    for y = 1:dims.mB
        for a = 1:dims.oA
            for b = 1:dims.oB
                if aliceOutputs(a, y) == bobOutputs(b, x)
                    inequalityTensor(a, b, x, y) = 1;
                end
            end
        end
    end
end
end
