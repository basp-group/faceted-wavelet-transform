function im=place2DSegment(im,segment)

corner = segment{2,2};
segSize = segment{2,3};
im(corner(1)+1:corner(1)+segSize(1),corner(2)+1:corner(2)+segSize(2)) = ...
im(corner(1)+1:corner(1)+segSize(1),corner(2)+1:corner(2)+segSize(2))+segment{5,1};