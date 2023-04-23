myFolder= uigetdir();
filePattern = fullfile(myFolder, '*.jpg');
theFiles = dir(filePattern);
[parentFolder deepestFolder] = fileparts(myFolder);
OUTFOLDERIC = sprintf('%s/OUT-IC', myFolder) ;
mkdir(OUTFOLDERIC);
for k = 1 : length(theFiles)
    baseFileName = theFiles(k).name;
    fullFileName = fullfile(theFiles(k).folder, baseFileName);
    [p,f,e] = fileparts(fullFileName);
    OUTFOLDER = sprintf('%s/OUT-%s', myFolder, f) ;
  disp(f);
    

    I = imread(fullFileName);
    imshow(I);  % Display image.
    h = images.roi.Point(gca,'Position',[160 160]);

h.Label = 'Marqueur';
mydlg = warndlg ('Deplacez le marqueur au niveau de la ZAC puis OK', 'Warning');
waitfor(mydlg);
 Pos = h.Position ;
c = Pos(1);
r = Pos(2);
se1 = strel('line',4,0);
se2 = strel('line',4,45);
se3 = strel('line',4,90);
se4 = strel("disk",2,4);   
sth = strel('disk',10);

contrastAdjusted = imadjust(I,[0.1 0.5],[]);
imshow (contrastAdjusted);
BW1 = imbinarize(im2gray(contrastAdjusted));

BW2 = edge(BW1,'canny', 0.2);
imshow (BW2);
BW6 = imdilate(BW2,[se1 se2 se3],'full');
BW11 = imerode(BW6,se4);
BW16 = imcomplement(BW11);
BW21 = bwselect(BW16,c,r);

BW500 = imfill(BW21, 'holes');
BW22 = imresize(BW500, [350 350] );
ROIFILE = OUTFOLDER+"/C-ROI.jpg" ;
imwrite(BW22,ROIFILE);

starea = regionprops(BW22, 'Area').Area / 11377,7777777778 ; 
stperim = regionprops(BW22, 'Perimeter').Perimeter / 106.6666666667 ;
stcirc = regionprops(BW22, 'Circularity').Circularity;
stdiam = regionprops(BW22, 'EquivDiameter').EquivDiameter / 106.6666666667;
stmajor = regionprops(BW22, 'MajorAxisLength').MajorAxisLength/ 106.6666666667;
stminor = regionprops(BW22, 'MinorAxisLength').MinorAxisLength/ 106.6666666667;
storien = regionprops(BW22, 'Orientation').Orientation;
stsol = regionprops(BW22, 'Solidity').Solidity;
stecc = regionprops(BW22, 'Eccentricity').Eccentricity;
[MAXF]= regionprops(BW22, 'MaxFeretProperties');
stmaxfd = MAXF.MaxFeretDiameter / 106.6666666667;
stmaxfa = MAXF.MaxFeretAngle ;
[MINF]= regionprops(BW22, 'MinFeretProperties');
stminfd = MINF.MinFeretDiameter / 106.6666666667 ;
stminfa = MINF.MinFeretAngle;
[CENTR] = regionprops (BW22, 'Centroid');
stcentX = CENTR.Centroid(1);
stcentY = CENTR.Centroid(2);

XLname = 'CANNY-MM72.xlsx';
Labels = {'File', 'C-Area', 'M-Area','C-Perimeter', 'M-Perimeter',...
  'C-Circularity','M-Circularity' , 'C-EquivDiameter', 'M-EquivDiameter',...
  'C-MajorAL', 'M-MajorAL', 'C-MinorAL', 'M-MinorAL','C-Angle', 'M-Angle',...
  'C-Solidity', 'M-Solidity','C-Eccentricity', 'M-Eccentricity',...
  'C-MaxFeretDiameter','M-MaxFeretDiameter','C-MaxFeretAngle',...
  'M-MaxFeretAngle','C-MinFeretDiameter','M-MinFeretDiameter',...
   'C-MinFeretAngle','M-MinFeretAngle','C-CX', 'M-CX','C-CY','M-CY'};

%writecell(Labels,XLname,'Sheet',1,'Range','A1');
%writematrix(f,XLname,'Sheet',1,'Range',sprintf('A%d', k+1));
writematrix(starea,XLname,'Sheet',1,'Range',sprintf('B%d', k+1));
writematrix(stperim,XLname,'Sheet',1,'Range',sprintf('D%d', k+1));
writematrix(stcirc,XLname,'Sheet',1,'Range',sprintf('F%d', k+1));
writematrix(stdiam,XLname,'Sheet',1,'Range',sprintf('H%d', k+1));
writematrix(stmajor,XLname,'Sheet',1,'Range',sprintf('J%d', k+1));
writematrix(stminor,XLname,'Sheet',1,'Range',sprintf('L%d', k+1));
writematrix(storien,XLname,'Sheet',1,'Range',sprintf('N%d', k+1));
writematrix(stsol,XLname,'Sheet',1,'Range',sprintf('P%d', k+1));
writematrix(stecc,XLname,'Sheet',1,'Range',sprintf('R%d', k+1));
writematrix(stmaxfd,XLname,'Sheet',1,'Range',sprintf('T%d', k+1));
writematrix(stmaxfa,XLname,'Sheet',1,'Range',sprintf('V%d', k+1));
writematrix(stminfd,XLname,'Sheet',1,'Range',sprintf('X%d', k+1));
writematrix(stminfa,XLname,'Sheet',1,'Range',sprintf('Z%d', k+1));
writematrix(stcentX,XLname,'Sheet',1,'Range',sprintf('AB%d', k+1));
writematrix(stcentY,XLname,'Sheet',1,'Range',sprintf('AD%d', k+1));



matfile = OUTFOLDER+"/cannyroi.mat" ;


[B] = bwboundaries(BW22,'noholes');
boundariesroi = B{1,1};
  save(matfile,"boundariesroi");
D = 15; %decalage factor
imshow(I);
hold on
for k = 1:length(B)
   boundary = B{k};
   plot(boundary(:,2)-D, boundary(:,1)-D, 'r', 'LineWidth', 1)
end
iptsetpref ('ImshowBorder','tight');
BOUNDFILE = OUTFOLDER+"/ICBOUND.jpg" ;
BOUNDFILE2 = OUTFOLDERIC+"/"+f+"-ICBOUND.jpg" ;
saveas(gcf, BOUNDFILE);
saveas(gcf, BOUNDFILE2);
XB = (boundary(:,2)-D);
YB = (boundary(:,1)-D);
%ROI1 = roipoly (I,XB, YB);
patch (XB,YB,'green');
FILLFILE = OUTFOLDER+"/ICFILL.jpg";
FILLFILE2 = OUTFOLDERIC+"/"+f+"-ICFILL.jpg" ;
saveas(gca,FILLFILE);
saveas(gca,FILLFILE2);
    drawnow; % Force display to update immediately.
end













