%% Solving for Delta Z
syms I IP I1P I2P z FO FE
assume(I,{'positive', 'real', 'rational'})
assume(I~=0)
assume(IP,{'positive', 'real', 'rational'})
assume(IP~=0)
assume(I1P,{'positive', 'real', 'rational'})
assume(I1P~=0)
assume(I2P,{'positive', 'real', 'rational'})
assume(I2P~=0)
assume(z,{'real', 'rational'}')
assume(FO,{'positive', 'real', 'rational'})
assume(FO~=0)
assume(FE, {'positive', 'real', 'rational'})
assume(FE~=0)
eq1 = 1/I + 1/IP == 1/FO;
eq2 = 1/(I-z) + 1/I1P == 1/FO;
eq3 = 1/(FO-I1P) + 1/I2P == 1/FE;
eq4 = IP - I2P ==  FO;
sol_dZ = solve([eq1, eq2, eq3, eq4],z)
% Solving for M1
M1 = simplify((solve(eq1, IP))/I) %Solves for I' and then divides by I to get magnification = I'/I
% Solving for M2--can't figure out what they did
M2 = eq2/eq3

