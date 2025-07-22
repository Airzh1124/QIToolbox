function [hardy_r1_coefficient_matrix,dims] = hardy_ineq_r1()
    dims.mA = 2; dims.mB = 2; dims.oA = 2; dims.oB = 2; dims.n=1;
    I = zeros(dims.oA^dims.n, dims.oB^dims.n, dims.mA^dims.n, dims.mB^dims.n);
    penalty_coeff = -1e10;


    %Set constraints
    I(1,1,1,1) = penalty_coeff;
    I(1,2,2,1) = penalty_coeff;
    I(2,1,1,2) = penalty_coeff;

    %Set the inequality
    I(1,1,2,2) = 1;


    hardy_r1_coefficient_matrix = I;

end