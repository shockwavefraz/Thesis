function create2DOceanSurfaces(L,alpha,M,U10,age,varargin)
%create2DOceanSurfaces(L,alpha, M,U10,age)
%create2DOceanSurfaces(L,alpha, M,U10,age,fileNamePrefix)
%
%This function will generate a set of 2D ocean surfaces for the given
%parameters and store them in HDF5 files
%Inputs:
%L - the spatial domain length to cover in 1 side (L^2 total dimensions)
%alpha - the scaling to use on L for the number of points per side - N =
%alpha*L, the total number of points is N^2
%M - the number of surfaces to create
%U10 - the wind speed at 10 m altitude in m/s
%age - the inverse age parameter (0.84 for fully developed, > 1.0 for
%mature, 2.0 - 5.0 for young).
%Optional input:
%fileNamePrefix - prefix to use for the file name. If not selected, the
%file name defaults to "surface"

if(nargin == 6)
    fileNamePrefix = varargin{1};
else
    fileNamePrefix = 'surface';
end

%compute N
N = alpha*L;

%setup timing info
minTime = 9e10;
maxTime = 0;
avgTime = 0;
totalTime = 0;
totalRMS = 0;
varXVec = [];
varYVec = [];
varVec = [];
%loop over the number of requested surfaces
    for counter = 1:M
        
        %start the timer and print 
        t1 = cputime;
        dispstring = sprintf('Creating Surface %d of %d',counter,M);
        disp(dispstring);
        
        %generate the surface
        [h,k,S,V,kx,ky] = generateSeaSurface2D(L, N, U10, age);
        
        %get the next file name
        fname = sprintf('%s%d.h5',fileNamePrefix,counter);

        %if the file exists, delete it
       if(exist(fname))
        delete(fname);
       end
       
       %create the file structre and write out the surface
        h5create(fname,'/surface',[N N]);
        h5write(fname,'/surface',h);
        
        %attach attributes to the dataset (metadata)
        h5writeatt(fname,'/surface','dx (m)',L/N);
        h5writeatt(fname,'/surface','L (m)',L);
        h5writeatt(fname,'/surface','U10 (m/s)',U10);
        h5writeatt(fname,'/surface','N (unitless)',N);
        h5writeatt(fname,'/surface','dk (rad/m)',2*pi/L);
        
        %get the statistics
        h1 = reshape(h,1,N^2);
        h5writeatt(fname,'/surface','std (m)' ,std(h1));
        h5writeatt(fname,'/surface','var (m)' ,var(h1));
        h5writeatt(fname,'/surface','max (m)' ,max(h1));
        h5writeatt(fname,'/surface','min (m)' ,min(h1));
        h5writeatt(fname,'/surface','wave height (m)' ,max(h1) - min(h1));
        h5writeatt(fname,'/surface','mean (m)' ,mean(h1));
        
        varVec = [varVec var(h1)];
        varYVec = [varYVec mean(var(h,0,2))];
        varXVec = [varXVec mean(var(h,0,1))];
        totalRMS = sqrt(mean(varVec));
        totalXRMS = sqrt(mean(varXVec));
        totalYRMS = sqrt(mean(varYVec));
        
        %get the final time
        t2 = cputime-t1;
        
        %update timing info
        totalTime = totalTime + t2;
        avgTime = totalTime/counter;
        if t2 > maxTime
            maxTime = t2;
        end
        if t2 < minTime
            minTime = t2;
        end
        
        %print the timing info
        dispstring = sprintf('Total Time: %0.2f s, Average Time: %0.2f s, Max Time: %0.2f s, Min Time; %0.2f s',totalTime,avgTime,maxTime,minTime);
        dispstring2 = sprintf('Current RMS: %0.5f m, Total RMS: %0.5f m, Total RMS in X: %0.5f m, Total RMS in Y: %0.5f m',std(h1),totalRMS, totalXRMS, totalYRMS);
        disp(dispstring);
        disp(dispstring2);
    end

end

