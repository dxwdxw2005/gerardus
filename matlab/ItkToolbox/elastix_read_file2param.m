function param = elastix_read_file2param(filename)
% elastix_read_file2param  Read file with elastix parameters into struct.
% It accepts nested transform files.
%
% PARAM = elastix_read_file2param(FILENAME)
%
%   FILENAME is a string with the path and filename of a parameter file
%   created by elastix (e.g. parameters for registration, or transformation
%   parameters with the result of a registration). The file is a text file,
%   and looks e.g. like the following
%
%   (Transform "SimilarityTransform")
%   (NumberOfParameters 4)
%   (TransformParameters 1.0001 -7.2000e-05 4.6345 -0.2104)
%   (InitialTransformParametersFileName "NoInitialTransform")
%   (HowToCombineTransforms "Compose")
%   (FixedImageDimension 2)
%   (MovingImageDimension 2)
%   (FixedInternalImagePixelType "float")
%   ...
%
%   PARAM is a struct with the same parameters. For example above:
%
%                             Transform: 'SimilarityTransform'
%                    NumberOfParameters: 4
%                   TransformParameters: [1.0001 -7.2000e-05 4.6345 -0.2104]
%    InitialTransformParametersFileName: 'NoInitialTransform'
%                HowToCombineTransforms: 'Compose'
%                   FixedImageDimension: 2
%                  MovingImageDimension: 2
%           FixedInternalImagePixelType: 'float'
%                                     ...
%
%   Parameters with more than one value are converted to cell arrays. E.g.
%
%   (FixedImagePyramid "FixedSmoothingImagePyramid" "FixedSmoothingImagePyramid" "FixedSmoothingImagePyramid")
%
%   parses to
%
%   FixedImagePyramid: {1x3 cell}
%
% See also: elastix_write_param2file.

% Author: Ramon Casero <rcasero@gmail.com>
% Copyright © 2014 University of Oxford
% Version: 0.2.3
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

% check arguments
narginchk(1, 1);
nargoutchk(0, 1);

if (~ischar(filename))
    error('FILENAME must be a string')
end

% read transform file or nested files
param = read_one_param_file(filename);

end

% this is a nested function to read a series of nested parameter files
% to structs. The function is called on a file a.txt. If a.txt has an
% "initial transform" b.txt (a transform that has to be applied before
% a.txt), then this function is called on b.txt before returning. Thus, we
% have nested calls
function param = read_one_param_file(filename)

% init output struct
param = struct([]);

% open transform parameters text file to read
fid = fopen(filename, 'r');
if (fid == -1)
    error(['Cannot open ' filename])
end

% read text file line by line
tline = fgetl(fid);
while ischar(tline)
    
    % remove everything after the comment sign
    tline = regexprep(tline, '//.*', '');
    
    % check whether we have a line with something in brackets
    tline2 = regexp(tline, '\(.*\)', 'match');
   
    % if not, this is a comment or empty line and we can skip it
    if (isempty(tline2))
        
        % read next line
        tline = fgetl(fid);
        
        continue;
    end
    
    % remove brackets
    tline2 = tline2{1};
    tline2 = tline2(2:end-1);
    
    % get parameter field label
    label = regexp(tline2, '\s*', 'split');
    label = label{1};
    
    % remove label from label
    tline2 = regexprep(tline2, ['\<' label '\s*'], '');
    
    % split line into words
    tline2 = regexp(tline2, '"\s*"', 'split');
    
    % remove double quotes (")
    tline2 = regexprep(tline2, '"', '');
    
    % get parameter values
    val = tline2;
    
    % if the values can be converted to numeric format, we do. Otherwise,
    % it's a string
    for I = 1:length(val)
        
        % try to convert to numeric (note that 'true' and 'false', although
        % strings, get successfully converted to 1 and 0, respectively)
        val2 = str2num(val{I});
        
        if (~isempty(val2) && ~strcmp(val{I}, 'true') ...
                && ~strcmp(val{I}, 'false')) % is numeric
            val{I} = val2;
        end
    end
    
    % if there's only one value, we take it out of the cell, so that it's a
    % number or string
    if (length(val) == 1)
        val = val{1};
    end
    
    % add field to output struct
    if (isempty(param))
        param = struct(label, val);
    else
        param.(label) = val;
    end
    
    % read next line
    tline = fgetl(fid);
    
end

% close parameters file
fclose(fid);

% if there's a previous nested transform...
if (isfield(param, 'InitialTransformParametersFileName') ...
        && ~strcmp(param.InitialTransformParametersFileName, 'NoInitialTransform'))
    % ... read it
    param.InitialTransformParametersFileName ...
        = read_one_param_file(param.InitialTransformParametersFileName);
end

end
