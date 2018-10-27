N=100000;
x=-1:0.1:1;
y=x.^2;

training=rand(N,4)*2-1;
training(:,2)=training(:,1).^2;
training(:,4)=training(:,3).^2;

m=zeros(N,1);

for i=1:N
    m(i,1)=((training(i,4)-training(i,2))/(training(i,3)-training(i,1)));
end

disp(m(1,1));

b=zeros(N,1);
b(:,1)=training(:,4)-m(:,1).*training(:,3);

m_avg=mean(m(:,1));
b_avg=mean(b(:,1));

y_avg=m_avg.*x+b_avg;

bias=b_avg^2+(m_avg^2-2*b_avg)/3+(1/5);
Eout=zeros(N,1);
variance=(1/3)*var(m)+var(b);

for j=1:N
    Eout(j,1)=b(j,1)^2+(m(j,1)^2-2*b(j,1))/3+(1/5);
end

EEout=mean(Eout);

plot(x,y, x, y_avg);

% line(sumlines(:,1),D(:,2),'Color','red','LineStyle','--');
% line(x, alt_line,'Color','blue','LineStyle','--');
