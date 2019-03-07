clc;
delete(instrfindall)
clear all
close all
numSec=1;
t=[];
v=[];
smp=50;
s1 = serial('/dev/tty.usbmodem143101');    % define serial port
s1.BaudRate=115200;               % define baud rate
set(s1, 'Terminator', 'CR','InputBufferSize',1500,'Timeout',5);    % define the terminator for println
fopen(s1);

utclag=1;
%%
close all
f1=figure;
set(f1,'color',[.5 .5 .5],'positio',[55 180 1230 600])
ax1=axes;
p(1)=plot(0,0,'k');
grid on, hold on
p(2)=plot(0,0,'r');
p(3)=plot(0,0,'g');
p(4)=plot(0,0,'b');
p(5)=plot(0,0,'m');
hl=legend('1','2','3','4','5');
set(ax1,'position',[.07 .1 .45 .85],...
    'color',[.5 .5 .5],'xcolor','w','ycolor','w')
set(gca,'fontsize',14)
ylabel('voltage'),xlabel('time (MM:SS, UTC)')

ax2=axes;
pw(1)=plot(0,0,'k');
grid on, hold on
pw(2)=plot(0,0,'r');
pw(3)=plot(0,0,'g');
pw(4)=plot(0,0,'b');
pw(5)=plot(0,0,'m');
set(ax2,'position',[.6 .45 .35 .5],...
    'color',[.5 .5 .5],'xcolor','w','ycolor','w')
set(ax2,'fontsize',14,'xscale','log')
ylabel('PSD'),xlabel('frequency (Hz)')

a1=annotation('textbox',[.6 .25 .2 .05],'string','Last data time: ');
set(a1,'FontSize',15,'VerticalAlignment','middle','Color','w','EdgeColor','w')
anow=annotation('textbox',[.6 .3 .2 .05],'string',['Current time: ',datestr(now,'HH:MM:SS.FFF')]);
set(anow,'FontSize',15,'VerticalAlignment','middle','Color','w','EdgeColor','w')
alatency=annotation('textbox',[.6 .2 .25 .05],'string',['Current data Tx latency (s): ',datestr(now,'HH:MM:SS.FFF')]);
set(alatency,'FontSize',15,'VerticalAlignment','middle','Color','r','EdgeColor','w')

%... initialize recording and plotting variable
V.s1=[];V.s2=[];V.s3=[];V.s4=[];V.s5=[];
T.s1=[];T.s2=[];T.s3=[];T.s4=[];T.s5=[];
Vrec.s1=[];Vrec.s2=[];Vrec.s3=[];Vrec.s4=[];Vrec.s5=[];
Trec.s1=[];Trec.s2=[];Trec.s3=[];Trec.s4=[];Trec.s5=[];


twin=300;
tstep=30;

onStart=1;
k=0;
j=0;
clear voltage
    while 1
        k=k+1;
        w=fgetl(s1);
        if length(w)>=4
        if strcmp(w(end-3:end),'WSKS')
            fread(s1,1);
            node=num2str(fread(s1,1));
            wtime=fread(s1,4);
            wnSample=fread(s1,2);
            nSample = typecast(uint8(wnSample),'uint16');
            t = cast(typecast(uint8(wtime),'uint32'),'double');
            tmat=double(datenum(2000,1,1)+t/86400);    
            disp(datestr(tmat))
            %voltage=zeros(nSample,1);
            j=0;
            volt=zeros(1,nSample);
            for is=1:4:nSample*4
                j=j+1;
                v=fread(s1,4);
                volt(j)= -1* typecast(uint8(v),'single');
            end
            
            V.(['s',node])=cat(2,V.(['s',node]),volt);
            ts=(0:length(volt)-1)/smp;
            tim=sort(tmat-ts/86400);
            T.(['s',node])=cat(2,T.(['s',node]),tim);

            %... Power Spectrum
            [Pxx,F] = pwelch(detrend(V.(['s',node])),length(V.(['s',node])),length(V.(['s',node]))-1,2^(nextpow2(length(V.(['s',node])))),smp);
            
            tnow=now-utclag/24;
            switch node
                case '1'
                    set(p(1),'xdata',T.(['s',node]),'ydata',V.(['s',node]))
                    set(pw(1),'xdata',F,'ydata',10*log10(Pxx))
                    set(anow,'string',['Current time: ',datestr(tnow,'HH:MM:SS.FFF')],'color','k')
                    set(a1,'string',['Last data time: ',datestr(T.(['s',node])(end),'HH:MM:SS.FFF')],'color','k')
                    latency=86400*(tnow-T.(['s',node])(end));
                    set(alatency,'string',['Current data Tx latency (s): ',num2str(latency)])
                case '2'
                    set(p(2),'xdata',T.(['s',node]),'ydata',V.(['s',node]))
                    set(pw(2),'xdata',F,'ydata',10*log10(Pxx))
                    set(anow,'string',['Current time: ',datestr(tnow,'HH:MM:SS.FFF')],'color','r')
                    set(a1,'string',['Last data time: ',datestr(T.(['s',node])(end),'HH:MM:SS.FFF')],'color','r')
                    latency=86400*(tnow-T.(['s',node])(end));
                    set(alatency,'string',['Current data Tx latency (s): ',num2str(latency)])
                case '3'
                    set(p(3),'xdata',T.(['s',node]),'ydata',V.(['s',node]))
                    set(pw(3),'xdata',F,'ydata',10*log10(Pxx))
                    set(anow,'string',['Current time: ',datestr(tnow,'HH:MM:SS.FFF')],'color','g')
                    set(a1,'string',['Last data time: ',datestr(T.(['s',node])(end),'HH:MM:SS.FFF')],'color','g')
                    latency=86400*(tnow-T.(['s',node])(end));
                    set(alatency,'string',['Current data Tx latency (s): ',num2str(latency)])
                case '4'
                    set(p(4),'xdata',T.(['s',node]),'ydata',V.(['s',node]))
                    set(pw(4),'xdata',F,'ydata',10*log10(Pxx))
                    set(anow,'string',['Current time: ',datestr(tnow,'HH:MM:SS.FFF')],'color','b')
                    set(a1,'string',['Last data time: ',datestr(T.(['s',node])(end),'HH:MM:SS.FFF')],'color','b')
                    latency=86400*(tnow-T.(['s',node])(end));
                    set(alatency,'string',['Current data Tx latency (s): ',num2str(latency)])
                case '5'
                    set(p(5),'xdata',T.(['s',node]),'ydata',V.(['s',node]))
                    set(pw(5),'xdata',F,'ydata',10*log10(Pxx))
                    set(anow,'string',['Current time: ',datestr(tnow,'HH:MM:SS.FFF')],'color','m')
                    set(a1,'string',['Last data time: ',datestr(T.(['s',node])(end),'HH:MM:SS.FFF')],'color','m')
                    latency=86400*(tnow-T.(['s',node])(end));
                    set(alatency,'string',['Current data Tx latency (s): ',num2str(latency)])
            end
            
            tvec=T.(['s',node])(1):tstep/86400:T.(['s',node])(1)+twin/86400;
            set(ax1,'xlim',[tvec(1) tvec(end)],'ylim',[0 5],...
                'xtick',tvec,'xticklabel',datestr(tvec,'MM:SS'))
            drawnow
%             ciao 
                   
            %... Savein
            if onStart~=1 && ~isempty(Trec.(['s',node]))
                if (floor(tim(end)*24)-floor((Trec.(['s',node])(1))*24))==1
                    th=floor(tim(end)*24)/24;
                    j=Trec.(['s',node])>=th;
                    tresto=tim(j);vresto=volt(j);
                    Trec.(['s',node])(j)='';Vrec.(['s',node])(j)='';
                    filename=['wkyFile-',datestr(tmat,'yyyymmdd'),'-',datestr(tmat,'HH'),'0000-node',node];
                    disp(['saveing ',filename])
                    time=Trec.(['s',node]);voltage=Vrec.(['s',node]);
                    save(['data/',filename],'time','voltage')
                    
                    Trec.(['s',node])=tresto;
                    Vrec.(['s',node])=vresto;
                else
                    Trec.(['s',node])=cat(2,Trec.(['s',node]),tim);
                    Vrec.(['s',node])=cat(2,Vrec.(['s',node]),volt);
                end
            else
                Trec.(['s',node])=cat(2,Trec.(['s',node]),tim);
                Vrec.(['s',node])=cat(2,Vrec.(['s',node]),volt);
                onStart=0;
            end
                        
            % Sroll Signal
            if (T.(['s',node])(end)-T.(['s',node])(1))*86400>=twin
                j=T.(['s',node])>=T.(['s',node])(1)+5/86400;
                V.(['s',node])=V.(['s',node])(j);
                T.(['s',node])=T.(['s',node])(j);
            end
%                 
           
        end
        end
    end
% catch me
%     fclose(s1);                 % always, always want to close s1
% end                             