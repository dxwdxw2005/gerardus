function [txnorm, tx] = blockface_frame_shifts(files, pathtofiles)
% blockface_frame_shifts  Find translation shifts between consecutive
% blockface frames.
%
% [TXNORM, TX] = blockface_frame_shifts(FILES, PATHTOFILES)
%
%   FILES is the result of a dir() command, e.g. dir('*_55_*.png'). The
%   function expects a list of blockface images.
%
%   PATHTOFILES is the full path to the files. By default, PATHTOFILES='.'.
%
%   TXNORM is a vector with the norm of the translation vector between
%   pairs of frames. If there are N blockface images, then TXNORM has N-1
%   elements. TXNORM(I) is the norm of the translation from FILES(I+1) to
%   FILES(I).
%
%   TX is an (N-1, 2)-matrix with the (x, y) translation vector. TX(I,:) is
%   the translation from FILES(I+1) to FILES(I).

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

DEBUG = 0;

% check arguments
narginchk(1, 2);
nargoutchk(0, 2);

% defaults
if (nargin < 2 || isempty(pathtofiles))
    pathtofiles = '.';
end

% write translation registration parameters to a temp file
paramfile = write_translate_parameters_file();

% init translation displacement vector
tx = zeros(length(files)-1, 2);
txnorm = zeros(length(files)-1, 1);

% expand list of files names so that they can operate as sliced variables
% in the parfor loop
fixed = files(1:end-1);
moving = files(2:end);

% load images
parfor I = 1:length(files)-1
    
    % display frame number
    if (DEBUG)
        disp(['Frame ' num2str(I)])
    end
    
    % register I+1 frame onto I frame
    [tx(I, :), txnorm(I)] = frame_registration(...
        [pathtofiles filesep fixed(I).name], ...
        [pathtofiles filesep moving(I).name], ...
        paramfile, DEBUG);
    
end

% delete temp file
delete(paramfile);

end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% frame_registration()
%
%   Translate registration of two frames.
function [tx, txabs] = frame_registration(fixed, moving, paramfile, DEBUG)

% temporary file for moving image and output directory for elastix
im2_temp = [tempname '.png'];
outdir_temp = tempname;
mkdir(outdir_temp)

% load two consecutive frames
im1 = imread(fixed);
im2 = imread(moving);

% convert to grayscale
im1 = rgb2gray(im1);
im2 = rgb2gray(im2);

% match 2nd frame's histogram to 1st frame's histogram
im2 = imhistmatch(im2, im1);

% plot image 1 and difference with image 2
if (DEBUG)
    subplot(2, 1, 1)
    hold off
    imagesc(im1)
    subplot(2, 1, 2)
    hold off
    imshowpair(im1, im2, 'Scaling', 'joint');
end

% save moving image to temporary file so that we can use elastix
imwrite(im2, im2_temp);

% translation registration of images
if (DEBUG)
    system([...
        'elastix ' ...
        ' -f ' fixed ...
        ' -m ' moving ...
        ' -out ' outdir_temp ...
        ' -p ' paramfile
        ]);
else
    % hide command output from elastix
    [status, result] = system([...
        'elastix ' ...
        ' -f ' fixed ...
        ' -m ' moving ...
        ' -out ' outdir_temp ...
        ' -p ' paramfile
        ]);
end

% read result
im2_reg = imread([outdir_temp filesep 'result.0.png']);

% read transform parameters
fid = fopen([outdir_temp filesep 'TransformParameters.0.txt']);
if (fid == -1)
    error(['Cannot open ' outdir_temp filesep 'TransformParameters.0.txt'])
end
c = textscan(fid, '%s %s %s', 'Delimiter', ' ', 'ReturnOnError', false);
fclose(fid);
idx = find(strcmp('(TransformParameters', c{1}));
tx = [str2double(c{2}{idx}) str2double(c{3}{idx}(1:end-1))];

% translation displacement
txabs = norm(tx);

% plot result
if (DEBUG)
    subplot(2, 1, 1)
    hold off
    imshowpair(im1, im2, 'Scaling', 'joint');
    subplot(2, 1, 2)
    hold off
    imshowpair(im1, im2_reg, 'Scaling', 'joint');
end

% delete temp directory and file
rmdir(outdir_temp, 's')
delete(im2_temp)

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% write_translate_parameters_file()
%
%   Create a text file with the registration parameters
function file = write_translate_parameters_file()

% create unique temp name for the parameters file
[pathstr, name] = fileparts(tempname);
file = [pathstr filesep 'ParametersTranslation2D-' name '.txt'];

% text of the parameters file
file_text = {
'// Parameter file for affine registration'
''
'// The internal pixel type, used for computations'
'// Leave to float in general'
'(FixedInternalImagePixelType "float")'
'(MovingInternalImagePixelType "float")'
''
'// The dimensions of the fixed and moving image'
'(FixedImageDimension 2)'
'(MovingImageDimension 2)'
''
'//Components'
''
'// The following components should be left as they are:'
'(Registration "MultiResolutionRegistration")'
'(FixedImagePyramid "FixedRecursiveImagePyramid")'
'(MovingImagePyramid "MovingRecursiveImagePyramid")'
'(Interpolator "BSplineInterpolator")'
'(ResampleInterpolator "FinalBSplineInterpolator")'
'(Resampler "DefaultResampler")'
''
'// You may change these:'
'// The optimizer RegularStepGradientDescent (RSGD) works quite ok '
'// in general. You may also use the StandardGradientDescent,'
'// like in parameters_Rigid.txt. The Transform and Metric'
'// are important and need to be chosen careful for each application.'
'(Optimizer "RegularStepGradientDescent")'
'(Transform "TranslationTransform")'
'(Metric "AdvancedMeanSquares")'
''
'// Scales the rotations compared to the translations, to make'
'// sure they are in the same range. The higher this parameter,'
'// the smaller the changes in rotation angle in each iteration.'
'// If you have the feeling that rotations are not found by elastix,'
'// decrease it; if elastix crashes after a few iterations, with'
'// the message that all samples map outside the moving image '
'// buffer, you may have to increase this parameter.'
'(Scales 1000.0)'
''
'// Automatically guess an initial translation. Not needed/recommended'
'// here, because we already did a rigid registration before!'
'(AutomaticTransformInitialization "false")'
''
'// Highly recommended to set this from elastix 4.3'
'(UseDirectionCosines "true")'
''
'// Choose another center of rotation for the AffineTransform,'
'// if you like. Uncomment if you want that.'
'(CenterOfRotation 1232 954)'
''
'// The number of resolutions. 1 Is only enough if the expected'
'// deformations are small. 3 or 4 mostly works fine.'
'(NumberOfResolutions 1)'
''
'// The pixel type of the resulting image'
'(ResultImagePixelType "unsigned char")'
''
'// Whether transforms are combined by composition or by addition.'
'// In general, Compose is the best option in most cases.'
'// It does not influence the results very much.'
'(HowToCombineTransforms "Compose")'
''
'// Number of spatial samples used to compute the mutual'
'// information in each resolution level.'
'// With the RegularStepGradientDescentOptimizer in general'
'// you need to set this to some fixed fraction of the total '
'// number of voxels in the image. Say 20%, at least.'
'// In the first resolutions the images are smaller so you '
'// may use less samples.'
'(NumberOfSpatialSamples 1500000)'
''
'// Pick the samples (pseudo)randomly. Use "Full" if you want'
'// to use all voxels to compute metric. (then the previous '
'// option makes of course no sense anymore).'
'(ImageSampler "Random")'
''
'//Order of B-Spline interpolation used in each resolution level:'
'// It may improve accuracy if you set this to 3. Never use 0.'
'(BSplineInterpolationOrder 3)'
''
'//Order of B-Spline interpolation used for applying the final'
'// deformation.'
'// 3 gives good accuracy.'
'// 1 gives worse accuracy (linear interpolation)'
'// 0 gives worst accuracy, but may be appropriate for '
'// binary images; this would be equivalent to nearest neighbor'
'// interpolation.'
'(FinalBSplineInterpolationOrder 3)'
''
'//Default pixel value for pixels that come from outside the picture:'
'(DefaultPixelValue 0)'
''
'// The following parameters are for the StandardGradientDescent'
'// optimizer. They determine the step size.'
'// Especially SP_a needs to be tuned for each specific application.'
'// The number of iterations is also important.'
''
'//Maximum number of iterations in each resolution level:'
'// 100-500 works usually fine.'
'(MaximumNumberOfIterations 100)'
''
'//Maximum step size of the RSGD optimizer for each resolution level.'
'// The higher you set this, the more aggressive steps are taken.'
'(MaximumStepLength 2.0)'
''
'//Minimum step size of the RSGD optimizer for each resolution level.'
'// The lower you set this, the more accurate the final result.'
'(MinimumStepLength 0.05)'
''
'//Minimum magnitude of the gradient (stopping criterion) for the RSGD optimizer:'
'// The lower you set this, the more accurate the final result may be.'
'(MinimumGradientMagnitude 0.00000001)'
''
'//Result image format'
'(ResultImageFormat "png")'
    };

% write text to file
fid = fopen(file, 'w+t');
if (fid == -1)
    error(['Error: Cannot open file descriptor to write registration parameters file: ' file])
end
[nrows, ~] = size(file_text);
for row = 1:nrows
    fprintf(fid, '%s\n', file_text{row, :});
end
st = fclose(fid);
if (st == -1)
    error(['Error: Cannot close parameters file: ' file])
end

end
