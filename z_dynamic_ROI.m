function [ x1,y1,w,l ] = z_dynamic_ROI( src0, src1 )
x1 = -1; y1 = -1; w = -1; l = -1;
[img_x, img_y, ~] = size(src0);
R0=src0(:,:,1);
R1=src1(:,:,1);
LENGTH = 120;

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
threshold = bwareaopen(threshold,1000);

stats = regionprops(threshold, 'basic');
area = zeros(size(stats));
for i=1:size(stats)
    area(i) = stats(i).Area;
end

[M,I] = max(area);
if(M>5000)
    if stats(I).BoundingBox(1) < LENGTH
        x1 = 1;
    else
        x1 = stats(I).BoundingBox(1)-LENGTH;
    end
    if stats(I).BoundingBox(2) < LENGTH
        y1 = 1;
    else
        y1 = stats(I).BoundingBox(2)-LENGTH;
    end
    if x1+stats(I).BoundingBox(3) > img_y -LENGTH*2
        w = img_y-x1;
    else
        w = stats(I).BoundingBox(3)+LENGTH*2;
    end
    if y1+stats(I).BoundingBox(4) > img_x -LENGTH*2
        l = img_x-y1;
    else
        l = stats(I).BoundingBox(4)+LENGTH*2;
    end
end
hold off



end

