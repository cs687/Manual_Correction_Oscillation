function rgb = makergb(r,g,b,normornot);
% function rgb = makergb(r,g,b,normornot)
%
% This function reads in red, green, and blue images, composites them, and returns them as a 0-255 scaled uint.
% Needs at least two images (r and g), with an option for a third.
% 'normornot' = 1 normalizes all images to 0-1 separately before
% compositing.
if nargin<2,
	disp('Error: I need at least 2 images here!');
	return;
end;
if nargin<4
    normornot=1;
end

if size(r,1) == 1,
	% these must be filenames;
	r = imread(r);
	g = imread(g);
	if nargin>=3,
		b = imread(b);
	end;
end;

if nargin==2,
	b = r;
	b(:) = 0;
end;

r = double(r(:,:,1,1));
g = double(g(:,:,1,1));
b = double(b(:,:,1,1));

if normornot
	rgb(:,:,1) = (r-minmin(r)) / (maxmax(r)-minmin(r));
	rgb(:,:,2) = (g-minmin(g)) / (maxmax(g)-minmin(g));
	if nargin>2
        rgb(:,:,3) = (b-minmin(b)) / (maxmax(b)-minmin(b));
	else
        rgb(:,:,3) = zeros(size(r));
	end
else
	rgb(:,:,1) = (r);%-minmin(r)) / (maxmax(r)-minmin(r));
	rgb(:,:,2) = (g);%-minmin(g)) / (maxmax(g)-minmin(g));
	if nargin>2
        rgb(:,:,3) = (b);%-minmin(b)) / (maxmax(b)-minmin(b));
	else
        rgb(:,:,3) = zeros(size(r));
	end
end    

rgb(isnan(rgb)) = 0;
rgb = uint8(rgb * 255);