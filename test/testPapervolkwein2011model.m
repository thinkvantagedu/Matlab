clear; clc;
% this script tests paper: Model reduction using proper orthogonal
% Decomposition by S.Volkwein.
n = 5;
% P1, page 2
Y = [1 2 3 4 5; 3 4 2 5 1; 1 3 5 4 2; 2 3 4 1 5; 2 1 4 3 5];
[u, sig, v] = svd(Y, 0);
sigVal = diag(sig);
% first i singular vector.
i = 2;
uPick = u(:, 1:i);
sigPick = sig(1:i, 1:i);
vPick = v(:, 1:i);
YTY = Y' * Y;
[eVecYTY, eValYTY] = eig(YTY); % equals to sig .^ 2.
% lam1 is the largest eigenvalue of YTY.
lamPick = sort(diag(eValYTY), 'descend');
lamPick = lamPick(1:i);

% test 1.7b, test1 = lamPick, therefore ul solves Pl in theorem 1.1, see page 4.
test1 = sum((uPick' * Y)' .^ 2)';

% 
YYT = Y * Y';
[eVecYYT, eValYYT] = eig(YYT);
eValDiag = sort(diag(eValYYT), 'descend');
%% test P1, page 2
u1 = u(:, 3);
P1 = 0;
for i = 1:n
    P1 = P1 + (abs(u1' * Y(:, i))) ^ 2;
end
%% test if projection error equals to truncation error.
% truncation error.
[rb, tError, nrb] = basisCompressionSingularRatio(Y, 0.95);
tError = 1 - tError;
tErrorSVD = 1 - norm(u(:, 1:nrb) * sig(1:nrb, 1:nrb) * v(:, 1:nrb)', 'fro') ...
    / norm(Y, 'fro'); % tError = tErrorSVD.
% projection error: u - \phi\phi^T * u.
pError = norm(Y - u(:, 1:nrb) * (u(:, 1:nrb))' * Y, 'fro');

% SVD error: u - ul * sigl * vlT.
sError = norm(Y - u(:, 1:nrb) * sig(1:nrb, 1:nrb) * v(:, 1:nrb)', 'fro');

% pError = sError.

%% test global-POD and POD, do they result in the same basis?
y1 = Y;
y2 = [8 7 6 5 4; 9 8 7 9 2; 8 7 2 3 6; 8 0 1 7 5; 8 7 6 3 9];
% i. POD
[u1, s1, ~] = svd(y1, 0);
[u2, s2, ~] = svd(y2, 0);
n = 2;
basis = [u1(:, 1:n) u2(:, 1:n)];

% ii. global-POD
[ug, sg, ~] = svd([y1 y2], 0);
