%% Created by Kalin Norman
% April 23, 2020 (Modified version of File from V2VSecurity paper, original
% file created by Bradford Clark

%% Actual File
close all; clear;
SecrecyCapacityApril17; % Run secrecy capacity file to get necessary variables
groupBob = group1alt; % rename 
groupEve = group2alt; % rename
%%
close all; clearvars -except groupBob groupEve closestIdx*; % Isolate the only needed variables
groupBobVars = lower(extractBefore(groupBob, '_'))+extractAfter(groupBob, '_');
groupEveVars = lower(extractBefore(groupEve, '_'))+extractAfter(groupEve, '_');
group1vars = [groupBobVars(1) groupEveVars];
group2vars = [groupBobVars(2) groupEveVars];

thresholdDB = 0;
thresholdLinear = 10^(thresholdDB/10);
firstDecade = 2; % 10^firstDecade
secondDecade = 4; % 10^secondDecade
numSNRs = 100;
snrArray = logspace(firstDecade, secondDecade, numSNRs);

groups = 2;
dataGroup1 = zeros(10, 42, 20459);
dataGroup2 = zeros(10, 42, 16050);
carriersGroup1 = zeros(10, numSNRs, 20459);
carriersGroup2 = zeros(10, numSNRs, 16050);
for i = 1:10
    if i <= 2
        temp1 = squeeze(closestIdxBobData_A_1(i,:,:));
        temp2 = squeeze(closestIdxBobData_A_2(i,:,:));
        dataGroup1(i,:,:) = temp1;
        dataGroup2(i,:,:) = temp2;
    else
        temp1 = squeeze(closestIdxEveData_A_1(i-2,:,:));
        temp2 = squeeze(closestIdxEveData_A_2(i-2,:,:));
        dataGroup1(i,:,:) = temp1;
        dataGroup2(i,:,:) = temp2;
    end
    for j = 1:numSNRs
        carriersGroup1(i,j,:) = CarriersFromThreshold(temp1, snrArray(j), thresholdLinear);
        carriersGroup2(i,j,:) = CarriersFromThreshold(temp2, snrArray(j), thresholdLinear);
    end
        
end

for i = 1:10
    for j = 1:numSNRs
        group1Sums(i,j) = sum(carriersGroup1(i,j,:) == 42);
        group2Sums(i,j) = sum(carriersGroup2(i,j,:) == 42);
        group1AtMax(i,j) = group1Sums(i,j) == 20459;
        group2AtMax(i,j) = group2Sums(i,j) == 16050;
    end
end

for i = 1:10
    if mod(i,2)
        figure(1); hold on
        plot(snrArray, group1Sums(i,:));
        figure(3); hold on
        plot(snrArray, group2Sums(i,:));
    else 
        figure(2); hold on
        plot(snrArray, group1Sums(i,:));
        figure(4); hold on
        plot(snrArray, group2Sums(i,:));
    end
end
figure(1); grid on; legend(group1vars, 'Location', 'southeast'); title('Bob A1 - Empty');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group1AtMax(1,:)), group1Sums(1, group1AtMax(1,:)), 'xk');
figure(2); grid on; legend(group1vars, 'Location', 'southeast'); title('Bob A1 - Traffic');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group1AtMax(2,:)), group1Sums(2, group1AtMax(2,:)), 'xk');
figure(3); grid on; legend(group2vars, 'Location', 'southeast'); title('Bob A2 - Empty');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group2AtMax(1,:)), group2Sums(1, group2AtMax(1,:)), 'xk');
figure(4); grid on; legend(group2vars, 'Location', 'southeast'); title('Bob A2 - Traffic');
ylabel('Number of frames with 42 carriers above the threshold'); xlabel('SNR (linear)');
plot(snrArray(group2AtMax(2,:)), group2Sums(2, group2AtMax(2,:)), 'xk');
            

% snrIndex = 40;
% 
% figure();
% subplot(2,4,1); plot(squeeze(carriersGroup1(1,snrIndex,:)));
% subplot(2,4,5); plot(squeeze(carriersGroup1(3,snrIndex,:)));
% subplot(2,4,6); plot(squeeze(carriersGroup1(5,snrIndex,:)));
% subplot(2,4,7); plot(squeeze(carriersGroup1(7,snrIndex,:)));
% subplot(2,4,8); plot(squeeze(carriersGroup1(9,snrIndex,:)));
% sgtitle('Bob A1, Empty');
% 
% figure();
% subplot(2,4,1); plot(squeeze(carriersGroup1(2,snrIndex,:)));
% subplot(2,4,5); plot(squeeze(carriersGroup1(4,snrIndex,:)));
% subplot(2,4,6); plot(squeeze(carriersGroup1(6,snrIndex,:)));
% subplot(2,4,7); plot(squeeze(carriersGroup1(8,snrIndex,:)));
% subplot(2,4,8); plot(squeeze(carriersGroup1(10,snrIndex,:)));
% sgtitle('Bob A1, Traffic');
% 
% figure();
% subplot(2,4,1); plot(squeeze(carriersGroup2(1,snrIndex,:)));
% subplot(2,4,5); plot(squeeze(carriersGroup2(3,snrIndex,:)));
% subplot(2,4,6); plot(squeeze(carriersGroup2(5,snrIndex,:)));
% subplot(2,4,7); plot(squeeze(carriersGroup2(7,snrIndex,:)));
% subplot(2,4,8); plot(squeeze(carriersGroup2(9,snrIndex,:)));
% sgtitle('Bob A2, Empty');
% 
% figure();
% subplot(2,4,1); plot(squeeze(carriersGroup2(2,snrIndex,:)));
% subplot(2,4,5); plot(squeeze(carriersGroup2(4,snrIndex,:)));
% subplot(2,4,6); plot(squeeze(carriersGroup2(6,snrIndex,:)));
% subplot(2,4,7); plot(squeeze(carriersGroup2(8,snrIndex,:)));
% subplot(2,4,8); plot(squeeze(carriersGroup2(10,snrIndex,:)));
% sgtitle('Bob A2, Traffic');


% syms x;
% 
% for k = 50:50
%     
%     maxNumberOfCarriers = 44;
%     carriersPerLocation = cap_alpha(1:end,k);
%     numberOfSpots = length(carriersPerLocation);
%     
%     %find scale values for Eves and bobs graphs
%     maxPosition = 435.2;
%     scaleEve = double(solve(maxPosition == x * numberOfSpots,x));
%     scaleBob = double(solve(maxPosition == x * numberOfSpots*2,x));
%     midPosition = 229.7;
%     
%     
%     
%     %find RM weights
%     u = 2;
%     m = 5;
%     kBits = 0;
%     for i = 0 : u
%         kBits = kBits + nchoosek(m,i);
%     end
%     RMWeights = RMWeightHier(u,m,false);
%     
%     %set bobs knowledge to maxNumberOfCarriers only if he gets all carriers
%     bobsKnowledge = zeros(numberOfSpots*2);
%     for i = 1:numberOfSpots
%         if carriersPerLocation(i) == maxNumberOfCarriers
%             bobsKnowledge(:,2*i-1:2*i) = maxNumberOfCarriers;
%         else
%             bobsKnowledge(:,2*i-1:2*i) = NaN;
%         end
%     end
%     
%     %find Eves Equivocation matrix
%     EvesEquivocation = zeros(numberOfSpots);
%     
%     for i = 1:numberOfSpots
%         EvesEquivocation(i,:) = RMWeights(1+(carriersPerLocation(i)));
%     end
%     
%     %create axis for graphs
%     [Evey Evex] = size(EvesEquivocation);
%     xaxis = zeros(Evex);
%     yaxis = zeros(Evey);
%     for i = 1:32
%         xaxis(:,i) = i;
%         yaxis(i,:) = i;
%     end
%     
%     %search for cases where bob gets all 32 bits
%     placesBobGetsAll = [];
%     placesBobGetsAll = strfind(bobsKnowledge(1,:),maxNumberOfCarriers)';
%     
%     %find vertices for the hatches
%     countIndex = 1;
%     placesBobGetsAllArea = [];
%     for i = 1:length(placesBobGetsAll)
%         if ((i == 1) &&...
%                 (placesBobGetsAll(i) + 1 == placesBobGetsAll(i+1)))
%             placesBobGetsAllArea(countIndex) = placesBobGetsAll(i);
%             countIndex = countIndex + 1;
%         elseif ((i == length(placesBobGetsAll)) &&...
%                 (placesBobGetsAll(i) - 1 == placesBobGetsAll(i-1)))
%             placesBobGetsAllArea(countIndex) = placesBobGetsAll(i);
%             countIndex = countIndex + 1;
%         elseif (i ~= 1 && i ~= length(placesBobGetsAll)) &&...
%                 xor((placesBobGetsAll(i-1) == placesBobGetsAll(i) - 1),...
%                 (placesBobGetsAll(i+1) == placesBobGetsAll(i) + 1))
%             placesBobGetsAllArea(countIndex) = placesBobGetsAll(i);
%             countIndex = countIndex + 1;
%         end
%         
%     end
%     
%     %% plot Bobs and Eves things
%     figure(100+k);
%     hold on;
%     
%     %create colormap
%     myColorMapScatter = flipud(gray(kBits+1));
%     colormap(myColorMapScatter);
%     
%     %find the xy axis
%     xyaxis = 0:scaleEve:Evex * scaleEve - scaleEve;
%     
%     [minValue,closestIndex] = min(abs(xyaxis-midPosition));
%     closestValue = xyaxis(closestIndex);
%     xyaxis = xyaxis-closestValue;
%     
%     %plot Eves equivocation
%     Eve = pcolor(xyaxis,xyaxis,EvesEquivocation);
%     set(Eve,'EdgeAlpha',0);
%     
%     %create hatch marks for bob
%     for i = 1:2:length(placesBobGetsAllArea)
%         firstSpot = placesBobGetsAllArea(i) * scaleBob - closestValue;
%         secondSpot = placesBobGetsAllArea(i+1) * scaleBob - closestValue;
%         bobPatch1 = patch([firstSpot firstSpot secondSpot secondSpot],...
%             [xyaxis(1) xyaxis(end) xyaxis(end) xyaxis(1)],'white');
%         
%         % Get patch objects from CONTOURGROUP
%         bobHandle = findobj(bobPatch1, 'Type', 'patch');
%         
%         % Apply Hatch Fill
%         bobHatch1 = hatchfill(bobHandle, 'cross', 45, 4);
%         
%         % Remove outline
%         set(bobPatch1, 'LineStyle', 'none');
%         
%         % Change the cross hatch to white
%         set(bobHatch1, 'Color', 'red');
%         
%     end
%     
%     %set the looks for the graphs
%     caxis([0 kBits]);
%     colorBar = colorbar;
%     colorBar.Label.FontSize = 15;
%     colorBar.Label.String = 'Equivocation at Eve (bits/channel use)';
%     xlabel('Bobs Position (m)');
%     ylabel('Eves Position (m)');
% %     title(sprintf('Carriers Below %.0f dB are Bits Coded With RM(%d,5)',10*log10(v2i_snr(k)),u));
%     xlim([-200 200]);
%     ylim([-200 200]);
%     
%     %sets the paper layout
%     cf = gcf;
%     cf.PaperSize = [5 4];
%     cf.PaperPosition = [-.05521 0.2240 -0.5521+5 0.2240+4];
%     
%     hold off;
%     drawnow;
% end