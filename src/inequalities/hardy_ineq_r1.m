function [inequalityTensor, dims] = hardy_ineq_r1()
%HARDY_INEQ_R1 Construct the one-round Hardy inequality tensor.
%   Forbidden events receive a large negative penalty and the Hardy event
%   receives coefficient one.

dims = struct('mA', 2, 'mB', 2, 'oA', 2, 'oB', 2, 'n', 1);
inequalityTensor = zeros(dims.oA, dims.oB, dims.mA, dims.mB);
penalty = -1e10;

inequalityTensor(1, 1, 1, 1) = penalty;
inequalityTensor(1, 2, 2, 1) = penalty;
inequalityTensor(2, 1, 1, 2) = penalty;
inequalityTensor(1, 1, 2, 2) = 1;
end
