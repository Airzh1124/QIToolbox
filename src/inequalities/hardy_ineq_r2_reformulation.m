function [inequalityTensor, dims] = hardy_ineq_r2_reformulation()
%HARDY_INEQ_R2_REFORMULATION Construct the one-round reformulation of
%the two-round Hardy inequality.

dims = struct('mA', 4, 'mB', 4, 'oA', 4, 'oB', 4, 'n', 1);
    I = zeros(dims.oA^dims.n, dims.oB^dims.n, dims.mA^dims.n, dims.mB^dims.n);
    penalty_coeff = -1e10;

    %1
    for a = 1:2
        for b = 1:2
            for x = 1:2
                for y = 1:2
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    %2
    for a = 1:2
        for b = 3:4
            for x = 3:4
                for y = 1:2
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    %3
    for a = 3:4
        for b = 1:2
            for x = 1:2
                for y = 3:4
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    %4
    for a = 1:2:3
        for b = 1:2:3
            for x = 1:2:3
                for y = 1:2:3
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    %5
    for a = 1:2:3
        for b = 2:2:4
            for x = 2:2:4
                for y = 1:2:3
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    %6
    for a = 2:2:4
        for b = 1:2:3
            for x = 1:2:3
                for y = 2:2:4
                    I(a,b,x,y) = penalty_coeff;
                end
            end
        end
    end
    
    
    %set objective
    %1
    for a = 1:2
        for b = 1:2
            for x = 3:4
                for y = 3:4
                    if I(a,b,x,y) == 0 %do not change the constraint already assigned value to.
                        I(a,b,x,y) = 1;
                    end
                end
            end
        end
    end
    %2
    for a = 1:2:3
        for b = 1:2:3
            for x = 2:2:4
                for y = 2:2:4
                    if I(a,b,x,y) == 0
                        I(a,b,x,y) = 1;
                    end
                end
            end
        end
    end

    I(2,2,3,3)=1;

    inequalityTensor = I;
end
