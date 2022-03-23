function y = bfiltjoe(x,filtSize)

l = length(x);
window = floor(filtSize/2);
y = x;
for j = (window + 1) : (l - window - 1)
    vals = x( (j - window) : (j+window) );
    sortedVals = sort(vals);
    y(j) = mean(sortedVals(2:(end-1)));
 end
    