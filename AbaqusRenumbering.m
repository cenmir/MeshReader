classdef AbaqusRenumbering
    %AbaqusRenumbering Renumbers indices
    %   TODO: Write documentation
    
    properties
        IndMap
        Points
        Connectivity
   end
    
    methods
        function o = AbaqusRenumbering(MR, coordSet, nodeSets, dofs, knod)
           if   ~isa(MR, 'Mesh.MeshReader.ReadMesh') 
               error('MR is not of class Mesh.MeshReader.ReadMesh!')
           end
           
           %% Input error handling
           
           M = MR.Mesh;
           nSets =  length(M);
           if nSets == 0
               error('No mesh found in MR!')
           end
           
           nCoordSets = length(coordSet);
           nNodeSets = length(nodeSets);
           
           
           if nCoordSets ~= 1
               error('Number of coordinate sets must be 1!')
           end
           
           if nNodeSets < 0
               error('Number of node sets must be at least 1!')
           end
           if nNodeSets > nSets-1
               error('Too many node sets!')
           end
           
           if nNodeSets + nCoordSets > nSets
               error(['Total number of provided sets (',num2str(nNodeSets + nCoordSets),') exceeds total number of sets (',num2str(nSets),')!'])
           end
           
           for ic = nCoordSets
               if size(M(ic).Data,2)-1 ~= dofs
                   error(['number of dofs does not match the data in the coordinate set: ',num2str(ic),'!'])
               end
           end
           
           for ic = nNodeSets
               if size(M(ic).Data,2)-1 ~= knod
                   error(['number of nodes per element (knod) does not match the data in the node set: ',num2str(ic),'!'])
               end
           end
           
           %% Extract sets
           PointsData = M(coordSet).Data;
           o.Points = PointsData(:,2:end);
           nnod = size(PointsData,1);
           o.IndMap = [PointsData(:,1),[1:nnod]']; %vectorized
           
           nele = 0;
           for iM = nodeSets
               nele = nele + size(M(iM).Data,1);
           end
           o.Connectivity = zeros(nele,knod);
           
           lo = 1;
           for iM = nodeSets
               nodesD = M(iM).Data(:,2:end);
               inele = size(nodesD,1);
               inodes = zeros(size(nodesD));
               for iel = 1:inele
                   row = nodesD(iel,:);
                   ir = 1;
                   for ind0 = row
                       ind1 = find(ind0 == o.IndMap(:,1));
                       inodes(iel,ir) = ind1;
                       ir = ir +1;
                   end
               end
               
               up = lo + inele -1;
               
               o.Connectivity(lo:up,:) = inodes;
               lo = lo + inele;
               
           end
           
        end
        
        
    end
    
end

