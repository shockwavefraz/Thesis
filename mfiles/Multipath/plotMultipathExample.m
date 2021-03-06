function plotMultipathExample(varargin)

saveFigs = 0;

if (nargin == 1)
    saveFigs = varargin{1};
end

re = 6371000*4/3;
h1 = 30;
h2 = 20;
r4 = linspace(1000,20000,10000);

% h2 = 15 - r4/(2*re);

r1 = sqrt(r4.^2 + (h1-h2).^2);
r23 = sqrt(r4.^2 + (h1+h2).^2);

test = 2*h1*h2./r4;

lambda = 3e8/35e9;
k = 2*pi/lambda;

value = abs(exp(1j*k*r1) + exp(1j*k*r23));
% value1 = abs(exp(1j*k*r1) + exp(1j*(k*r23 +pi/4)));

h = figure;
plot(r4/1000,value,'LineWidth',2);
hold on
% plot(r4/1000,value1,'LineWidth',2);
grid on
xlabel('Down Range Distance (km)')
ylabel('F_p (unitless)');
xlim([4 20])
set(gca,'LineWidth',2)
set(gca,'FontSize',12)
set(gca,'FontWeight','bold')

if(saveFigs == 1)
    saveas(h,'two_ray_multipath_results','png')
end