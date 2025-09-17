clear all

% Ньютоны и метры.
% syms H m
H = 1;
m = 1;

% Свойства материала
E = 0.71e+11 * H / m^2;
v = 0.23;
% Размеры и свойства сечений.
a = 0.03 * m;
b = 0.03 * m;
A = a * b;
Iz = a * a ^ 3 / 12;
% Размеры балок.
L1 = 1 * m;
L2 = 1.5 * m;
% Матрица жесткости элемента.
syms EF L EI
K = [[ EF/L,            0,           0, -EF/L,            0,           0];
     [    0,  (12*EI)/L^3,  (6*EI)/L^2,     0, -(12*EI)/L^3,  (6*EI)/L^2];
     [    0,   (6*EI)/L^2,    (4*EI)/L,     0,  -(6*EI)/L^2,    (2*EI)/L];
     [-EF/L,            0,           0,  EF/L,            0,           0];
     [    0, -(12*EI)/L^3, -(6*EI)/L^2,     0,  (12*EI)/L^3, -(6*EI)/L^2];
     [    0,   (6*EI)/L^2,    (2*EI)/L,     0,  -(6*EI)/L^2,    (4*EI)/L]];
% Матрицы жесткости элементов в локальной системе координат.
K1 = subs(K, [EF, EI, L], [E * A, E * Iz, L1]);
K2 = subs(K, [EF, EI, L], [E * A, E * Iz, L2]);
hyp = sqrt(L1^2 + L2^2);
K3 = subs(K, [EF, EI, L], [E * A, E * Iz, hyp]);
% Матрица поворота.
syms COS SIN
Tz = [[  COS, -SIN,    0,    0,    0,    0];
      [  SIN,  COS,    0,    0,    0,    0];
      [    0,    0,    1,    0,    0,    0];
      [    0,    0,    0,  COS, -SIN,    0];
      [    0,    0,    0,  SIN,  COS,    0];
      [    0,    0,    0,    0,    0,    1]];

T1 = subs(Tz, [COS, SIN], [1, 0]);
T2 = subs(Tz, [COS, SIN], [0, 1]);
T3 = subs(Tz, [COS, SIN], [L1 / hyp, -L2 / hyp]);
% Матрицы жесткости элементов в глобальной системе координат.
K1 = T1 * K1 * T1.';
K2 = T2 * K2 * T2.';
K3 = T3 * K3 * T3.';
% Объединение матриц жесткости в одну.
Z = zeros(6);
Kl = [
    horzcat(horzcat(K1,  Z),  Z);
    horzcat(horzcat( Z, K2),  Z);
    horzcat(horzcat( Z,  Z), K3);
];
% Объединение совпадающих узлов.
Z = zeros(3);
O = eye(3);
A = [ % Общие узлы  1  2   3
    horzcat(horzcat(O, Z), Z); % Элемент 1, узел 1.
    horzcat(horzcat(Z, O), Z); % Элемент 1, узел 2.
    horzcat(horzcat(O, Z), Z); % Элемент 2, узел 1.
    horzcat(horzcat(Z, Z), O); % Элемент 2, узел 2.
    horzcat(horzcat(Z, O), Z); % Элемент 3, узел 1.
    horzcat(horzcat(Z, Z), O); % Элемент 3, узел 2.
    ];
% Глобальная матрица жесткости.
Kglobal = A.' * Kl * A;
% Нагрузки и закрепления (граничные условия).
syms Rx1 Ry1 Mz1 Rx2 Ry2 Mz2 Rx3 Ry3 Mz3 
syms tx1 ty1 rz1 tx2 ty2 rz2 tx3 ty3 rz3

F = [Rx1, Ry1, Mz1, Rx2, Ry2, Mz2, Rx3, Ry3, Mz3].';
U = [tx1, ty1, rz1, tx2, ty2, rz2, tx3, ty3, rz3].';

F = subs(F, [Mz1, Rx2, Ry2, Mz2, Ry3, Mz3], [0, 0, -1000 * H, 0, 0, 0]);
U = subs(U, [tx1, ty1, tx3], [0, 0, 0]);
% Система уравнений.
Sys = Kglobal * U - F;
res = solve(Sys, [Rx1, Ry1, rz1, tx2, ty2, rz2, Rx3, ty3, rz3]);

Rx1 = double(res.Rx1)
Ry1 = double(res.Ry1)
rz1 = double(res.rz1)
tx2 = double(res.tx2)
ty2 = double(res.ty2)
rz2 = double(res.rz2)
Rx3 = double(res.Rx3)
ty3 = double(res.ty3)
rz3 = double(res.rz3)
