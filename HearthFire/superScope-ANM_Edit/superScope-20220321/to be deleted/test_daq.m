% create a data acquisition session
S = daq.createSession('ni');

% add a analog output channel
ch_ao0 = addAnalogOutputChannel(S, 'Dev1', 'ao0', 'Voltage'); 
ch_ao0.Range = [-10.0 10.0];

% setup trigger source
addTriggerConnection(S, 'External', 'Dev1/PFI8', 'StartTrigger');
S.Connections(1).TriggerCondition = 'RisingEdge';
S.Rate = 1000;

% specify output signal
data0 = linspace(-1, 1, 1000)';
lh = addlistener(S,'DataRequired', ...
    @(src,event) src.queueOutputData(data0));

S.IsContinuous = true;
disp('Do it!');
queueOutputData(S, data0);
% for multiple channles, use
% queueOutputData(S, [data0 data1]);

S.startBackground();



