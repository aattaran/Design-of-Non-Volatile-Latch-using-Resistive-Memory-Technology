% Import data from file which will create 5 columns.
% importdata('XXX.mt0').
% Import instructions: Delimited>Space  and  column Vectors   and variable
% names row 4.
% After import, you will notice delay is a vector of cells and others are
% double vectors.
% Create new double vector to store delay and initialize to 0.
% delay3 = (zeros(9216,1));
% % Copy all successful values
% delayi=num2cell(delay);
% for i=1:length(delay3)
%     if (strcmp(delayi{i},'NaN'))
%         delay3(i) = 0;
%     else
%         delay3(i) = str2double(delayi{i}); 
%     end
% end
%delay3=str2double(delay3);

A=importdata('write_ali.mt0');
A=A.textdata(5:end,:);
delay3 = zeros(9216,1);
for i=1:length(delay3)
    if (strcmp(A{i,7},'failed'))
        delay3(i) = 0;
    else
        delay3(i) = str2num(A{i,7}); 
    end
end

% Set value for failed. Here I have used 1.5 times the maximum value. You
% can increase further to show sharp difference between fail and successful
% or set it to zero or some other fixed value
failDelay = 1.5*max(delay3);
% For every falied entry in delay, copy numerical value faildelay in delay2
for i=1:length(delay3)
    if (delay3(i) == 0)
        delay3(i) = failDelay;
    end
end

%% Use suitable plot to show the graph. I have written 2. Uncomment and use whichever one you like

% scatter(ratio10,ratio01,5,delay2);
 scatter3(sinkn,topn,delay3,20,delay3);
 %scatter3(x,y,z,...
%       'MarkerEdgeColor','k',...
%       'MarkerFaceColor',[0 .75 .75])
%
% Mesh graphs aren't ideally suited for randomly sampled data. You can
% make good plots even without the mesh and they will be more informative.

%% To adjust colors in graph
% After the plot is created. Click on Insert Colorbar. A colorbar will appear.
% Right click on the Colorbar. Select any standard colormap and then select Interactive colormap shift.
% Now you can adjust the colors in colorbar by dragging them up and down as per your preference.
% I have attached a sample colormap for your use.

%% To calculate minimum area
% Set the maximum allowed delay
maxDelay = 1e-8;
% Initialize position of minimum area
position = -1;
for i=1:length(delay3)
    if (delay3(i) <= maxDelay)
        if (position == -1)
            position = i;
        elseif (area1(i)<area1(position))
            % Update the position to new position
            position = i;
        end
    end
end
% Print minimum area values
if (position ~= -1)
    ratio10(position)
    ratio01(position)
    sinkn(position)
    topn(position)
    area1(position)
    temper(position)
    delay3(position)
end