plotData;

cd ~/Desktop/Temp/thesisResults/13092018_2218_Ibeam/trial=4225;

load errProposedNouiTujN20Iter20Add2Profiler.mat;
% profview(0, errProposedNouiTujN20Iter20Add2Profiler)

load errOriginalIter20Add2Profiler.mat
% profview(0, errOriginalIter20Add2Profiler)

% original: pm sweep = NM, basis processing.
% proposed: impulse response = NM, construct Wa, pm sweep, basis processing.
% proposed.
% case 1.
tpall1 = 67136; % total
tpNM1 = 3628; % exact solution
tpMTM1 = 21274;
tpSweep1 = 40375;
tpRB1 = tpall1 - tpNM1 - tpMTM1 - tpSweep1;

% case 2.
tpall2 = 76063; % total
tpNM2 = 7504; % exact solution
tpMTM2 = 44410;
tpSweep2 = 22156;
tpRB2 = tpall2 - tpNM2 - tpMTM2 - tpSweep2;

% prediction and exact.
toRB = 4475 - 4396;
toNMsweep = 4396;
ttNMsweep = toNMsweep / 1620 * 65^2 * 20;

tall = [toRB toNMsweep 0 0;  toRB ttNMsweep 0 0; ...
    0 tpall2 0 0;...
    tpRB2 tpSweep2 tpNM2 tpMTM2; tpRB1 tpSweep1 tpNM1 tpMTM1];

h = barh(tall, 'stacked');
set(h, {'facecolor'}, {'b'; 'r'; 'y'; 'g'})
axis normal
grid on
legend('Basis generation', 'Parameter sweep', 'Computation of U^{imp}', ...
    'Computation of M_i^{trans}', 'Interpreter', 'latex', 'Location', 'northeast')
set(gca,'fontsize', fsAll)
% set(gca,'xscale','log')
xlabel('Execution time (seconds)', 'FontSize', fsAll)
% xlim([10, 110000])
axis normal