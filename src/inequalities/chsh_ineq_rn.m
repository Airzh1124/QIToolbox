function [chsh_rn_coefficient_matrix,dims] = chsh_ineq_rn(n)
%CHSH_INEQ_RN Generates the coefficient matrix for an n-round CHSH-type inequality.
%
%   chsh_rn_coefficient_matrix = chsh_ineq_rn(n)
%
%   This function generalizes the construction of the CHSH game coefficient
%   matrix for 'n' sequential rounds. In each round, the winning condition
%   for Alice's output 'a' is determined by the inputs 'x' and 'y', and
%   Bob's output 'b', according to the rule a = (x*y + b) mod 2.
%
%   This version does NOT require the Communications Toolbox.
%
%   Input:
%       n : The number of rounds (a positive integer).
%
%   Output:
%       chsh_rn_coefficient_matrix : A 4-dimensional tensor (matrix) of size
%       (2^n, 2^n, 2^n, 2^n) representing the coefficients of the inequality.
%       The dimensions correspond to (Alice's outputs, Bob's outputs,
%       Alice's inputs, Bob's inputs).

    % --- 1. Initialization ---
    % Standard CHSH dimensions: 2 inputs (m) and 2 outputs (o) for Alice (A) and Bob (B).
    dims.mA = 2; dims.mB = 2; dims.oA = 2; dims.oB = 2;

    % The total number of possible sequences of inputs/outputs.
    num_seq_X = dims.mA^n;
    num_seq_Y = dims.mB^n;
    num_seq_B = dims.oB^n;

    % Initialize the coefficient matrix I with zeros.
    % The dimensions are (oA^n, oB^n, mA^n, mB^n).
    I = zeros(dims.oA^n, dims.oB^n, dims.mA^n, dims.mB^n);

    % Define the actual values for inputs/outputs (0 and 1).
    X_vals = 0:dims.mA-1;
    Y_vals = 0:dims.mB-1;
    B_vals = 0:dims.oB-1;

    % --- 2. Iterate through all possible sequences of inputs and Bob's outputs ---
    % Instead of nested for-loops, we iterate from 0 to M^n-1 and use
    % base conversion to get all possible sequences.

    % Iterate through all sequences of Alice's inputs (x_1, ..., x_n)
    for iX = 0:(num_seq_X - 1)
        % Get the 0-based sequence of inputs for Alice using our custom function.
        x_seq_0based = my_de2base(iX, n, dims.mA);

        % Iterate through all sequences of Bob's inputs (y_1, ..., y_n)
        for iY = 0:(num_seq_Y - 1)
            y_seq_0based = my_de2base(iY, n, dims.mB);

            % Iterate through all sequences of Bob's outputs (b_1, ..., b_n)
            for iB = 0:(num_seq_B - 1)
                b_seq_0based = my_de2base(iB, n, dims.oB);

                % --- 3. Calculate Alice's winning output sequence ---
                % Get the actual values (0 or 1) from the 0-based indices
                x_vec = X_vals(x_seq_0based + 1);
                y_vec = Y_vals(y_seq_0based + 1);
                b_vec = B_vals(b_seq_0based + 1);

                % The core CHSH logic, applied element-wise for each round
                % a_k = (x_k * y_k + b_k) mod 2
                a_seq_0based = mod(x_vec .* y_vec + b_vec, 2);

                % --- 4. Set the coefficient in the matrix ---
                % Convert all 0-based sequences to 1-based index vectors for MATLAB
                idx_A_vec = a_seq_0based + 1;
                idx_B_vec = b_seq_0based + 1;
                idx_X_vec = x_seq_0based + 1;
                idx_Y_vec = y_seq_0based + 1;

                % Use the helper function to place the coefficient (which is 1)
                % at the correct position in the 4D matrix I.
                I = setInequalityCoeff(I, 1, idx_A_vec, idx_B_vec, idx_X_vec, idx_Y_vec, dims);
            end
        end
    end

    chsh_rn_coefficient_matrix = I;
end


function base_vec = my_de2base(dec_num, len, base)
%MY_DE2BASE Custom implementation to convert a decimal number to a vector
%   of its digits in a specified base. Replaces the functionality of de2bi
%   from the Communications Toolbox.
%
%   Example: my_de2base(5, 4, 2) -> [0 1 0 1]

    base_vec = zeros(1, len);
    temp_dec = dec_num;
    for i = len:-1:1
        base_vec(i) = mod(temp_dec, base);
        temp_dec = floor(temp_dec / base);
    end
end