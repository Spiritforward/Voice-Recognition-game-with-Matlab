function breakout

global Vx Vy w Step count h Bx By Br hit
close all;clc
Vx=0;Vy=-0.4;w=600;Step=0;count=0; Br=zeros(1,4); hit=0;
s=get(0,'screensize');

h.f=figure('menubar','none','numbertitle','off','name','Breakout','position',[s(3)/2-300,s(4)/2-300,w,w]);
h.a=axes('xlim',[0 100],'ylim',[0 100],'xtick',[],'ytick',[],'box','on','position',[0 0 1 1]);axis square

h.p=patch([45 55 55 45],[1 1 4 4],[1 0 0 ]);
h.b=patch(50+1.5*sin([0:.01:1]*2*pi), 50+1.5*cos([0:.01:1]*2*pi),[0 0 1]);

for i=1:10
h.br(i)=patch([1 9 9 1]+i*10-10,[70 70 73 73],[1 1 0 ]);
h.br(i+10)=patch([1 9 9 1]+i*10-10,[75 75 78 78],[0 1 1]);
h.br(i+20)=patch([1 9 9 1]+i*10-10,[80 80 83 83],[1 0 1]);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

h.t1=text(40,60, sprintf('BREAKOUT\n(Press to start a new game)'));
pause
set(h.t1,'visible', 'off');

h.timer=timer('TimerFcn',@Beat,'ExecutionMode','fixedDelay','Period',.001);
h.t2=text(1, 97, 'hi','color',[.5 .8 0],'fontweight','bold','fontsize',20);
set(h.f,'keypressFcn',{@Down, h});
start(h.timer);

%--------------------------------------------------------------------------

function Down(hobject, eventdata, h)
frequency = 0;
global Step

k = eventdata.Key;
%%%%%%%%%%%%%%% when press R ; Record VOice  %%%%%%%%%%%%%%

switch k
    case 'space'
        disp('space');
    case 'return'
        %disp('Enter');
        % sampling frequency is 1 kHz
        Fs=1000;
        recObj = audiorecorder(Fs,8,1);
        % Record your voice for 5 seconds.
        time = 1;
        t = 0:1/Fs:time-1/Fs;
        disp('Start speaking.')
        recordblocking(recObj, time);
        disp('End of Recording.');

        % Play back the recording.
        play(recObj);


        % Store data in double-precision array.
        myRecording = getaudiodata(recObj);
        fft_Record = fft(myRecording);

        [Y,I] = max(abs(fft_Record));
        freq = 0:Fs/length(myRecording):Fs/2;
        frequency=freq(I);
        fprintf('Voice Frequency: at %3.2f Hz\n.',frequency);
        
    case 'leftarrow'
    if Step>0
    Step=0;
    else
        Step=Step-.2;
    end
    

    case 'rightarrow'
    if Step<0
    Step=0;
    else
        Step=Step+.2;
    end
        
    otherwise
beep;
end
%disp(freq)
if frequency>150 
    disp('Move right');
        if Step<0
    Step=0;
    else
        Step=Step+.2;
    end
        
    
elseif frequency<150 & frequency>10
    disp('Move left');
    if Step>0
    Step=0;
    else
        Step=Step-.2;
    end
else disp('No sound');
end

set(h.p,'xdata', get(h.p,'xdata')+Step);
% disp(Step)
drawnow;

%--------------------------------------------------------------------------

function Beat(varargin)
global Vx Vy w Step count h Bx By
Bx=unique(get(h.b,'xdata'));Bx=Bx([1,end]);
By=unique(get(h.b,'ydata'));By=By([1,end]);
Rx=unique(get(h.p,'xdata'));Rx=Rx([1,end]);
Ry=unique(get(h.p,'ydata'));Ry=Ry([1,end]);


brick;


if (By(1)<=Ry(2) && Bx(2)>=Rx(1) && Bx(1)<=Rx(2))
    Vx=Vx+Step;
    Vy=-Vy+(Ry(2)-By(1)-0.2)/10;
    count=count+1;
    set(h.t2,'string',num2str(count)); drawnow
    soundsc(sin(1:100),4000)
end

if Bx(1)<=0 || Bx(2)>=100
    Vx=-Vx;
end

if By(2)>=100
    Vy=-Vy;
elseif By(1)<=0
    disp(Vy);
    set(h.t,'string','Game Over !');drawnow
    stop(h.timer);
end

if Rx(1)<=0
    Step=0.1;
elseif Rx(2)>=100
    Step=-0.1;
end

set(h.b,'xdata',get(h.b,'xdata')+Vx);
set(h.b,'ydata',get(h.b,'ydata')+Vy);
set(h.p,'xdata',get(h.p,'xdata')+Step);
drawnow;

%--------------------------------------------------------------------------


function brick(obj)
global Vx Vy w Step count h Bx By hit

for i=1:length(h.br)

Brx=unique(get(h.br(i),'xdata'));Brx=Brx([1,end]);
Bry=unique(get(h.br(i),'ydata'));Bry=Bry([1,end]);

% Br=[By(2)>=Bry(1) By(1)<=Bry(2) Bx(2)>=Brx(1) Bx(1)<=Brx(2)]; % 关 困 谅 快
Brv=[By(2)-Bry(1) Bry(2)-By(1) Bx(2)-Brx(1) Brx(2)-Bx(1)]; % 关 困 谅 快

if sum(Brv>=0)==4
    if Brv(1)==min(Brv) || Brv(2)==min(Brv)
        Vy=-Vy;

    elseif Brv(3)==min(Brv) || Brv(4)==min(Brv)
        Vx=-Vx;
    end
    
    hit=hit+1;
    disp(num2str([hit Bx' Vx By' Vy]));
    set(h.br(i), 'visible', 'off', 'xdata', [0 0], 'ydata', [0 0]);
    soundsc(sin(1:100),8000);

    if hit==length(h.br)
            set(h.t,'string', 'Succeed !!');
            stop(h.timer);
    end
    
end
end


