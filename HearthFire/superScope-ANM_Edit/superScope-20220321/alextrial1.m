%% 4D Data Fitting Experiments!
% Idea here is to mess around with 4D data fits
x= 1:100;
y = 1:100;
for n=1:100
   for m=1:100
       Z(n,m) = x(n)*y(m);
   end
end
[X,Y] = meshgrid(x,y);
surf(x,y,Z)