time = linspace(1,120,15000);
los = time;
for i = 1:15000
    if time(i) > 29 && time(i) < 33
        los(i) = 1;
    elseif time(i) > 66 && time(i) < 68
        los(i) = 1;
    elseif time(i) > 95 && time(i) < 101
        los(i) = 1;
    else
        los(i) = 0;
    end 
end

figure()
plot(time,los)
save('Flanary_blocked_beta_los.mat','los');