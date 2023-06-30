clear variables;
%initial positions
x_init = 3.8;
y_init = 0.5;
angles = [0 45 -45];
%velocity
u = 0.05;
%fuzzy for car control
controller = readfis('C_CarControl2.fis');
for j=1:length(angles)
    i = 1;
    flag = 1;
    all_xs = x_init;
    all_ys = y_init;
    finished = 1;
    corner = angles(j);
    while finished
        dh = 10;
        dv = 5;
        xc = all_xs(i);
        yc = all_ys(i);
        if xc < 0 || yc < 0 || xc > 10 || yc > 5 % Outside of our lines
            break;
        end
    %compute dv and dh
        if yc <= 1
            dv = yc;
            dh = 5 - xc;
        elseif yc > 1 && yc <= 2
            if xc < 5
                dv = yc;
            else
                dv = yc - 1;
            end
            dh = 6 - xc;
        elseif yc > 2 && yc <= 3
            if xc < 5
                dv = yc;
            elseif xc >= 5 && xc < 6
                dv = yc - 1;
            else
                dv = yc - 2;
            end
            dh = 7 - xc;
        elseif yc > 3
            if xc < 5
                dv = yc;
            elseif xc >= 5 && xc < 6
                dv = yc - 1;
            elseif xc >=6 && xc < 7
                dv = yc - 2;
            else
                dv = yc - 3;
            end
        end

        if dh < 0 || dh > 10 || dv < 0 || dv > 5
            flag = 0;
            break;
        end
    
        %evaluate from fuzzy the change of angle
        Dtheta = evalfis(controller,[dh/10 dv/5 corner]);

        corner = Dtheta + corner;

        %the angle must be in [-180,180] range
        %so we do this transform
        if corner < -180
            corner = 360 + corner;
        elseif corner > 180
            corner = corner - 360;
        end

        %evaluate the new coordinates
        x_new = xc + cosd(corner)*u;
        y_new = yc + sind(corner)*u;

        if x_new == 10 && y_new == 3.2
            finished = 0;
        end

        %update route
        all_xs = [all_xs x_new];
        all_ys = [all_ys y_new];
        i = i + 1;
    
    end

    figure(j);


    plot(linspace(0,1) * 0 + 5, linspace(0,1), 'black');
    hold on;
    plot(linspace(0,3) * 0 + 10, linspace(0,3), 'black');
    hold on;
    plot(linspace(1,2) * 0 + 6, linspace(1,2), 'black');
    hold on;
    plot(linspace(2,3) * 0 + 7, linspace(2,3), 'black');
    hold on;
    plot(linspace(5,6), linspace(5,6) * 0 + 1, 'black');
    hold on;
    plot(linspace(5,10), linspace(5,10) * 0, 'black');
    hold on;
    plot(linspace(6,7), linspace(6,7) * 0 + 2, 'black');
    hold on;
    plot(linspace(7,10), linspace(7,10) * 0 + 3, 'black');
    hold on;

    plot(all_xs, all_ys,'LineWidth',2,'Color',[0 0.4470 0.7410]);
    hold on;
    %Starting point
    plot(all_xs(1), all_xs(1), 'o','MarkerFaceColor','b')
    hold on;
    %Where we reached
    plot(all_xs(i-1), all_ys(i-1),'d','MarkerFaceColor','g'); 
    hold on;
    %Our destination
    plot(10, 3.2, 's','MarkerEdgeColor','r');
    %title(['¸ = ', num2str(angles_init(angles_index)), '°'])
    xlabel('x')
    ylabel('y')
    axis([0 10.1 0 5])
    hold off;
end