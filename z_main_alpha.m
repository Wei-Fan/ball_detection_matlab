function [] = z_main_alpha( runtime )
%initialize serial
delete(instrfindall);
blu = serial('com3');
set(blu,'BaudRate',9600);
fopen(blu);

%initialize camera
vid = videoinput('winvideo',1);  
%preview(vid);  

%initialization
count = 1; X = zeros(1,5); Y = zeros(1,5);
ROI_flag = 0;
width = 0; length = 0;
test = 0;

% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start(vid)
src0 = getsnapshot(vid);
[img_x, img_y, ~] = size(src0);
figure('name','z_trajectory_measement');
while (1)
    src = getsnapshot(vid);
    %find the ROI
    if ROI_flag == 0
        [x1,y1,w,l] = z_dynamic_ROI(src0,src);
        src0 = src;
        if x1 == -1
            fprintf('No find ROI~~\n')
            continue;
        else
            ROI_flag = 1;
            width = w; length = l;
        end
    end

    %detect the position of the ball
    [x,y] = z_ball_detect(src,x1,y1,w,l);
    if x == -1
        src0 = src;
        ROI_flag = 0;
        %count = 1;
        continue;
    end
    
    %get the trajectory
    if count == 1
        X(1) = x;
        Y(1) = y;
        count = count + 1;
        continue;
    elseif count < 6
        X(count) = x;
        Y(count) = y;
        x1 = x1 + 1.15*(X(count) - X(count-1));
        y1 = y1 + 1.25*(Y(count) - Y(count-1));
        if x1 < 1
            x1 = 1;
        end
        if y1 < 1
            y1 = 1;
        end
        if x1 + width > img_y
            w = img_y - x1;
        else
            w = width;
        end
        if y1 + length > img_x
            l = img_x - y1;
        else
            l = length;
        end
        count = count + 1;
        continue;
    elseif count == 6
        for i = 1:4
            X(i) = X(i+1);
            Y(i) = Y(i+1); 
        end
        X(5) = x;
        Y(5) = y;
    end
    
    x1 = x1 + X(5) - X(4);
    y1 = y1 + Y(5) - Y(4);
    if x1 < 1
        x1 = 1;
    end
    if y1 < 1
        y1 = 1;
    end
    if x1 + width > img_y
        w = img_y - x1;
    else
        w = width;
    end
    if y1 + length > img_x
        l = img_x - y1;
    else
        l = length;
    end
    
    a = z_curveFit(X, -Y, 2);
    %testing
    imshow(src)
    hold on
    rectangle('Position',[x1,y1,w,l],'edgecolor','r');
    hold off
    
    [distance,direction] = z_transfer(a(1),a(2),a(3));
    fprintf(blu,'%d',distance);
    fprintf(blu,'%d',direction);
    fprintf(blu,'%d',Z);
    for i = 1:5
        fprintf(blu,'%d',direction);
    end
    fprintf(blu,'%d',Z);
end
stop(vid)
delete(vid)
close

fclose(blu);
delete(blu);
end

