function magic_r1_coefficient_matrix = magic_ineq_r1()
    dims.mA = 3; dims.mB = 3; dims.oA = 4; dims.oB = 4; n=1;
    I = zeros(dims.oA^n, dims.oB^n, dims.mA^n, dims.mB^n);
    
    
    X = [0, 1, 2];

    Y = [0, 1, 2];

    A = [0, 0, 0;
         0, 1, 1;
         1, 0, 1;
         1, 1, 0;];

    B = [0, 0, 1;
         0, 1, 0;
         1, 0, 0;
         1, 1, 1;];

    for x_idx=1:dims.mA
        for y_idx = 1:dims.mB
            for a_idx = 1:dims.oA
                for b_idx = 1:dims.oB
                    if A(a_idx,y_idx) == B(b_idx,x_idx)
                       I(a_idx,b_idx,x_idx,y_idx) = 1;
                    end
                end
            end
        end
    end

    magic_r1_coefficient_matrix = I;

end