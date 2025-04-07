nFrames = 441;

NET.addAssembly('C:\Program Files\Thorlabs\Scientific Imaging\DCx Camera Support\Develop\DotNet\uc480DotNet.dll');

% create camera object handle
cam = uc480.Camera;

cam.Init(0);

cam.Display.Mode.Set(uc480.Defines.DisplayMode.DiB);

cam.PixelFormat.Set(uc480.Defines.ColorMode.Mono8);

cam.Trigger.Set(uc480.Defines.TriggerMode.Software);

[status, MemID] = cam.Memory.Allocate(true);
[~, Width, Height, Bits, ~] = cam.Memory.Inquire(MemID);


%% set up NI
S = daq.createSession('ni');
if ~isempty(S.Channels)
    removeChannel(S,1:length(S.Channels));
end
 % add a analog output channel
ch_ao0 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao0', 'Voltage'); 
ch_ao0.Range = [-10.0 10.0];

ch_ao1 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao1', 'Voltage'); 
ch_ao1.Range = [-10.0 10.0];

% add a analog output channel
ch_ao2 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao2', 'Voltage'); 
ch_ao2.Range = [-10.0 10.0];

ch_ao3 = addAnalogOutputChannel(S, 'cDAQ1Mod1', 'ao3', 'Voltage'); 
ch_ao3.Range = [-10.0 10.0];

data = [0 0 0 0];
outputSingleScan(S, data); %% RESET

%%
imgData = zeros(Height, Width, nFrames, 'uint8');
iImg = 1;
for iVolt = 10 : -1 : -10
    for jVolt = -10 : 1 : 10
    
        data = [iVolt jVolt 0 0];

        outputSingleScan(S, data); 

%         acStatus = cam.Acquisition.Freeze(uc480.Defines.DeviceParameter.Wait);
        acStatus = cam.Acquisition.Freeze(50);
        [~, tmp] = cam.Memory.CopyToArray(MemID);

        tem_img = reshape(uint8(tmp), Height, Width);

        imgData(:, :, iImg) = tem_img;
        iImg = iImg + 1;
        %himg = imshow(data);
        disp([iVolt jVolt]);
    end
end
cam.Exit;

filename = 'D:\Bei\scan_tirf.tif';
for i = 1 : size(imgData, 3)
    imwrite(imgData(:,  :, i), filename, 'tif', 'writemode', 'append', 'compression', 'none');
end