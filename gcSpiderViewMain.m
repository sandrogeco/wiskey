clc;
delete(instrfindall)
clear all
close all
numSec=1;
t=[];
v=[];
s1 = serial('COM8');    % define serial port
s1.BaudRate=115200;               % define baud rate
set(s1, 'Terminator', 'CR','InputBufferSize',1500,'Timeout',5);    % define the terminator for println
fopen(s1);
%%
close all
f1=figure;
set(f1,'color','w')
p=plot(0,0,'k');grid on
set(gca,'fontsize',14)
ylabel('voltage'),xlabel('time (s)')


% try       
% use try catch to ensure fclose
k=0;
j=0;
clear voltage
    while 1
        k=k+1
        w=fgetl(s1);
        if length(w)>=4
        if strcmp(w(end-3:end),'WSKS')
            fread(s1,1);
            node=fread(s1,1);
            wtime=fread(s1,4);
            wnSample=fread(s1,2);
            nSample = typecast(uint8(wnSample),'uint16')
            t = typecast(uint8(wtime),'uint32');
            time=double(datenum(2000,1,0)+t/86400);    
            disp(datestr(time))
            %voltage=zeros(nSample,1);
            %j=0;
            for is=1:4:nSample*4
                j=j+1
                v=fread(s1,4);
                voltage(j)= typecast(uint8(v),'single');
                format long;
                disp(voltage(j))
            end

            time=((0:length(voltage)-1)/50)/86400;

            set(p,'xdata',time,'ydata',voltage)
               set(gca,'xlim',[time(1) time(end)],'ylim',[-5 5])
            drawnow
           
        end
        end
    end
% catch me
%     fclose(s1);                 % always, always want to close s1
% end                             