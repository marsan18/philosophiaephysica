function tiffwrite(varargin)
%TIFFWRITE implements the output of matrics or cells array , and storts it in a .tif file;

%usage: tiffwrite(Img_in);
%Author: Bei Liu, 10/19,2009

if nargin==1
    diagbox = 1;%Open standard dialog box for retrieving files
elseif nargin==2
    diagbox = 0;
    filepath = [cd '\'];
    filename = varargin{2};
elseif nargin==3
    diagbox = 0;
    filepath = varargin{2};
    filename = varargin{3};
else
    error('Invalid number of input variables!!!');
end
progressText(0,'Writing images');
if iscell(varargin{1})
    [row col] = size(varargin{1}{1});
    N = length(varargin{1}); 
%     temp = cell2mat(varargin{1});
    clear Img_in
    Img_in = zeros(row,col,N);
    for i=1:N
        Img_in(:,:,i) = varargin{1}{i};
    end
else
    [row col N] = size(varargin{1});    
    Img_in = varargin{1};
end
    

if diagbox==1
    [fileinfo ext usr_cancel] = imputfile;
    if usr_cancel
        msgbox('You canceled the save dialog box!!!')
    else
        for i = 1:N
            imwrite(uint16(Img_in(:,:,i)),[fileinfo(1:end-4) '.' ext],ext,'writemode','append','compression','none');
            progressText(i/N,'Writing images');
        end
    end
else
    fileinfo = [filepath filename];
    for i = 1:N
        imwrite(uint16(Img_in(:,:,i)),[fileinfo(1:end-4) '.tif'],'tif','writemode','append','compression','none');
        progressText(i/N,'Writing images');
    end
end
    