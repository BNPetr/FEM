clear all

% Ньютоны и метры.
% H = sym("H", "positive");
% m = sym("m", "positive");
H = 1;
m = 1;

% Модуль упругости материала.
E = 0.71e+11 * H / m^2;
% Размеры сечения.
a = 0.03;
b = 0.03;
% Площадь сечения.
F = a * b;
% Момент инерции сечения для оси z.
Iz = a * a ^ 3 / 12;
% Размеры балок.
L1 = 1 * m;
L2 = 1.5 * m;
L3 = sqrt(L1^2 + L2^2);
% Матрица жесткости элемента.
syms EF L EI
K = [[ EF/L,            0,           0, -EF/L,            0,           0];
     [    0,  (12*EI)/L^3,  (6*EI)/L^2,     0, -(12*EI)/L^3,  (6*EI)/L^2];
     [    0,   (6*EI)/L^2,    (4*EI)/L,     0,  -(6*EI)/L^2,    (2*EI)/L];
     [-EF/L,            0,           0,  EF/L,            0,           0];
     [    0, -(12*EI)/L^3, -(6*EI)/L^2,     0,  (12*EI)/L^3, -(6*EI)/L^2];
     [    0,   (6*EI)/L^2,    (2*EI)/L,     0,  -(6*EI)/L^2,    (4*EI)/L]];
% Матрицы жесткости элементов в их локальных системах координат.
K1 = subs(K, [EF, EI, L], [E * F, E * Iz, L1]);
K2 = subs(K, [EF, EI, L], [E * F, E * Iz, L2]);
K3 = subs(K, [EF, EI, L], [E * F, E * Iz, L3]);
% Матрица поворота вокруг оси z.
syms COS SIN
Tz = [[  COS, -SIN,    0,    0,    0,    0];
      [  SIN,  COS,    0,    0,    0,    0];
      [    0,    0,    1,    0,    0,    0];
      [    0,    0,    0,  COS, -SIN,    0];
      [    0,    0,    0,  SIN,  COS,    0];
      [    0,    0,    0,    0,    0,    1]];

T1 = subs(Tz, [COS, SIN], [1, 0]);
T2 = subs(Tz, [COS, SIN], [0, 1]);
T3 = subs(Tz, [COS, SIN], [L1 / L3, -L2 / L3]);
% Перевод матриц жесткости элементов в глобальную систему координат.
K1 = T1 * K1 * T1.';
K2 = T2 * K2 * T2.';
K3 = T3 * K3 * T3.';
% Объединение матриц жесткости в одну, пустые места заполняются нулями.
Z = zeros(6);
Kl = [
    horzcat(K1,  Z,  Z);
    horzcat( Z, K2,  Z);
    horzcat( Z,  Z, K3);
];
% Построение матрицы связей.
Z = zeros(3);
O = eye(3);
A = [ % Общие узлы  1  2  3
            horzcat(O, Z, Z); % Элемент 1, узел 1.
            horzcat(Z, O, Z); % Элемент 1, узел 2.
            horzcat(O, Z, Z); % Элемент 2, узел 1.
            horzcat(Z, Z, O); % Элемент 2, узел 2.
            horzcat(Z, O, Z); % Элемент 3, узел 1.
            horzcat(Z, Z, O); % Элемент 3, узел 2.
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
result = solve(Sys, [Rx1, Ry1, rz1, tx2, ty2, rz2, Rx3, ty3, rz3]);

Rx1 = double(result.Rx1)
Ry1 = double(result.Ry1)
rz1 = double(result.rz1)
tx2 = double(result.tx2)
ty2 = double(result.ty2)
rz2 = double(result.rz2)
Rx3 = double(result.Rx3)
ty3 = double(result.ty3)
rz3 = double(result.rz3)
