% SCIMAT  Struct used in Gerardus to store 3D images and their metadata.
%
%   Medical image processing usually requires knowledge not only of voxel
%   intensity values, but of voxel size, image orientation and position.
%   Hence, in Gerardus we use a struct, that we call SCIMAT, to enrich
%   images. An example of a SCIMAT image:
%
%   scimat = 
%   
%           data:   [415x460x900 single]
%           axis:   [3x1 struct]
%           rotmat: [3x3 double]
%
%   data:   A 3D array that contains the image voxels.
%   axis:   A 3-vector with the following fields:
%       size:    Image size.
%       spacing: Voxel size, i.e. spacing between voxel centres. 
%       min:     Coordinates of the "bottom-left" corner of the image, NOT
%                of the first voxel's centre. The first voxel's centre
%                coordinates = min+spacing/2.
%       max:     Unused.
%       center:  Unused.
%       unit:    Spacing, center and min units.
%       label:   Unused.
%   rotmat: A (3, 3)- matrix that gives the image orientation as a rotation
%           of the x, y, z Cartesian axes.
%
%   The SCIMAT struct follows the Matlab convention that image arrays are
%   sorted as (y, x, z)
%
%     axis(1) ==> rows
%     axis(2) ==> columns
%     axis(3) ==> slices
%
%   but rotations and point coordinates are given as (x, y, z).
%
%   In the earlier versions of Gerardus, SCIMAT was called NRRD. A bad
%   choice, as SCIMAT has nothing to do with the NRRD format developed by
%   the Teem project (http://teem.sourceforge.net/nrrd/format.html). But
%   there are still some functions in Gerardus that haven't been upgraded
%   and have names like "scinrrd_*" instead of "scimat_*".%
%
%   SCIMAT is based on the struct generated by the visualization platform
%   Seg3D, developed by the University of Utah Scientific Computing and
%   Imaging (SCI) Institute. When you save an image or segmentation to
%   Matlab format from Seg3D, the file contains a struct with the name
%   "scirunnrrd". Compared to SCIMAT, this struct has an extra dummy
%   dimension and the (rows,columns) in the image are switched.
%
%   >>  scirunnrrd
%
%   scirunnrrd = 
%
%          data: [4-D uint8]
%          axis: [4x1 struct]
%      property: []

% Author: Ramon Casero <rcasero@gmail.com>
% Copyright © 2014 University of Oxford
% Version: 0.1.0
% $Rev$
% $Date$
% 
% University of Oxford means the Chancellor, Masters and Scholars of
% the University of Oxford, having an administrative office at
% Wellington Square, Oxford OX1 2JD, UK. 
%
% This file is part of Gerardus.
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details. The offer of this
% program under the terms of the License is subject to the License
% being interpreted in accordance with English Law and subject to any
% action against the University of Oxford being under the jurisdiction
% of the English Courts.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <http://www.gnu.org/licenses/>.
