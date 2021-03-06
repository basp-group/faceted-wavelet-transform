clc; clear all; close all
format compact

addpath data
addpath src

rng(1234)
x = randn(1024, 1024);
% x = x(1:951, 43:1024);
N = size(x);

%%
% sdwt2

% facet definition
Qy = 3;
Qx = 3;
Q = Qx*Qy;
rg_y = split_range(Qy, N(1));
rg_x = split_range(Qx, N(2));
randBool = false;

segDims = zeros(Q, 4);
for qx = 1:Qx
    for qy = 1:Qy
        q = (qx-1)*Qy+qy;
        segDims(q, :) = [rg_y(qy, 1)-1, rg_x(qx, 1)-1, rg_y(qy,2)-rg_y(qy,1)+1, rg_x(qx,2)-rg_x(qx,1)+1];
    end
end
I = segDims(:, 1:2);
dims = segDims(:, 3:4);

% Wavelet parameters
n = 1:8;
nlevel = 3;
M = numel(n)+1;
dwtmode('zpd','nodisp');
wavelet = cell(M, 1);
for m = 1:M-1
    wavelet{m} = ['db', num2str(n(m))];
end
wavelet{end} = 'self';
L = [2*n,0].'; % filter length

% Compute auxiliary parameters (see if it can be simplified further)
% [I_overlap_ref, dims_overlap_ref, I_overlap, dims_overlap, ...
%     status, offset, offsetL, offsetR, Ncoefs, temLIdxs, temRIdxs] = setup_sdwt2(N, I, dims, nlevel, wavelet, L);
% [I_overlap_ref0, dims_overlap_ref0, I_overlap0, dims_overlap0, ...
%     status0, offset0, pre_offset0, post_offset0, Ncoefs0, pre_offset_dict0, ...
%     post_offset_dict0] = sdwt2_setup_test(N, I, dims, nlevel, wavelet, L);
[I_overlap_ref, dims_overlap_ref, I_overlap, dims_overlap, ...
    status, offset, pre_offset, post_offset, Ncoefs, pre_offset_dict, ...
    post_offset_dict] = sdwt2_setup(N, I, dims, nlevel, wavelet, L);

SPsitLx = cell(Q, 1);
PsiStu = cell(Q, 1);
for q = 1:Q
    % full facet-size, including 0-padding (pre_offset / post_offset 0s added)
    % I_overlap_ref / dims_overlap_ref do not include the zeros added!
    % only indicates portion to be extracted from the global image to
    % create the local facet
    full_facet_size = dims_overlap_ref(q,:) + pre_offset(q,:) + post_offset(q,:); 
    
    % size of the the image extension is actually specified here! to be 
    % possibly changed (if other than zero padding)
    % in practice, we are thus computing larger convolution all the way
    x_overlap = zeros(full_facet_size); 
    
    x_overlap(pre_offset(q,1)+1:end-post_offset(q,1),...
            pre_offset(q,2)+1:end-post_offset(q,2))...
            = x(I_overlap_ref(q, 1)+1:I_overlap_ref(q, 1)+dims_overlap_ref(q, 1), ...
        I_overlap_ref(q, 2)+1:I_overlap_ref(q, 2)+dims_overlap_ref(q, 2)); 
    
    % forward operator [put the following instructions into a parfeval for parallelisation]
    SPsitLx{q} = sdwt2_sara_faceting(x_overlap, I(q, :), offset, status(q, :), nlevel, wavelet, Ncoefs{q});
    
    % inverse operator (for a single facet) u{q}
    PsiStu{q} = isdwt2_sara_faceting(SPsitLx{q}, I(q, :), dims(q, :), I_overlap{q}, dims_overlap{q}, Ncoefs{q}, nlevel, wavelet, pre_offset_dict{q}, post_offset_dict{q});
end
% 
LtPsiStu = zeros(N);
for q = 1:Q
    LtPsiStu = place2DSegment(LtPsiStu, PsiStu{q}, I_overlap_ref(q, :), dims_overlap_ref(q, :));
    imshow(LtPsiStu);
    pause(0.5)
end

err = norm(LtPsiStu(:) - x(:));
