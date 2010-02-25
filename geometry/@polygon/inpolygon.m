function ind = inpolygon( p , p2, method)
% check whether a polygon is in a given polygon
%
%% Syntax
%  ind = inpolygon(polygon1 ,polygon2)
% 
%% Input
%  p   - @polygon
%  p2  - @polygon
%
%% Option
%  method - 'complete' (default), 'centroids', 'intersect'
%
%% Output
%  ind    - logical indexing
%

p = polygon( p );
x = polygon( p2 );

xy = vertcat(x.xy);

if nargin < 3
  method = 'complete';
end

switch lower(method)
  case 'complete'
    ind = in_it(p,xy,@all);
  case 'centroids'  
    pxy = centroid(p);
    ind = inpolygon(pxy(:,1),pxy(:,2),xy(:,1),xy(:,2));
  case 'intersect'
    ind = in_it(p,xy,@any);
end

ind = reshape(ind,size(p));



function ind = in_it(p,xy,modifier)

np = cellfun('length',{p.xy});
pxy = vertcat(p.xy);
    
in = inpolygon(pxy(:,1),pxy(:,2),xy(:,1),xy(:,2));

cs = [0 cumsum(np)];

ind = false(size(np));
for k=1:length(np)
  ind(k) = modifier(in(cs(k)+1:cs(k+1)));
end


% ind = cellfun(modifier,mat2cell(in, np,1));
