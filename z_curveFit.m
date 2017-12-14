function [ a ] = z_curveFit( X, Y, order)
%UNTITLED 此处显示有关此函数的摘要
%   此处显示详细说明
if length(X) ~= length(Y)
    a = -1;
    disp('invalid input!')
    return
end
A=ones(size(X));
for i = 1:order
    A = [A; X.^i];
end
B = A';
C = A*B;

P=ones(size(X));
for i = 1:order
    P = [P; X.^i];
end
P = P*Y';
a = C\P;
end

