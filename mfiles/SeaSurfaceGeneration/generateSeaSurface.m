function [h, k, S, V, x, kp, lambda_p] = generateSeaSurface(L, N, U10, age, varargin)
%[h, k, S, V, x, kp, lambda_p] = generateSeaSurface(L, N, U10, age)

if (nargin == 5)
   seed = varargin{1};
   if (seed > 0)
       rng(seed)
   else
       error('Random Number Seed Must be Nonnegative Integer');
   end
end

dk = 2*pi/L;
k = (0:N/2)*dk;

[S,kp] = Elfouhaily(k,U10,age);
lambda_p = 2*pi/kp;
S(1) = 0;

%apply the filter
Spindex = find(S == max(S));
S1index = find(S >= 0.5*max(S),1);
S2index = Spindex + find(S(Spindex:end) <= 0.5*max(S),1);
S(1:S1index-1) = 0;
S(S2index+1:end) = 0;

%create the random variables

V = [];
w = randn(1,N/2);
u = randn(1,N/2);

V(1) = sqrt(S(1)*dk)*w(1);
for(j = 2:N/2)
    V(j) = 1/2*sqrt(S(j)*dk)*(w(j) + 1i*u(j));
end
V(N/2+1) = sqrt(S(N/2+1)*dk)*u(1);

for (j = N/2+2:N)
V(j) = conj(V(N-j + 2));
end

h = ifft(V)*length(V);
x = (0:N-1)*L/N;
