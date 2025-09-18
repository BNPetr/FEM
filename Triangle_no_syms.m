clear all

% Модуль упругости материала.
E = 0.71e+11;
% Размеры сечения.
a = 0.03;
b = 0.03;
% Площадь сечения.
F = a * b;
% Момент инерции сечения для оси z.
Iz = a * a ^ 3 / 12;
% Размеры балок.
L1 = 1;
L2 = 1.5;
L3 = sqrt(L1^2 + L2^2);
% Матрица жесткости элемента.
K1 = Stiffness_matrix(E * F, E * Iz, L1);
K2 = Stiffness_matrix(E * F, E * Iz, L2);
K3 = Stiffness_matrix(E * F, E * Iz, L3);
% Матрицы поворота.
T1 = Rotation_matrix(1, 0);
T2 = Rotation_matrix(0, 1);
T3 = Rotation_matrix(L1 / L3, -L2 / L3);
% Перевод матриц жесткости элементов в глобальную систему координат.
K1 = T1 * K1 * T1.';
K2 = T2 * K2 * T2.';
K3 = T3 * K3 * T3.';
% Объединение матриц жесткости в одну, пустые места заполняются нулями.
Z = zeros(6);
Kl = [
    horzcat(horzcat(K1,  Z),  Z);
    horzcat(horzcat( Z, K2),  Z);
    horzcat(horzcat( Z,  Z), K3);
];
% Построение матрицы соединений.
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
% NaN - используется для обозначения неизвестных.
%   [Rx1, Ry1, Mz1, Rx2, Ry2, Mz2, Rx3, Ry3, Mz3] - усилия в узлах.
F = [NaN, NaN,   0,  0,-1000,   0, NaN,   0,   0]; 
%   [tx1, ty1, rz1, tx2, ty2, rz2, tx3, ty3, rz3] - перемещения узлов.
U = [  0,   0, NaN, NaN, NaN, NaN,   0, NaN, NaN]; 
% Индексы неизвестных усилий.
F_unknown = find(isnan(F));
% Индексы известных перемещений.
U_known = F_unknown;
% Выделение коэффициентов при неизвестных в отдельную матрицу.
A = Kglobal;
A(:, F_unknown) = 0;
for i = 1:length(F_unknown)
    A(F_unknown(i), F_unknown(i)) = -1;
end
% Выделение известных величин в отдельную матрицу.
B = F;
B(U_known) = U(U_known);
% Решение системы уравнений.
result = linsolve(A, B.');
Rx1 = result(1)
Ry1 = result(2)
rz1 = result(3)
tx2 = result(4)
ty2 = result(5)
rz2 = result(6)
Rx3 = result(7)
ty3 = result(8)
rz3 = result(9)

% Матрица жесткости элемента.
function K = Stiffness_matrix(EF, EI, L)
    K = [[ EF/L,            0,           0, -EF/L,            0,           0];
         [    0,  (12*EI)/L^3,  (6*EI)/L^2,     0, -(12*EI)/L^3,  (6*EI)/L^2];
         [    0,   (6*EI)/L^2,    (4*EI)/L,     0,  -(6*EI)/L^2,    (2*EI)/L];
         [-EF/L,            0,           0,  EF/L,            0,           0];
         [    0, -(12*EI)/L^3, -(6*EI)/L^2,     0,  (12*EI)/L^3, -(6*EI)/L^2];
         [    0,   (6*EI)/L^2,    (2*EI)/L,     0,  -(6*EI)/L^2,    (4*EI)/L]];
end

% Матрица поворота вокруг оси z.
function Tz = Rotation_matrix(COS, SIN)
    Tz = [[  COS, -SIN,    0,    0,    0,    0];
          [  SIN,  COS,    0,    0,    0,    0];
          [    0,    0,    1,    0,    0,    0];
          [    0,    0,    0,  COS, -SIN,    0];
          [    0,    0,    0,  SIN,  COS,    0];
          [    0,    0,    0,    0,    0,    1]];
end
