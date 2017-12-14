function [ X,Y ] = z_ball_detect( src,x1,y1,w,l )
%initialize
X = -1; Y = -1;
[img_x, img_y, ~] = size(src);
R=src(:,:,1); G=src(:,:,2); B=src(:,:,3);
threshold = zeros(img_x,img_y);

%threshold condition 
%(to be more advanced, i should consider moving project detection)
%ceil(y1)
%ceil(x1)
y2 = floor(y1+l);
x2 = floor(x1+w);
for i=ceil(y1):y2
    for j=ceil(x1):x2
        if(R(i,j)-G(i,j)>15 && R(i,j)-B(i,j)>20)
            threshold(i,j) = 255;
        else
            threshold(i,j) = 0;
        end
    end
end

%get the object
threshold = bwareaopen(threshold,1000);
%subplot(1,2,1), imshow(threshold),title('threshold')

stats =  regionprops(threshold, 'basic');
area = zeros(size(stats));
for i=1:size(stats)
    area(i) = stats(i).Area;
end

%subplot(1,2,2), imshow(src,'border','tight'), title('src')
%hold on
[M,I] = max(area);
if M>5000
    %rectangle('Position', [stats(I).BoundingBox],'LineWidth',2,'LineStyle','--','EdgeColor','r'),
    X = stats(I).Centroid(1);
    Y = stats(I).Centroid(2);
end
%hold off

end

