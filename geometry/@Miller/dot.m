function d = dot(m1,m2,varargin)
% inner product between two Miller indece
%% Syntax
%  a = angle(m1,m2)
%
%% Input
%  m1,m2 - @Miller
%
%% Output
%  d - m1 . m2

% where is the symmetry
if isa(m1,'Miller')
  m1 = vector3d(symmetrise(m1,varargin{:}));
  m2 = vector3d(repmat(m2(:).',size(m1,1),1));
else  
  m2 = vector3d(symmetrise(m2,varargin{:}));
  m1 = vector3d(repmat(m1(:).',size(m2,1),1));
end

% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = dot(m1,m2);

% find maximum
if ~check_option(varargin,'all')
  d = max(d,[],1);
end
