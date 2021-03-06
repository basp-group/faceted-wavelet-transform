function rg = split_range_interleaved(nchunks, N)
% Tessellates 1:N into interleaved subsets.
%
% Tessellates 1:L into subsets of interleaved indices, each containing
% approximately the same number of indices (downsampling of 1:N).
%
% Args:
%     nchunks (int): number of segments.
%     N (int): total number of indices. 
%
% Returns:
%     rg (array): first/last index of each segment {Q, 1}.

%-------------------------------------------------------------------------%
%%
% Code: P.-A. Thouvenin.
%-------------------------------------------------------------------------%
%%
if nchunks > N
    error('split_range_interleaved:ValueError', ...
    'Number of facets Q=%i greater than the dimension L=%i', nchunks, N);
end

rg = cell(nchunks, 1);
for q = 1:nchunks
    rg{q} = q:nchunks:N;
end

end
