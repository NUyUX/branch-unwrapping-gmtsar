function []=unwrapping_example(corr,  area_x, area_y);
 

%load the needed packages; please install if not found, note that you will have to use octave v.4.0 or better. 
pkg load image
load example.mat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script unwrappes GMTSAR outputs with the 2D Goldstein branch cut phase unwrapping algorithm.
%
% References::
% 1. R. M. Goldstein, H. A. Zebken, and C. L. Werner, �Satellite radar interferometry:
%    Two-dimensional phase unwrapping,� Radio Sci., vol. 23, no. 4, pp. 713�720, 1988.
% 2. D. C. Ghiglia and M. D. Pritt, Two-Dimensional Phase Unwrapping:
%    Theory, Algorithms and Software. New York: Wiley-Interscience, 1998.
%
% Inputs: 1. Correlation threshold, e.g. 0.12
%         2. Area to be unwrapped. A single 1 for the entire scene, e.g. unwrap_branchcut(0.12, 1)
%         Else give the area as e.g. 1000:1500 for x and y directions. 
%         e.g. unwrap_branchcut(0.12, 1000:1500, 1000:1500)
%         3. Image input are assumed to be grds from GMTSAR and are converted. [Using a modified version of GRDREAD2 from Kelsey Jordahl]
%                     
% Outputs: Figures: Unwrapped phase image, phase residues, wrapped phase and branch cuts
%          
%
% Redone for use with InSAR (GMTSAR outputs) and octave by Andreas Steinberg, 27.6.2016 
% Unwrapping algorithms by Bruce Spottiswoode on 22 December 2008 (de.mathworks.com/matlabcentral/fileexchange/22504-2d-phase-unwrapping-algorithms)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
warning('off', 'Octave:possible-matlab-short-circuit-operator'); %turn down error uncessary error messages, dont be worried by this. 
warning('off', 'Octave:divide-by-zero ');

%create a nicer divergent colormap

rgb = [ ...
    94    79   162
    50   136   189
   102   194   165
   171   221   164
   230   245   152
   255   255   255
   254   224   139
   253   174    97
   244   109    67
   213    62    79
   158     1    66  ] / 255;





%% REPLACE WITH YOUR IMAGES IF NEEDED


%Create a binary mask from the correlation threshold.
cor(isnan(cor))= 0;
cor(cor <= corr )=0;
cor(cor >=  corr +0.01)=1;
mask= cor;


if area_x == 1
 IM_mask=mask;


%%
IM_mag=abs(ampli)*1000;                             %Magnitude image
IM_phase=(phase);  

else
     IM_mask=mask(area_x,area_y);
%%
IM_mag=abs(ampli(area_x,area_y));                             %Magnitude image
IM_phase=(phase(area_x,area_y));  


end

    

                       %Phase image

%%  Set parameters
max_box_radius=4;                           %Maximum search box radius (pixels)
threshold_std=1;                            %Number of noise standard deviations used for thresholding the magnitude image

%% Unwrap
residue_charge=PhaseResidues(IM_phase, IM_mask);                            %Calculate phase residues
branch_cuts=BranchCuts(residue_charge, max_box_radius, IM_mask);            %Place branch cuts



[IM_unwrapped, rowref, colref]=FloodFill(IM_phase, branch_cuts, IM_mask);   %Flood fill phase unwrapping




%% Display and save results
figure; 

imagesc(residue_charge), colormap(rgb), axis square, axis off, title('Phase residues (charged)');

saveas(gcf,'residue_charge.png')

figure; 
imagesc(branch_cuts), colormap(flipud(gray)), axis square, axis off, title('Branch cuts');
saveas(gcf,'branch_cuts.png')
figure; imagesc(immultiply(IM_phase,IM_mask)), colormap(jet), axis square, axis off, title('Wrapped phase'), h=colorbar('location','eastoutside');; 
saveas(gcf,'wrapped_phase.png') %maybe not necessary
IM_unwrapped = (IM_unwrapped/1000)*5.56;
figure; imagesc(IM_unwrapped), colormap(jet), axis square, axis off, title('Unwrapped phase');

h=colorbar('location','eastoutside');
saveas(gcf,'unwrapped.png')
 
save('unwrapping_branchcut_results.mat','IM_unwrapped','residue_charge','branch_cuts','IM_mask','-mat');
end
