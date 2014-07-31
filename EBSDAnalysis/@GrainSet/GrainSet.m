classdef GrainSet < dynProp & misorientationAnalysis
  % construct
  %
  % *GrainSet* represents grain objects. a *GrainSet* can be constructed from
  % spatially indexed @EBSD data by the routine [[EBSD.calcGrains.html,
  % calcGrains]]. in particular
  %
  %   grains = calcGrains(ebsd)
  %
  % constructs such a *GrainSet*.
  %
  % Input
  %  grainStruct - incidence and adjaceny matrices
  % 
  %
  % See also
  % EBSD/calcGrains Grain3d/Grain3d Grain2d/Grain2d
  
  properties
    V  = zeros(0,3)              % vertices - (x,y,(z)) coordinate
    F  = zeros(0,3)              % edges(faces) - vertices ids (v1,v2,(v3))
    I_DG = sparse(0,0)           % voronoi cells x grains
    I_FDint = sparse(0,0)        % interior faces x voronoi cells
    I_FDext = sparse(0,0)        % exterior faces y voronoi cells
    
    A_Db  = sparse(0,0)          % cells with grain boundary
    A_Do  = sparse(0,0)          % cells within one grain
        
    meanRotation = rotation      % mean rotation of the grain        
    ebsd                         % the ebsd data
  end
  
  properties (Dependent = true)
    id                           % identification number
    A_D                          % adjacent cells
    A_G                          % adjacent grains
    I_VF
    I_VD
    I_VG
    I_FD                         % faces - cells
    I_FG                         % faces - grains
    phaseId
    phase
    phaseMap
    CS
    allCS
    mineral                     % mineral name of the grain
    allMinerals                 % all mineral names of the data set
    mis2mean
    meanOrientation             % mean orientation of the grain
    indexedPhasesId             % id's of all non empty indexed phase 
  end
  
  methods
    function obj = GrainSet(varargin)
      
           
    end
 
    function id = get.id(grains)
      id = find(any(grains.I_DG,1));
    end
    
    function A_D = get.A_D(grains)
      A_D = double(grains.A_Db | grains.A_Do);
    end
    
    function A_G = get.A_G(grains)
      A_G = grains.I_DG'*double(grains.A_Db)*grains.I_DG;
    end
    
    function id = get.indexedPhasesId(grains)
      
      id = grains.ebsd.indexedPhasesId;
    
    end
    
    function I_VF = get.I_VF(grains)
      % vertices incident to a grain V x G
      [i,~,v] = find(double(grains.F));
      I_VF = sparse(v,i,1,size(grains.V,1),size(grains.I_FDext,1));
    end
    
    function I_VD = get.I_VD(grains)
      I_VD = grains.I_VF * grains.I_FD;
    end
    
    function I_VG = get.I_VG(grains)
      I_VG = grains.I_VD * grains.I_DG;
    end
    
    function I_FD = get.I_FD(grains)
      I_FD = grains.I_FDext | grains.I_FDint;
    end
    
    function I_FG = get.I_FG(grains)
      I_FG = grains.I_FD*double(grains.I_DG);
    end
    
    function phId = get.phaseId(grains)
      d = find(any(grains.I_DG,2));      
      D = sparse(d,d,grains.ebsd.phaseId,size(grains.I_DG,1),size(grains.I_DG,1));
      
      phId = nonzeros(max(grains.I_DG'*D,[],2));
    end
    
    function ph = get.phase(grains)
      ph = grains.phaseMap(grains.phaseId);
    end
    
    function map = get.phaseMap(grains)
      map = grains.ebsd.phaseMap;
    end
    
    function grains = set.phaseMap(grains,map)
      grains.ebsd.phaseMap = map;
    end
    
    function CS = get.CS(grains)
      CS = grains.ebsd.CS;
    end
    
    function grains = set.CS(grains,CS)
      grains.ebsd.CS = CS;
    end
    
    function allCS = get.allCS(grains)
      allCS = grains.ebsd.allCS;
    end
    
    function grains = set.allCS(grains,allCS)
      grains.ebsd.allCS = allCS;
    end
    
    function grains = set.phaseId(grains,ph)
      g = find(any(grains.I_DG,1));
      G = sparse(g,g,ph,size(grains.I_DG,2),size(grains.I_DG,2));
      
      grains.ebsd.phaseId = nonzeros(max((grains.I_DG*G),[],2));
    end
    
    function grains = set.phase(grains,ph)
      
      phId = zeros(size(ph));
      for i = 1:numel(grains.phaseMap)
        phId(ph==grains.phaseMap(i)) = i;
      end
      
      grains.phaseId = phId;
    end
    
    function mis2mean = get.mis2mean(grains)
      
      % restrict to actual grains
      I_DG_restricted = grains.I_DG(any(grains.I_DG,2),any(grains.I_DG,1));
      
      % find pairs of grains and orientations
      [g,d] = find(I_DG_restricted');
      mis2mean = inv(grains.ebsd.orientations(d)).* ...
        reshape(grains.meanOrientation(g),[],1);

    end
    
    function ori = get.meanOrientation(grains)
      
      % ensure single phase
      [grains,cs] = checkSinglePhase(grains);
      
      ori = orientation(grains.meanRotation,cs);
    end
            
    function mineral =  get.mineral(grains)
      
      mineral = grains.ebsd.mineral;
    
    end
    
    function minerals = get.allMinerals(grains)
      
      minerals = grains.ebsd.allMinerals;
    
    end
  end
  
  methods (Access = protected)
    
    function ind = subsind(grains,subs)
      ind = true(length(grains),1);
      
      for i = 1:length(subs)
        
        if ischar(subs{i}) || iscellstr(subs{i})
          
          miner = ensurecell(subs{i});
          alt_mineral = cellfun(@num2str,num2cell(grains.phaseMap),'Uniformoutput',false);
          phases = false(length(grains.phaseMap),1);
          
          for k=1:numel(miner)
            phases = phases | ~cellfun('isempty',regexpi(grains.allMinerals(:),miner{k})) | ...
              strcmpi(alt_mineral,miner{k});
          end
          ind = ind & phases(grains.phaseId(:));
          
          %   elseif isa(subs{i},'grain')
          
          %     ind = ind & ismember(ebsd.options.grain_id,get(subs{i},'id'))';
          
        elseif isa(subs{i},'logical')
          
          sub = any(subs{i}, find(size(subs{i}')==max(size(ind)),1));
          
          ind = ind & reshape(sub,size(ind));
          
        elseif isnumeric(subs{i})
          
          if any(subs{i} <= 0 | subs{i} > length(grains))
            error('Out of range; index must be a positive integer or logical.')
          end
          
          iind = false(size(ind));
          iind(subs{i}) = true;
          ind = ind & iind;
          
        elseif isa(subs{i},'polygon')
          
          ind = ind & inpolygon(grains,subs{i})';
          
        end
      end
    end
    
  end
 
  
  methods (Access=protected)
    function grains = cleanupFaces(grains)
      % remove faces that are not a grainboundary

      ind = ~any(grains.I_FD,2);
      grains.F(ind,:) = 0;
      
    end
  end
  
end

% ------------ mean orientation and phase --------------------------
function meanRotation = calcMeanRotation(grains)

[d,g] = find(grains.I_DG);

grainSize     = full(sum(grains.I_DG>0,1));   % points per grain
grainRange    = [0 cumsum(grainSize)];        % 
firstD        = d(grainRange(2:end));
phaseId       = grains.ebsd.phaseId(firstD);
q             = quaternion(grains.ebsd.rotations);
meanRotation  = q(firstD);

indexedPhases = ~cellfun('isclass',grains.allCS(:),'char');

for p = grains.indexedPhasesId
  ndx = grains.ebsd.phaseId(d) == p;
  if any(ndx)
    q(d(ndx)) = project2FundamentalRegion(...
      q(d(ndx)),grains.allCS{p},meanRotation(g(ndx)));
  end
  
  % mean may be inaccurate for some grains and should be projected again
  % any(sparse(d(ndx),g(ndx),angle(q(d(ndx)),meanRotation(g(ndx))) > getMaxAngle(ebsd.CS{p})/2))
end

doMeanCalc    = find(grainSize(:)>1 & indexedPhases(phaseId));
cellMean      = cell(size(doMeanCalc));
for k = 1:numel(doMeanCalc)
  cellMean{k} = d(grainRange(doMeanCalc(k))+1:grainRange(doMeanCalc(k)+1));
end
cellMean = cellfun(@mean,partition(q,cellMean),'uniformoutput',false);

meanRotation(doMeanCalc) = [cellMean{:}];

end