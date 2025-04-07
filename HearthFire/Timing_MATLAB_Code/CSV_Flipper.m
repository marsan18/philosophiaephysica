
[file,path] = uigetfile()
File_Path=strcat(path,file)
A = readmatrix(File_Path);
size(A)
B = transpose(A);
size(B)