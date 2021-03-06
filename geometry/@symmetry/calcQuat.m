function s = calcQuat(s,axes)
% calculate quaternions for Laue groups

if nargin == 1, axes = [xvector,yvector,zvector]; end

ll0axis = vector3d(1,1,0);
lllaxis = vector3d(1,1,1);

a = axes(1);
b = axes(2);
c = axes(3);

a1 = axes(1);
a2 = axes(2);
m = a1 - a2;

pg = pointGroupList;
pg = pg(s.id);

% compute rotations
switch pg.properId
  case 1 % 1
    rot = {rotation('Euler',0,0,0)};    
  case 3 % 211
    rot = {symAxis(a,2)};
  case 6 % 121
    rot = {symAxis(b,2)};
  case 9 % 112
    rot = {symAxis(c,2)};    
  case 12 % 222
    rot = {symAxis(a,2),symAxis(c,2)};
  case 17 % 3
    rot = {symAxis(c,3)};
  case 19 % 321
    rot = {symAxis(a1,2),symAxis(c,3)};
  case 22 % 312
    rot = {symAxis(m,2),symAxis(c,3)};
  case 25 % 4    
    rot = {symAxis(c,4)};
  case 28 % 4/mmm
    rot = {symAxis(a,2),symAxis(c,4)};
  case 33 % 6
    rot = {symAxis(c,6)};
  case 36 % 622
    rot = {symAxis(a,2),symAxis(c,6)};
  case 41 % 23
    rot = {symAxis(lllaxis,3),symAxis(a,2),symAxis(c,2)};
  case 43 % 432
    rot = {symAxis(lllaxis,3),symAxis(ll0axis,2),symAxis(c,4)};
end

% apply inversion
if size(pg.Inversion ,1) == 2
  rot = [rot,{[rotation(idquaternion),-rotation(idquaternion)]}];
else
  rot = arrayfun(@(i) rot{i} .* pg.Inversion(i).^(0:length(rot{i})-1) ,...
    1:length(rot),'uniformOutput',false);
  
end

% store symmetries
rot = prod(rot{:});
[s.a, s.b, s.c, s.d] = double(rot);
s.i = isImproper(rot);

end
