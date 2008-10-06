function pf = loadPoleFigure_popla(fname,varargin)
% import data fom Popla file
%
%% Syntax
% pf = loadPoleFigure_popla(fname,<options>)
%
%% Input
%  fname    - filename
%
%% Output
%  pf - vector of @PoleFigure
%
%% See also
% interfaces_index popla_interface loadPoleFigure


fid = efopen(fname);

ipf = 1;

while ~feof(fid)

  try
    
    % read header
	  
    % first line --> comments
    comment = textscan(fid,'%s',1,'delimiter','\n','whitespace','');
    comment = char(comment{1}{1});comment = comment(1:10);
    
    % second line
    s = fgetl(fid);
    p = textscan(s,'%5c%5.1f%5.1f%5.1f%5.1f%2d%2d%2d%2d%2d%5d%5d%5c%5c');
    
    h = string2Miller(p{1}); % Miller indice
    dtheta = p{2}; mtex_assert(dtheta > 0 && dtheta < 90);
    mtheta = p{3}; mtex_assert(mtheta > 0 && mtheta <= 180);
    drho = p{4}; mtex_assert(drho > 0 && drho < 90);
    mrho = p{5}; mtex_assert(mrho > 0 && mrho <= 360);
    shifttheta = p{6}; mtex_assert(shifttheta == 1 || shifttheta == 0);
    shiftrho = p{7}; mtex_assert(shiftrho == 1 || shiftrho == 0);
    iper = [p{8:10}]; mtex_assert(all(abs(iper)>0) && all(abs(iper)<4));
    scaling = p{11}; mtex_assert(scaling>0);
    bg = p{12};
    
    % generate specimen directions
    theta = (dtheta*~shifttheta/2:dtheta:mtheta)*degree;
    rho = (drho*~shiftrho/2:drho:mrho-drho/(1+~shiftrho))*degree;
    r = S2Grid('theta',theta,'rho',rho,'reduced');
	
    % read data
    
    a = textscan(fid,[' ',repmat('%4d',1,19)]);
    d = reshape([a{1:18}].',GridSize(r));
          
    % generate Polefigure
    pf(ipf) = PoleFigure(h,r,double(d)*double(scaling),symmetry('cubic'),symmetry,'comment',comment,varargin{:});
  
    ipf = ipf+1;
  catch
    if ~exist('pf','var')
      error('format Popla does not match file %s',fname);
    end
  end
end

fclose(fid);