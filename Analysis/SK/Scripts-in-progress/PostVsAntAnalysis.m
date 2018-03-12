%% 
% Define list of cells based on Excel sheet filtering for right protocols and 
% stim-cell dist < 140um. For recordings up to FAT179. This was meant to
% give a similar average cell-stim distance as the posterior cells. Actual
% averages are as follows for the same number of n=13 recordings each:
% anterior X nearCells : 101um
% posterior X allCells : 82um
% Posterior recordings are closer to the cell body than the same number of
% the shortest-distance anterior recordings.

nearCells = {
    'FAT105';
    'FAT106';
    'FAT107';
    'FAT108';
    'SYM001';
    'FAT110';
    'FAT116';
    'FAT119';
    'FAT120';
    'FAT122';
    'FAT124';
    'FAT125';
    'FAT127';
    'FAT128';
    'FAT129';
    'FAT130';
    'FAT131';
    'FAT132';
    'FAT133';
    'FAT134';
    'FAT135';
    'FAT136';
    'FAT137';
    'FAT138';
    'FAT139';
    'FAT140';
    'FAT141';
    'FAT142';
    'FAT143';
    'FAT144';
};
%%
protList ={'WC_Probe';'NoPre'};
matchType = 'first';
strainList = {'TU2769'};
internalList = {'IC6'};
stimPosition = {'posterior'};
wormPrep = {'dissected'};

posteriorCells = FilterRecordings(ephysData, ephysMetaDatabase,...
    'strain', strainList, 'internal', internalList, ...
     'stimLocation', stimPosition, 'wormPrep', wormPrep);

ExcludeSweeps(ephysData, protList, antIC6Cells, 'matchType', matchType);

internalList = {'IC2'};
stimPosition = {'anterior'};

anteriorCells = FilterRecordings(ephysData, ephysMetaDatabase, nearCells,...
    'strain', strainList, 'internal', internalList, ...
     'stimLocation', stimPosition, 'wormPrep', wormPrep);

% ExcludeSweeps(ephysData, protList, posteriorCells, 'matchType', matchType);

clear protList strainList internalList cellTypeList stimPosition matchType ans wormPrep;

%%

protList = {'WC_Probe','NoPre'};
sortSweeps = {'magnitude','magnitude','magnitude','magnitude'};
matchType = 'first';
posteriorMRCs = IdAnalysis(ephysData,protList,posteriorCells,'num','matchType',matchType, ...
    'tauType','thalfmax', 'sortSweepsBy', sortSweeps, 'integrateCurrent',1 , 'sepByStimDistance',1);

antIC6MRCs = IdAnalysis(ephysData,protList,antIC6Cells,'num','matchType',matchType, ...
    'tauType','thalfmax', 'sortSweepsBy', sortSweeps, 'integrateCurrent',1 , 'sepByStimDistance',1);

clear protList sortSweeps matchType

%%
protList ={'WC_Probe8'};
matchType = 'first';
strainList = {'TU2769'};
wormPrep = {'dissected'};
internalList = {'IC6'};
stimPosition = {'anterior'};

anteriorCells = FilterRecordings(ephysData, ephysMetaDatabase,...
    'strain', strainList, 'internal', internalList, ...
     'stimLocation', stimPosition, 'wormPrep', wormPrep);

ExcludeSweeps(ephysData, protList, anteriorCells, 'matchType', matchType);


stimPosition = {'posterior'};

posteriorCells = FilterRecordings(ephysData, ephysMetaDatabase,...
    'strain', strainList, 'internal', internalList, ...
     'stimLocation', stimPosition, 'wormPrep', wormPrep);

ExcludeSweeps(ephysData, protList, posteriorCells, 'matchType', matchType);



protList = {'WC_Probe8'};
sortSweeps = {'magnitude','magnitude','magnitude','magnitude'};
matchType = 'first';
posteriorMRCs = IdAnalysis(ephysData,protList,posteriorCells,'num','matchType',matchType, ...
    'tauType','thalfmax', 'sortSweepsBy', sortSweeps, 'integrateCurrent',1 , 'sepByStimDistance',1);

anteriorMRCs = IdAnalysis(ephysData,protList,anteriorCells,'num','matchType',matchType, ...
    'tauType','thalfmax', 'sortSweepsBy', sortSweeps, 'integrateCurrent',1 , 'sepByStimDistance',1);


clear protList strainList internalList cellTypeList stimPosition matchType ans wormPrep;

clear protList sortSweeps matchType



%%
a = vertcat(anteriorMRCs{:,3});
b = vertcat(posteriorMRCs{:,3});
sizeA = unique(a(:,1));
sizeB = unique(b(:,1));

% %FAT162 and FAT164 have no distance, replaced one with 1 and one with 2 (0
% %makes them non-unique). If checking mean distance, use mean(b(b(:,8)>3,:))
% b(10:11,8) = [1;1];
% b(12:13,8) = [2;2];

% Get rid of posterior recordings that either have no size or were taken
% after moving the stimulator (higher Rs by that point). Only use
% recordings from the initial stimulator location.
b = b(b(:,8)~=0,:);
b = b(b(:,8)~=25.049999999999997,:);
b = b(b(:,8)~=46,:);
b = b(b(:,8)~=90.18,:);
%FAT105 and FAT116 happened to have the same distance, add 0.01
%to one of them to make it easier to use unique.
a(83:90,8)=a(83:90,8)+0.01;

allPosts = nan(length(sizeA),length(unique(b(:,8))));
allAnts = nan(length(sizeA),length(unique(a(:,8))));

[antDists,antStart] = unique(a(:,8),'first');
[~,antEnd] = unique(a(:,8),'last');

[postDists,postStart] = unique(b(:,8),'first');
[~,postEnd] = unique(b(:,8),'last');



%NEXT: use index of distance to assign peaks into matching sizes with ==,
%and then take the whole thing and put into Igor and fit individual
%recordings where possible.
%TODO: redo anterior with *all* eligible recordings, not just near, to have
%a better estimate of the curve

for iAnt = 1:size(allAnts,2)
    thesePeaks = a(antStart(iAnt):antEnd(iAnt),[1 3]);
    for iSize = 1:length(sizeA)
       try allAnts(iSize,iAnt)=thesePeaks(thesePeaks(:,1)==sizeA(iSize),2); 
       catch
       end
    end
end

for iPost = 1:size(allPosts,2)
    thesePeaks = b(postStart(iPost):postEnd(iPost),[1 3]);
    for iSize = 1:length(sizeA)
       try allPosts(iSize,iPost)=thesePeaks(thesePeaks(:,1)==sizeA(iSize),2); 
       catch
       end
    end
end

    