while true

    X = rand(1024,1);
    Y = rand(1024,1);
    x = fft(X);
    y = fft(Y);

    x = abs(x);
    y = abs(y);

    image=zeros(1024,1024,3); %initialize

    x1 = x(2:341)./max(x(2:1024));%max(x(2:341));
    x2 = x(342: 682)./max(x(2:1024));%max(x(342:682));
    x3 = x(683:1024)./max(x(2:1024));%max(x(683:1024));

    for i = 1:length(x1)
        image(:,i, 1) = x1(i);
    end
    for i = length(x1):(length(x2)+length(x1)-1)
        image(:,i, 2) = x2(i-length(x1)+1);
    end
    for i = length(x1)+length(x2):(length(x3) + length(x2)+length(x1)-1)
        image(:,i, 3) = x3(i-length(x1)-length(x2)+1);
    end

    image2=zeros(1024,1024,3); %initialize

    y1 = y(2:341)./max(y(2:1024));%max(y(2:341));
    y2 = y(342: 682)./max(y(2:1024));%max(y(342:682));
    y3 = y(683:1024)./max(y(2:1024));%max(y(683:1024));

    for i = 1:length(y1)
        image2(1024-i,:, 1) = y1(i);
    end
    for i = length(y1):(length(y2)+length(y1)-1)
        image2(1024-i,:, 2) = y2(i-length(y1)+1);
    end
    for i = length(y1)+length(y2):(length(y3) + length(y2)+length(y1)-1)
        image2(1024-i,:, 3) = y3(i-length(y1)-length(y2)+1);
    end
    figure(1)
    
    i3 = imfuse(image2, image, 'blend');
    blur = imgaussfilt(i3,1);
    
    imshow(blur);

end