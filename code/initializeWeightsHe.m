function x = initializeWeightsHe(sz)
    fanIn = prod(sz(1:2));
    stddev = sqrt(2/fanIn);
    x = stddev .* randn(sz);
end