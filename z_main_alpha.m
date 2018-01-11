%initialize serial
delete(instrfindall);
blu = serial('com5');
set(blu,'BaudRate',9600);
fopen(blu);

distance = 3;
direction = 0;
fprintf(blu,'%s','{0:100}');

%initialize camera
vid = videoinput('winvideo',1);  
%preview(vid);  

% Configure the object for manual trigger mode.
triggerconfig(vid, 'manual');

start(vid)
tmp0 = getsnapshot(vid);
src0 = ycbcr2rgb(tmp0);
[img_x, img_y, ~] = size(src0);
count = 1;
X = zeros(1,4);
Y = zeros(1,4);

while ~strcmpi(get(gcf,'CurrentCharacter'),'e')
    tmp1 = getsnapshot(vid);
    src1 = ycbcr2rgb(tmp1);
    figure(1)
    imshow(src1);
    R0=src0(:,:,1);
    R1=src1(:,:,1);
    
    threshold = zeros(img_x,img_y,'single');
    for i=1:img_x
       for j=1:img_y
           if R1(i,j)-R0(i,j)>12 || R0(i,j)-R1(i,j)>12
               threshold(i,j) = 255;
           else
               threshold(i,j) = 0;
           end
       end
    end
    threshold_small = threshold - bwareaopen(threshold,10);
    threshold_big = bwareaopen(threshold,300);
    threshold = threshold - threshold_big - threshold_small;
    figure(2)
    imshow(threshold),title('threshold');
    
    stats = regionprops(threshold, 'basic');
    s = size(stats);
    s = s(1);
    if(s==0)
        fprintf('no trash detected~~\n')
        src0 = src1;
        continue;
    elseif(s>1)
        fprintf('noise too loud~~\n')
        src0 = src1;
        continue;
    end

    x = stats(s).Centroid(1);
    y = stats(s).Centroid(2);
    
    if count <= 3
        X(count) = x;
        Y(count) = y;
        count = count + 1;
    elseif count == 4
        a = z_curveFit(X, -Y, 2)
        
        if a(1)<0
            %test
            %t = 0:1280;
            %p = a(1) + a(2)*t + a(3)*t.^2;
            %figure(3);plot(t,p),title('track');
            %[distance,direction] = z_transfer(a(1),a(2),a(3));
            if direction == 0
                fprintf(blu,'%s','A');
            else
                fprintf(blu,'%s','E');
            end
            pause(distance)
            fprintf(blu,'%s','Z');
        end
        
        count = 1;
        src0 = src1;
        continue;
    end
    src0 = src1;
end
stop(vid)
delete(vid)
close all

fclose(blu);
delete(blu);
