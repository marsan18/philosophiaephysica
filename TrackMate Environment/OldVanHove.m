function [VanHoveOut] = VanHove(InputTrack, TimeSteps, BinSize)
%% Van Hove plots
% Preallocation!

% Without accounting for step size, the Max Size of Each VanHove Cell is 
% approximately the number of tracks times the maximum length of each track
InputLength=length(InputTrack{end});
NumTracks = length(InputTrack);
InputLength*NumTracks

% plot probability of each step size.
if max(TimeSteps)>= length(InputTrack{end})
    error('Please select a set of timesteps for the Van Hove Plot which are less than the length of the longest path.')
end

for i=TimeSteps 
    % create a cell struct with one cell for each tau value
% Make sure this is outside loop or it will erase the VanHove matrix with 
% each iteration
 VanHoveOut{i}=[]; %zeros(length(MobileTrack{end},4)); %preallocates VanHove to be as large as biggest MobileTrack dataset
end

for track=1:length(InputTrack)
    fprintf('Assembling VanHove')
    display(track)
    % Moves through every track in VHTracks
    for tau = TimeSteps 
        % Change this to change number of frames for each distribution.
        BackStop=length(InputTrack{track})-tau;
        if BackStop > 1 && tau<length(InputTrack{track})
            % This condition works to avoid indexing errors which result
            % when tau is bigger than the number of particles in the track
            for t=1:BackStop 
                % This rosters through each position in the track 
                for dt=1:tau 
                    % accomodates frame skips--checks frame step values
                    % from 1 up to tau to see if Δt=τ
                    if InputTrack{track}(t+dt,1) - InputTrack{track}(t,1) == tau 
                       % if the Δt is tau...
                       Dx = InputTrack{track}(t+dt,2)- InputTrack{track}(t,2); % write dΧ
                       Dy = InputTrack{track}(t+dt,3) - InputTrack{track}(t,3); % write dY
                       VanHoveOut{tau}=vertcat(VanHoveOut{tau},[Dx,Dy,track,t]); % records ΔΧ, ΔY, tracj number, AND start frame number
                       % Considering we have track and frame, all steps are
                       % fully tracable
                    end
                end
            end
        end
        % fprintf('for τ=%d ',tau)
        % fprintf('found %d steps for in the file.\n', length(VHTrack{frame}))
    end
end

% Trim VanHove after Preallocation!
% Trim zeroes off end of VanHove
    % 
    % for tau=time_steps
    % for i=length(VanHove{tau})
    %     if sum(VanHove{Tau}(i,:))==0
    %        VanHove{tau}(i:end,:)=[]
    %        break
    %     end
    % end
    % end

% Now we need to change from steps into Probabilities


%% Logarithmic sorting
% edgesPos=[-Inf,-5.5,-5, -4.5, -4,-3.5:0.1:log(2)];
% edgesNeg=-flip(edgesPos);
% % column 1 is x, column 2 is y, column 3 indicates if we should keep row
% for var=1
%     for tau=time_steps
%         fprintf('Log Sorting')
%         display(tau)
%         for k=1:length(VanHove{tau})
%             if VanHove{tau}(k,var)>0
%                 % should convert imaginary numbers resulting from log(negatives) to real negative numbers
%                 PosLogVanHove{tau}(k,var)=reallog(VanHove{tau}(k,var));
%                 PosLogVanHove{tau}(k,3)=1; % keep
%                 NegLogVanHove{tau}(k,var)=0;
%                 NegLogVanHove{tau}(k,3)=0; % throw out
%             else
%                 % record negative log value, throw out postive log value
%                 NegLogVanHove{tau}(k,var)=-reallog(-VanHove{tau}(k,var));
%                 NegLogVanHove{tau}(k,3)=1; % keep
%                 PosLogVanHove{tau}(k,var)=0;
%                 PosLogVanHove{tau}(k,3)=0; % throw out
%             end
%         end
%         FilterPosLogVanHove{tau}=[];
%         FilterNegLogVanHove{tau}=[];
%         for j=1:length(VanHove{tau})
%             if NegLogVanHove{tau}(j,3)==0 && PosLogVanHove{tau}(j,3)==1
%                 FilterPosLogVanHove{tau}=vertcat(FilterPosLogVanHove{tau},PosLogVanHove{tau}(j,1));
%             else
%                 FilterNegLogVanHove{tau}=vertcat(FilterNegLogVanHove{tau},NegLogVanHove{tau}(j,1));
%             end
% 
% 
%         end
%         NegPVanHove{tau}(:,var) = histcounts( FilterNegLogVanHove{tau},edgesNeg)/length(VanHove{tau});
%         PosPVanHove{tau}(:,var) = histcounts(FilterPosLogVanHove{tau},edgesPos)/length(VanHove{tau});
%         PVanHove{tau}(:,var)=vertcat(NegPVanHove{tau}(:,var), PosPVanHove{tau}(:,var));
%      end
% end