function strategy = indexToStrategy(index, base, length)
%INDEXTOSTRATEGY Decode a one-based index into little-endian strategy values.
%   Each returned value is one-based. The first position changes fastest.

strategy = ones(1, length);
index = index - 1;
for position = 1:length
    strategy(position) = mod(index, base) + 1;
    index = floor(index / base);
end
end
