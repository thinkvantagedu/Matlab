clear; clc; clf;
oripath = '~/Desktop/Temp/thesisResults/27052018_1516_GreedyProcedure';

load(strcat(oripath, '/greedy/errGreedy.mat'), 'errGreedy');
load(strcat(oripath, '/pseudorandom/errRandom1.mat'), 'errRandom1');
load(strcat(oripath, '/pseudorandom/errRandom2.mat'), 'errRandom2');
load(strcat(oripath, '/pseudorandom/errRandom3.mat'), 'errRandom3');
load(strcat(oripath, '/pseudorandom/errRandom4.mat'), 'errRandom4');
load(strcat(oripath, '/pseudorandom/errRandom5.mat'), 'errRandom5');
load(strcat(oripath, '/structure/errStruct.mat'), 'errStruct');
load(strcat(oripath, '/sobol/errSobol.mat'), 'errSobol');
load(strcat(oripath, '/latin/errLatin1.mat'), 'errLatin1');
load(strcat(oripath, '/latin/errLatin2.mat'), 'errLatin2');
load(strcat(oripath, '/latin/errLatin3.mat'), 'errLatin3');
load(strcat(oripath, '/latin/errLatin4.mat'), 'errLatin4');
load(strcat(oripath, '/latin/errLatin5.mat'), 'errLatin5');

errx = 1:10;
errOriMax = errGreedy.store.max;
errRanMax1 = errRandom1.store.max;
errRanMax2 = errRandom2.store.max;
errRanMax3 = errRandom3.store.max;
errRanMax4 = errRandom4.store.max;
errRanMax5 = errRandom5.store.max;
errStrMax = errStruct.store.max;
errSobolMax = errSobol.store.max;
errLatinMax1 = errLatin1.store.max;
errLatinMax2 = errLatin2.store.max;
errLatinMax3 = errLatin3.store.max;
errLatinMax4 = errLatin4.store.max;
errLatinMax5 = errLatin5.store.max;
%%
% greedy vs random.
figure(1)
h1 = semilogy(errx, errOriMax, 'b-o', 'MarkerSize', 10, 'lineWidth', 3);
hold on;
h2 = semilogy(errx, errRanMax1, 'k-.', 'lineWidth', 1.5);
semilogy(errx, errRanMax2, 'k-.', 'lineWidth', 1.5);
semilogy(errx, errRanMax3, 'k-.', 'lineWidth', 1.5);
semilogy(errx, errRanMax4, 'k-.', 'lineWidth', 1.5);
semilogy(errx, errRanMax5, 'k-.', 'lineWidth', 1.5);
legend([h1, h2], {'Greedy', 'Pseudorandom'});
set(gca, 'YScale', 'log')
xticks(errx);
axis([0 errx(end) + 1 errOriMax(end) errOriMax(1)]);
grid on
xlabel('N');
ylabel('Maximum relative error');
set(gca,'fontsize',20)
%%
% greedy vs structure.
figure(2)
h1 = semilogy(errx, errOriMax, 'b-o', 'MarkerSize', 10, 'lineWidth', 3);
hold on
h3 = semilogy(errx, errStrMax, 'm-+', 'lineWidth', 1.5);
legend([h1, h3], {'Greedy', 'Structure'});
set(gca, 'YScale', 'log')
xticks(errx);
axis([0 errx(end) + 1 errOriMax(end) errOriMax(1)]);
grid on
xlabel('N');
ylabel('Maximum relative error');
set(gca,'fontsize',20)
%%
% greedy vs Sobol.
figure(3)
h1 = semilogy(errx, errOriMax, 'b-o', 'MarkerSize', 10, 'lineWidth', 3);
hold on
h4 = semilogy(errx, errSobolMax, 'r-*', 'lineWidth', 1.5);
legend([h1, h4], {'Greedy', 'Quasi-random (Sobol)'});
set(gca, 'YScale', 'log')
xticks(errx);
axis([0 errx(end) + 1 errOriMax(end) errOriMax(1)]);
grid on
xlabel('N');
ylabel('Maximum relative error');
set(gca,'fontsize',20)
%%
% greedy vs Latin.
figure(4)
h1 = semilogy(errx, errOriMax, 'b-o', 'MarkerSize', 10, 'lineWidth', 3);
hold on;
h4 = semilogy(errx, errLatinMax1, 'g--', 'lineWidth', 1.5);
semilogy(errx, errLatinMax2, 'g--', 'lineWidth', 1.5);
semilogy(errx, errLatinMax3, 'g--', 'lineWidth', 1.5);
semilogy(errx, errLatinMax4, 'g--', 'lineWidth', 1.5);
semilogy(errx, errLatinMax5, 'g--', 'lineWidth', 1.5);
legend([h1, h4], {'Greedy', 'Latin Hypercube'});
set(gca, 'YScale', 'log')
xticks(errx);
axis([0 errx(end) + 1 errOriMax(end) errOriMax(1)]);
grid on
xlabel('N');
ylabel('Maximum relative error');
set(gca,'fontsize',20)

% figure(2)
% pmSpaceOri = logspace(-1, 1, 129);
% pmSpacePro = logspace(-1, 1, 129);
% errPmLocOri = pmSpaceOri(errGreedy.store.loc);
% loglog(errPmLocOri, errOriMax, 'b-o', 'MarkerSize', 10, 'LineWidth', 3)
% axis([10^-1 10^1 errOriMax(end) errOriMax(1)])
% grid on
% legend({'Greedy'}, 'FontSize', 20);
% set(gca,'fontsize',20)
% xlabel('Young''s modulus', 'FontSize', 20);
% ylabel('Maximum relative error', 'FontSize', 20);