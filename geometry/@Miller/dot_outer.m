function d = dot_outer(m1,m2,varargin)
% inner product between two Miller indece
%% Syntax
%  a = dot_outer(m1,m2)
%
%% Input
%  m1,m2 - @Miller
%
%% Output
%  d - m1 . m2

% where is the symmetry
if isa(m1,'Miller')
  m1 = symmetrise(m1,varargin{:});
  s = [size(m1),numel(m2)];
  dim = 1;
else
  m2 = symmetrise(m2,varargin{:});
  s = [numel(m1),size(m2)];
  dim = 2;
end

% normalize
m1 = m1 ./ norm(m1);
m2 = m2 ./ norm(m2);

% dotproduct
d = reshape(dot_outer(vector3d(m1),vector3d(m2)),s);

% find maximum
if check_option(varargin,'all')
  if dim == 1
    d = permute(d,[2 3 1]);
  else
    d = permute(d,[1 3 2]);
  end
else
  d = squeeze(max(d,[],dim));
end
