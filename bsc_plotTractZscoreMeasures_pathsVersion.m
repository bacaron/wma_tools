function  bsc_plotTractZscoreMeasures_pathsVersion(csvPaths,plotProperties,saveDir)


%workingDir='/N/dc2/projects/lifebid/HCP/Dan/EcogProject/proj-5c33a141836af601cc85858d'
%identifierTag='cleaned'
%plotProperties=[19 20]

mkdir(fullfile(saveDir,'data'));

%csvPaths = tractStatNamesGen(workingDir,identifierTag)

[avgTable, stdTable]=bsc_tableAverages_v3(csvPaths);



%nonNameProperties=propertyNames(2:end);

%onlysubjNames=erase(subjNames,'sub-');

for iplotProperties=1:length(plotProperties)
    if ischar(plotProperties{iplotProperties})
    plotProperties{iplotProperties}=find(strcmp(plotProperties{iplotProperties},propertyNames));
    else
        %probably will error for numbers
        plotProperties{iplotProperties}=plotProperties{iplotProperties}+1;
    end
end

mkdir(fullfile(saveDir,'image/'));

for iplotProperties=1:length(plotProperties)
    leftLabels=[];
    for iDomains=1:length(domainNames)
    leftLabels{iDomains}=[domainNames{iDomains},' (',num2str(avgTable{iDomains,plotProperties{iplotProperties}}),' +/- ',num2str(stdTable{iDomains,plotProperties{iplotProperties}}),')'];
    end
    figure
    %indexing at 2 to squeeze out wbfg, casuses problems otherwise
    plotArray=squeeze(valueArray(:,plotProperties{iplotProperties},:));
    %plotArray(isnan(plotArray))=0;
    minMax=[abs(min(min(min(plotArray,[],'omitnan')))),max(max(max(plotArray,[],'omitnan')))];
    maxOrMin=max(minMax);
    imagesc(plotArray)
    redBlueMap=redblue(99999);
    %hyper inelegant, relies on precision to give you black. In some cases,
    %a value sufficiently close to 0 may appear to be zero, and thus nan on
    %this scale.
    %redBlueMap(50000,:)=[0,0,0];

    colormap(redBlueMap);
    caxis([-maxOrMin maxOrMin])
    colormap(redBlueMap);
    set(gca,'TickLength',[0,0])
    yticks([0:1:length(domainNames)])
    %WHY DO I HAVE TO CIRCULAR SHIFT?
    set(gca,'YTickLabel',circshift(leftLabels,1))
    set(gca,'XTickLabel',[]);
    ax = gca;
    ax.YLabel.String = 'Tracts';
     ax.XLabel.String = 'Subjects';
    ax.Title.String = [propertyNames{plotProperties{iplotProperties}}];
    curMap=colorbar;
    curMap.Label.String = 'Z score';
    figName=[propertyNames{plotProperties{iplotProperties}}];
    
    saveas(gcf,[fullfile(saveDir,'image/'),figName,'.svg']);
end

if ~notDefined(saveDir)
    save([fullfile(saveDir,'data'),'groupZscoreData.mat'],'subjNames','domainNames','propertyNames','valueArray')
end

end