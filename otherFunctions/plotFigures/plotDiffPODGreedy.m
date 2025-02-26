% this script draws the discretised parameter domain, to
% demonstrate the sampling difference among POD, snapshot-POD, POD-Greedy.
clear; clc; close all;

% evenly distributed for POD.
figure(1)
hold on
rectangle('Position',[0 0 100 100], 'LineWidth',2)
axis([0 100 0 100])
axis square

xe = linspace(2, 98, 25);
ye = linspace(2, 98, 25);
for i = 1:length(xe)
    for j = 1:length(ye)
        plot(xe(i), ye(j), '-+', 'LineWidth', 1.5, ...
            'MarkerSize', 10, 'Color', 'b');
    end
end
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])

grid on
grid minor
% randomly distributed for snapshot-POD.
figure(2)
hold on
rectangle('Position',[0 0 100 100], 'LineWidth',2)
axis([0 100 0 100])
axis square

n = 20;

xr = randi([0 100], n, 1);
yr = randi([0 100], n, 1);

for i = 1:n
    plot(xr(i), yr(i), '-+', 'LineWidth', 1.5, ...
        'MarkerSize', 10, 'Color', 'b')
end
set(gca,'XTickLabel',[])
set(gca,'YTickLabel',[])


grid on
grid minor