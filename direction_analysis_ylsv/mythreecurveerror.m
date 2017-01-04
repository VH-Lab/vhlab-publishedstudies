function err = mythreecurveerror(x,y1,y2,y3)

err = sum((y1-x(1)*y2).^2+(y1-x(2)*y3).^2);

