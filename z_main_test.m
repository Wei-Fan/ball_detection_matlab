function [] = z_main_test( runtime )
%initialize timer
tstart = tic;
tused = toc(tstart);

%initialize camera
vid = videoinput('winvideo',1);  
%preview(vid);  

%initialization
X = zeros(1,5); Y = zeros(1,5);
ROI_flag = 0;
width = 0; length = 0;
figure();

% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

% Now that the device is configured for manual triggering, call START.
% This will cause the device to send data back to MATLAB, but will not log
% frames to memory at this point.
start(vid)
src0 = getsnapshot(vid);
[img_x, img_y, ~] = size(src0)
while tused < runtime
    src = getsnapshot(vid);
    %find the ROI
    if ROI_flag == 0
        [x1,y1,w,l] = z_dynamic_ROI(src0,src)
        src0 = src;
        if x1 == -1
            tused = toc(tstart);
            fprintf('No find ROI~~\n')
            continue;
        else
            ROI_flag = 1;
            width = w; length = l;
        end
    end
    
    x1 = x1 + 10;
    y1 = y1 + 10;
    
    if x1 < 1 || x1 > img_y
        x1 = 1;
    end
    if y1 < 1 || y1 > img_x
        y1 = 1;
    end
    if x1 + width > img_y
        w = img_y - x1;
    else
        w = width;
    end
    if y1 + length > img_x
        l = img_y - y1;
    else
        l = length;
    end
    
    imshow(src)
    hold on
    rectangle('Position',[x1,y1,w,l],'edgecolor','b');
    hold off
    
    %testing
    tused = toc(tstart);
end
tused
stop(vid)
delete(vid)
close
end

