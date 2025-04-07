%% README
% This code performs the calculations specified in the paper by Qu, Hu.
%% Declaring Variables
syms I IP I1P I2P z FO FE D1 FR MO
assume(I,{'positive', 'real', 'rational'})
assume(IP,{'positive', 'real', 'rational'})
assume(I1P,{'positive', 'real', 'rational'})
assume(I2P,{'positive', 'real', 'rational'})
assume(z,{'real', 'rational'}')
assume(FO,{'positive', 'real', 'rational'})
assume(FE, {'positive', 'real', 'rational'})
assume(FR, {'positive', 'real', 'rational'})
%% Calculation For BFP Remote focusing
eq1 = 1/I + 1/IP == 1/FO;
eq2 = 1/(I-z) + 1/I1P == 1/FO;
eq3 = 1/(FO-I1P) + 1/I2P == 1/FE;
eq4 = IP - I2P ==  FO;
sol_dZ = solve([eq1, eq2, eq3, eq4])
dz=sol_dZ.z;
display(dz)
% Solving for M1
M1 = simplify((solve(eq1, IP))/I)
% Solving for M2
% M2 = (eq2/eq3);
% isolate(M2, ((I-z)/FO)*I2P/I1P) %dist obj/dist image = I-z/I1 * I1/I2 = I-z/I2
%% Calculation For Relay Lenses Remote Focusing
eq10 = 1/I + 1/IP == 1/FO;
eq12 = FR-FR^2*(FO-I)/(FO^2)==I2P + FE;
eq15 = 1/(I-z)+1/(I1P) == 1/FO;
eq16 = 1/(IP + FR - I1P) + 1/I2P == 1/FR;
sol_dZ2 = solve([eq10,eq12, eq15, eq16])
dZ2_simple= simplify(subs(sol_dZ2.z, ((FO-I)/FO)^2, MO^2))