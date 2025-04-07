S = daq.createSession('ni');
N_TURN = 100;
% add a analog output channel
ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao2', 'Voltage'); 
ch_ao0.Range = [-10.0 10.0];

ch_ao1 = addAnalogOutputChannel(S, 'Dev1', 'ao3', 'Voltage'); 
ch_ao1.Range = [-10.0 10.0];

addTriggerConnection(S, 'External', 'Dev1/PFI8', 'StartTrigger');
S.Connections(1).TriggerCondition = 'RisingEdge';

S.Rate = 250; 
% S.IsContinuous = true;
outputData0 = (linspace(-3,3,250))';
outputData1 = (linspace(3,-3,250))';

outputData2 = (linspace(0,0,250))';
outputData3 = (linspace(0,0,250))';
% S.TriggersPerRun = 5;   
S.ExternalTriggerTimeout = 150;
nTrigger = 1;
for i = 1 : N_TURN
    if ~mod(nTrigger, 10)
        queueOutputData(S,[outputData0,outputData1]); 
        S.startForeground();
        nTrigger = nTrigger + 1;
        disp('s1')
    else
        queueOutputData(S,[outputData2,outputData3]); 
        S.startForeground();
        nTrigger = nTrigger + 1;
         disp('s2')
    end

    % lh = addlistener(S,'DataRequired', ...
    % 			@(src,event) src.queueOutputData([outputData0,outputData1]));   
end