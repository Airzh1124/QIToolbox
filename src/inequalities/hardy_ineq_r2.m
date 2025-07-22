function [hardy_r2_coefficient_matrix,dims] = hardy_ineq_r2()
    dims.mA = 2; dims.mB = 2; dims.oA = 2; dims.oB = 2; dims.n=2;
    I = zeros(dims.oA^dims.n, dims.oB^dims.n, dims.mA^dims.n, dims.mB^dims.n);
    penalty_coeff = -1e10;




    %Set inequality
    for x = 1:dims.mA
        for y = 1:dims.mB
            for a = 1:dims.oA
                for b = 1:dims.oB
                    I = setInequalityCoeff(I,1,[1,a],[1,b],[2,x],[2,y],dims);
                    I = setInequalityCoeff(I,1,[a,1],[b,1],[x,2],[y,2],dims);
                end
            end
        end
    end

    %Set constraints
    for x = 1:dims.mA
        for y = 1:dims.mB
            for a = 1:dims.oA
                for b = 1:dims.oB
                    I = setInequalityCoeff(I,penalty_coeff,[1,a],[1,b],[1,x],[1,y],dims);
                    I = setInequalityCoeff(I,penalty_coeff,[a,1],[b,1],[x,1],[y,1],dims);
                    I = setInequalityCoeff(I,penalty_coeff,[1,a],[2,b],[2,x],[1,y],dims);
                    I = setInequalityCoeff(I,penalty_coeff,[a,1],[b,2],[x,2],[y,1],dims);
                    I = setInequalityCoeff(I,penalty_coeff,[2,a],[1,b],[1,x],[2,y],dims);
                    I = setInequalityCoeff(I,penalty_coeff,[a,2],[b,1],[x,1],[y,2],dims);
                end
            end
        end
    end

    
    hardy_r2_coefficient_matrix  = I;
end