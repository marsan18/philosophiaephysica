function [CenterPoint,EquiProb,TotStepsCount] = VanHoveEquiBin(VanHove, TimeSteps, BinSize, MinBin)
arguments
    VanHove {iscell}
    TimeSteps{isrow}
    BinSize{isscalar}
    MinBin {isscalar} = 0.001 %in microns!
end
% This function sorts datapoints into bins with approximately equal numbers
% of datapoints in them, and computes the probability by normalizing the
% number of particles/width of the bin. Sometimes, if there is duplicate
% data, they are clumped in one bin. It attempts to avoid issues with large
% number of identical data steps (especially 0) by refusing to create a new
% bin until the bin has non-zero width.

% Provide a valid VanHove Distribution by running the VanHove function.
% time_steps is a row vector which indicates the tau value we want to use.
% Ensure you use the same time steps as you did when generating VanHove.
% BinSize is an integer which checks that for tau=time_steps
%     if VanHove{tau}==[]
%         error('VanHove has no cell for some values of tau. Please ensure
%         your time steps are consistent and your VanHove matrix is
%         valid.')
%     end
% end


if not(floor(BinSize)==BinSize && size(BinSize,1)==1 && size(BinSize,2)==1)
    error('Please input an integer for BinSize')
end

%% Equal bin sorting 
% Logarithmic sorting doesn't seem amazing...so let's do equal bin sorting.
%VHBinSize Sets number of particles per division
% there is a strange rounding error that causes many bins to get rounded to
% (0,0) which causes a huge probability spike at that point. This is due to
% that fact that many, many points actually have probability 0 and they all
% get stuck into a single bin during sorting. Note HISTCOUNTS pushes stuff
% on the boundary UP!
var=1; % select 1 for x or 2 for y

%% Preallocation
SortedVanHove=VanHove; % These should be the same size

BiggestTau = max(TimeSteps);

% Preallocating all tau-dependent cell arrays
EquiDomain=zeros(length(VanHove),1);
EquiBins=cell(BiggestTau,1);
TotStepsCount=cell(BiggestTau,1);
EquiWidth=cell(BiggestTau,1);
EquiProb=cell(BiggestTau,1);
CenterPoint=cell(BiggestTau,1);
CountCheck=cell(BiggestTau,1);
Binz=cell(BiggestTau,1);

for tau=TimeSteps
%% Sorting data    
    fprintf(['Sorting dt=', num2str(tau), ' into bins \n'])

    SortedVanHove{tau}(:,var) = sort(VanHove{tau}(:,var));
    EquiDomain(tau,1)=SortedVanHove{tau}(end,var)-SortedVanHove{tau}(1,var);

    % Set the bottom of the first bin to the lowest value.
    EquiBins{tau}=SortedVanHove{tau}(1,var);
    
    TotStepsCount{tau}=length(SortedVanHove{tau});
    
   
    
    %% EquiBin Creation
    % Every nth bin (n=BinSize), we check to see if we may make a new bin
    % marker. If a bin is narrower than the threshold allows, it cannot
    % start a new bin. Instead, the OverFlow flag is set to true. While
    % OverFlow is true, MATLAB checks the witdth of the would-be bin for
    % every subsequent dx. This continues until a velocity is far enough
    % from the precedent bin that the width exceeds the minimum theashold,
    % which allows for the createion of a new bin and the resetting of the
    % OverFlow condition back to false.
    OverFlow=false; 
    for k=1:TotStepsCount{tau}
        if  OverFlow || mod(k,BinSize)==0  
            % short circuit OR, doesn't evaluate second option if first is
            % true. Add OverFlow in order to test every single particle,
            % rather than every BinSize particles. In the future we should
            % test this with a minimum width threshold
            BinStart=SortedVanHove{tau}(k,1); %k+1 or k? I think k.
            % Try to fix the 0 width bin problem by marking a new bin iff
            % there is a non-zero Bin Size
            if not(abs(BinStart-EquiBins{tau}(end,end))<MinBin) 
                % Not too close to the last bin? go ahead
                EquiBins{tau}=[EquiBins{tau};BinStart];
                OverFlow=false;
            else 
                % if we are too close (within the threshold), activate
                % OverFlow ZeroBins=ZeroBins+1; display(ZeroBins)
                OverFlow=true;
            end
        end
    end
    BottomBorder=[SortedVanHove{tau}(end,1)];
    EquiBins{tau}=[EquiBins{tau};BottomBorder];
    % EquiBins{tau} is finalized now
     
    EquiWidth{tau}=diff(EquiBins{tau}); 
    % Gives the width of each of the EquiBins Note the widths are NOT
    % equal, in spite of the name
    
    [CountCheck{tau}, ~, Binz{tau}]=histcounts(SortedVanHove{tau}(:,var),EquiBins{tau});
    % Binz is the same size and order as SortedVanHove and contains the bin
    % placement value for each particle. Since Binz is produced by sorting
    % SortedVanHove, the bins are always sequential.
    
    CountCheck{tau}=[CountCheck{tau}]'; 
    
    if not(sum(CountCheck{tau}) == TotStepsCount{tau})
        % If we don't have the same number of particles we started with, we
        % have a big problem!
        error('VanHove Particle Sorting Error: Not all particles were sorted into a bin!')
    end

    % Nota Bene Sometimes bins are a bit off--end up with target +/- 1 in a
    % bin. This occurs due to them having the exact same localization.
    % Happens most frequently around 0. To ensure accuracy, we must
    % therefore check the number of particles in each bin.

    EquiProb{tau}=CountCheck{tau}./EquiWidth{tau};
    EquiProb{tau}=EquiProb{tau}.*(1/sum(EquiProb{tau}, 'omitnan'));
    PastBin=1;
    
    % Now we make a list of the coordinates in each bin
    
    startcoord = 1; % start at the beginning of course

    for k=1:length(Binz{tau})
        CurrentBin = Binz{tau}(k,1);
        if PastBin==CurrentBin 
            % If our Bin remains the same and we are not on the last tick
            % add the current particle to our list of particles in the bin.
            
           % We can probably just have this follow the loop rather... if
           % k==length(Binz{tau}) %     % FOR THE FINAL BIN ONLY: %     %
           % Set the end of the bin to the final k value and find the % %
           % average of the undersized bin
           %     endcoord = k;
           % 
           % end
        else
            % THE BIN MUST END AT THE PRIOR PARTICLE!
            endcoord = k-1; 

            % Compute the mean position for the current bin.
            CenterPoint{tau}(PastBin)=mean(SortedVanHove{tau}(startcoord:endcoord,1));
            
            % AFTER COMPUTING THE CENTERPOINT, START A NEW BIN!
            startcoord = k;    
        end
        PastBin=CurrentBin;
    end
    % for the last bin, we never define an end coordiante, so just run it
    % from the last start coordiante to the end.
    CenterPoint{tau}(PastBin)=mean(SortedVanHove{tau}(startcoord:end,1));
    if isnan(EquiProb{tau}(end))
        % If the final bin has only a single entry, it will have 0 width.
        % This means that it will have infinite probability.
        warning(strcat("NaN error detected on the last bin! Final bin for", string(tau), "discarded!"))
        CenterPoint{tau}=CenterPoint{tau}(1:(end-1));
        EquiProb{tau}=EquiProb{tau}(1:(end-1));
    end
end