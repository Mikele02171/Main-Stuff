function varargout = Lab6ExA(varargin)
% LAB6EXA M-file for Lab6ExA.fig
%      LAB6EXA, by itself, creates a new LAB6EXA or raises the existing
%      singleton*.
%
%      H = LAB6EXA returns the handle to a new LAB6EXA or the handle to
%      the existing singleton*.
%
%      LAB6EXA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LAB6EXA.M with the given input arguments.
%
%      LAB6EXA('Property','Value',...) creates a new LAB6EXA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Lab6ExA_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Lab6ExA_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Lab6ExA

% Last Modified by GUIDE v2.5 13-Apr-2005 16:37:01

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Lab6ExA_OpeningFcn, ...
    'gui_OutputFcn',  @Lab6ExA_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Lab6ExA is made visible.
function Lab6ExA_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Lab6ExA (see VARARGIN)

% The following commands are used to get user input from the GUI components
% get(handles.selectTF,'Value');
% str2double(get(handles.aconst,'String'));
% str2double(get(handles.bconst,'String'));
% get(handles.tfFunction,'String');
% get(handles.pdfX,'Value');
% str2double(get(handles.aparam,'String'));
% str2double(get(handles.bparam,'String'));

% Plot default pdf of X and transform
plotPdfXtf(hObject,handles);

% Choose default command line output for Lab6ExA
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Lab6ExA wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Lab6ExA_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in selectTF.
function selectTF_Callback(hObject, eventdata, handles)
% hObject    handle to selectTF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: contents = get(hObject,'String') returns selectTF contents as cell array
%        contents{get(hObject,'Value')} returns selected item from selectTF


% --- Executes during object creation, after setting all properties.
function selectTF_CreateFcn(hObject, eventdata, handles)
% hObject    handle to selectTF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function aconst_Callback(hObject, eventdata, handles)
% hObject    handle to aconst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: get(hObject,'String') returns contents of aconst as text
%        str2double(get(hObject,'String')) returns contents of aconst as a double


% --- Executes during object creation, after setting all properties.
function aconst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aconst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bconst_Callback(hObject, eventdata, handles)
% hObject    handle to bconst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: get(hObject,'String') returns contents of bconst as text
%        str2double(get(hObject,'String')) returns contents of bconst as a double


% --- Executes during object creation, after setting all properties.
function bconst_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bconst (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tfFunction_Callback(hObject, eventdata, handles)
% hObject    handle to tfFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: get(hObject,'String') returns contents of tfFunction as text
%        str2double(get(hObject,'String')) returns contents of tfFunction as a double


% --- Executes during object creation, after setting all properties.
function tfFunction_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tfFunction (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pdfX.
function pdfX_Callback(hObject, eventdata, handles)
% hObject    handle to pdfX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Set parameters to default for pdf selected
val = get(hObject,'Value');
str = get(hObject, 'String');

switch str{val};
    case {'Uniform (a,b)','Normal (a,b)','Cauchy (a,b)'} % User selects uniform, normal or cauchy distribution
        set(handles.aparam,'String','0');
        set(handles.bparam,'String','1');
    case 'Exponential (a)' % User selects exponential distribution
        set(handles.aparam,'String','1');
        set(handles.bparam,'String','0');
    case 'Gamma (a,b)' % User selects gamma distribution
        set(handles.aparam,'String','1');
        set(handles.bparam,'String','1');
end
guidata(hObject, handles);

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: contents = get(hObject,'String') returns pdfX contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pdfX


% --- Executes during object creation, after setting all properties.
function pdfX_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pdfX (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function aparam_Callback(hObject, eventdata, handles)
% hObject    handle to aparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: get(hObject,'String') returns contents of aparam as text
%        str2double(get(hObject,'String')) returns contents of aparam as a double


% --- Executes during object creation, after setting all properties.
function aparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to aparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function bparam_Callback(hObject, eventdata, handles)
% hObject    handle to bparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Re-plot the transform and pdf of X
plotPdfXtf(hObject,handles);

% Hints: get(hObject,'String') returns contents of bparam as text
%        str2double(get(hObject,'String')) returns contents of bparam as a double


% --- Executes during object creation, after setting all properties.
function bparam_CreateFcn(hObject, eventdata, handles)
% hObject    handle to bparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in RunSim.
function RunSim_Callback(hObject, eventdata, handles)
% hObject    handle to RunSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Do 300 000 simulations.
% Plot the epdf of Y (bin data to generate bar plot).
% Plot the exact pdf of Y if the transformation selected is not "general".
% Scale the epdf so it's peak is the same as the peak of the exact pdf.
% Make sure that the Y axis has the same scale as the transformation plot.

plotPdfXtf(hObject,handles);
axes(handles.axesPDFY);

valx = get(handles.pdfX,'Value');
strx = get(handles.pdfX, 'String');
ap = str2double(get(handles.aparam,'String'));
bp = str2double(get(handles.bparam,'String'));
valt = get(handles.selectTF,'Value');
strt = get(handles.selectTF,'String');
ac = str2double(get(handles.aconst,'String'));
bc = str2double(get(handles.bconst,'String'));
tfunc = get(handles.tfFunction,'String');

% Do simulations
nreps=300000;
numbins=100;

% Set bins for histogram
binrange = get(handles.axesTF,'YLim');
bins = binrange(1)+(binrange(2)-binrange(1))/numbins/2:(binrange(2)-binrange(1))/numbins:binrange(2)-(binrange(2)-binrange(1))/numbins/2;
epmf=zeros(1,length(bins));
increment=(1/nreps);
for i=1:nreps
    % Simulate X
    switch strx{valx};
        case 'Uniform (a,b)'
            xsim = ap + (bp-ap)*rand(1);
        case 'Exponential (a)'
            xsim = (-1/ap)*log(rand(1));
        case 'Gamma (a,b)'
            xsim = rand(1);%Not working - findroot(gammainc(x/bp,ap)-rand(1)); or use funtools function inversion
        case 'Normal (a,b)'
            xsim = ap + sqrt(bp)*randn(1);
        case 'Cauchy (a,b)'
            xsim = ap+bp*tan(pi*(rand(1)-1/2));
    end
    % Apply transformation
    switch strt{valt};
        case 'Y = aX + b'
            ysim = ac*xsim+bc;
        case 'Y = X^2'
            ysim = xsim^2;
        case {'Monotonic','General'}
            X=xsim;
            ysim = eval(tfunc);
    end
    % Round off ysim into bins
    index = floor((ysim - binrange(1))/(binrange(2)-binrange(1))*numbins) + 1;
    if index >= 1 && index <= length(bins)
        epmf(index)=epmf(index)+increment;
    end
end
%barh(bins, epmf',0.8,'c');
%hold on;
% Plot theoretical pdf of Y
y = binrange(1):(binrange(2)-binrange(1))/5000:binrange(2);
f = zeros(1,length(y));
switch strt{valt};
    case 'Y = aX + b'
        switch strx{valx};
            case 'Uniform (a,b)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>ac*ap+bc && y(i)<ac*bp+bc
                            f(i) = 1/abs(ac)/(bp-ap);
                        end
                    else
                        if y(i)<ac*ap+bc && y(i)>ac*bp+bc 
                            f(i) = 1/abs(ac)/(bp-ap);
                        end
                    end
                end
            case 'Exponential (a)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>= bc
                            f(i) = ap/abs(ac) * exp(-ap/ac*(y(i)-bc));
                        end
                    else
                        if y(i)<= bc 
                            f(i) = ap/abs(ac) * exp(-ap/ac*(y(i)-bc));
                        end
                    end
                end
            case 'Gamma (a,b)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>= bc
                            f(i) = bp^ap*exp(-bp/ac*(y(i)-bc))*((y(i)-bc)/ac)^(ap-1) /abs(ac)/ gamma(ap);
                        end
                    else
                        if y(i)<= -bc 
                            f(i) = bp^ap*exp(-bp/ac*(y(i)-bc))*((y(i)-bc)/ac)^(ap-1) /abs(ac)/ gamma(ap);
                        end
                    end
                end
            case 'Normal (a,b)'
                f = exp(-1/(2*bp)*((y-bc)/ac-ap).^2)/(sqrt(2*bp*pi))/abs(ac);
            case 'Cauchy (a,b)'
                f = 1./(bp+(((y-bc)/ac-ap)/bp).^2)./pi/abs(ac);
        end
        %f = mean(epmf)/mean(f)*f;
        %plot(f,y,'LineWidth',2,'Color','r');
    case 'Y = X^2'
        switch strx{valx};
            case 'Uniform (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        if sqrt(y(i))>ap && sqrt(y(i))<bp
                            f(i) = 1/(bp-ap);
                        end
                        if -sqrt(y(i))>ap && -sqrt(y(i))<bp 
                            f(i) = f(i)+1/(bp-ap);
                        end
                        f(i)=f(i)/2/sqrt(y(i));
                    end
                end
            case 'Exponential (a)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = ap * exp(-ap*sqrt(y(i)))/2/sqrt(y(i)); 
                    end
                end
            case 'Gamma (a,b)'
                for i=1:length(y)
                    for i=1:length(y)
                        if y(i)>0
                            f(i) = (bp^ap)*exp(-bp*(sqrt(y(i))))*sqrt(y(i))^(ap-1)/ gamma(ap)/2/sqrt(y(i));
                        end
                    end
                end
            case 'Normal (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = (exp(-1/(2*bp)*(sqrt(y(i))-ap)^2)+exp(-1/(2*bp)*(-sqrt(y(i))-ap)^2))/(sqrt(2*bp*pi))/2/sqrt(y(i)); 
                    end
                end
            case 'Cauchy (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = (1/(bp+((sqrt(y(i))-ap)/bp)^2)+1/(bp+((-sqrt(y(i))-ap)/bp)^2))/pi/2/sqrt(y(i));
                    end
                end
        end
        %f = mean(epmf)/mean(f)*f;
        %plot(f,y,'LineWidth',2,'Color','r');
    case 'Monotonic'
        %Haven't done the symbolic part yet
        switch strx{valx};
            case 'Uniform (a,b)'
                %insert
            case 'Exponential (a)'
                %insert
            case 'Gamma (a,b)'
                %insert
            case 'Normal (a,b)'
                %insert
            case 'Cauchy (a,b)'
                %insert
        end
        %f = max(epmf)/max(f)*f;
        %plot(f,y);
end
switch strt{valt};
    case {'Y = aX + b','Y = X^2'}   
        epmf = mean(f)/mean(epmf)*epmf;
        barh(bins, epmf','c');
        hold on;
        plot(f,y,'LineWidth',2,'Color','r');
    case {'Monotonic','General'}
        barh(bins, epmf','c');
        hold on;
end
%barh(bins, epmf','c');
%hold on;
%plot(f,y,'LineWidth',2,'Color','r');
%legend('empirical','theoretical',0);
% set axes limit properties
set(handles.axesPDFY,'YAxisLocation','right');
set(handles.axesPDFY,'YTickLabel','');
set(handles.axesPDFY,'YTickLabelMode','manual');
set(handles.axesPDFY,'XTickLabel','');
set(handles.axesPDFY,'XTickLabelMode','manual');
set(handles.axesPDFY,'XDir','reverse');
set(handles.axesPDFY,'YLim',binrange);
set(handles.axesPDFY,'XLim',[0 1.05*max([max(f) max(epmf)])]);
set(handles.pdfymax,'String',num2str(1.05*max([max(f) max(epmf)]),3));

hold off;


% --- Executes on button press in StepSim.
function StepSim_Callback(hObject, eventdata, handles)
% hObject    handle to StepSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Do 10 simulations.
% Plot the epdf of Y (bin data to generate bar plot).
% Make sure that the Y axis has the same scale as the transformation plot.
% Plot traces of the simulated data on the transformation plot and the plot
% of the pdf of X.

plotPdfXtf(hObject,handles);

valx = get(handles.pdfX,'Value');
strx = get(handles.pdfX, 'String');
ap = str2double(get(handles.aparam,'String'));
bp = str2double(get(handles.bparam,'String'));
valt = get(handles.selectTF,'Value');
strt = get(handles.selectTF,'String');
ac = str2double(get(handles.aconst,'String'));
bc = str2double(get(handles.bconst,'String'));
tfunc = get(handles.tfFunction,'String');

% Do 10 simulations
nreps=10;
numbins=100;

% Set bins for histogram
binrange = get(handles.axesTF,'YLim');
xrange = get(handles.axesTF,'XLim');
pdfxrange = get(handles.axesPDFX,'YLim');
pdfyrange = get(handles.axesPDFY,'XLim');
bins = binrange(1)+(binrange(2)-binrange(1))/numbins/2:(binrange(2)-binrange(1))/numbins:binrange(2)-(binrange(2)-binrange(1))/numbins/2;
epmf=zeros(1,length(bins));
increment=(1/nreps);
for i=1:nreps
    % Simulate X
    switch strx{valx};
        case 'Uniform (a,b)'
            xsim = ap + (bp-ap)*rand(1);
        case 'Exponential (a)'
            xsim = (-1/ap)*log(rand(1));
        case 'Gamma (a,b)'
            xsim = rand(1);%Not working - findroot(gammainc(x/bp,ap)-rand(1)); or use funtools function inversion
        case 'Normal (a,b)'
            xsim = ap + sqrt(bp)*randn(1);
        case 'Cauchy (a,b)'
            xsim = ap+bp*tan(pi*(rand(1)-1/2));
    end
    % Apply transformation
    switch strt{valt};
        case 'Y = aX + b'
            ysim = ac*xsim+bc;
        case 'Y = X^2'
            ysim = xsim^2;
        case {'Monotonic','General'}
            X=xsim;
            ysim = eval(tfunc);
    end
    % Plot trace on transformation plot
    axes(handles.axesPDFY);
    hold on;
    plot(0,ysim,'d'); 
    axes(handles.axesTF);
    line([xrange(1) xsim xsim],[ysim ysim binrange(1)],'Color','m','LineStyle',':');
    axes(handles.axesPDFX);
    hold on;
    line([xsim xsim],pdfxrange,'Color','m','LineStyle',':');
    plot(xsim,pdfxrange(1),'d'); 
    hold off;
    % Round off ysim into bins
    index = floor((ysim - binrange(1))/(binrange(2)-binrange(1))*numbins) + 1;
    if index >= 1 && index <= length(bins)
        epmf(index)=epmf(index)+increment;
    end
end
axes(handles.axesPDFY);

hold on;
% Plot theoretical pdf of Y
y = binrange(1):(binrange(2)-binrange(1))/5000:binrange(2);
f = zeros(1,length(y));
switch strt{valt};
    case 'Y = aX + b'
        switch strx{valx};
            case 'Uniform (a,b)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>ac*ap+bc && y(i)<ac*bp+bc
                            f(i) = 1/abs(ac)/(bp-ap);
                        end
                    else
                        if y(i)<ac*ap+bc && y(i)>ac*bp+bc 
                            f(i) = 1/abs(ac)/(bp-ap);
                        end
                    end
                end
            case 'Exponential (a)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>= bc
                            f(i) = ap/abs(ac) * exp(-ap/ac*(y(i)-bc));
                        end
                    else
                        if y(i)<= bc 
                            f(i) = ap/abs(ac) * exp(-ap/ac*(y(i)-bc));
                        end
                    end
                end
            case 'Gamma (a,b)'
                for i=1:length(y)
                    if ac>0
                        if y(i)>= bc
                            f(i) = bp^ap*exp(-bp/ac*(y(i)-bc))*((y(i)-bc)/ac)^(ap-1) /abs(ac)/ gamma(ap);
                        end
                    else
                        if y(i)<= -bc 
                            f(i) = bp^ap*exp(-bp/ac*(y(i)-bc))*((y(i)-bc)/ac)^(ap-1) /abs(ac)/ gamma(ap);
                        end
                    end
                end
            case 'Normal (a,b)'
                f = exp(-1/(2*bp)*((y-bc)/ac-ap).^2)/(sqrt(2*bp*pi))/abs(ac);
            case 'Cauchy (a,b)'
                f = 1./(bp+(((y-bc)/ac-ap)/bp).^2)./pi/abs(ac);
        end
        %f = max(epmf)/max(f)*f;
        plot(f,y,'LineWidth',2);
    case 'Y = X^2'
        switch strx{valx};
            case 'Uniform (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        if sqrt(y(i))>ap && sqrt(y(i))<bp
                            f(i) = 1/(bp-ap);
                        end
                        if -sqrt(y(i))>ap && -sqrt(y(i))<bp 
                            f(i) = f(i)+1/(bp-ap);
                        end
                        f(i)=f(i)/2/sqrt(y(i));
                    end
                end
            case 'Exponential (a)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = ap * exp(-ap*sqrt(y(i)))/2/sqrt(y(i)); 
                    end
                end
            case 'Gamma (a,b)'
                for i=1:length(y)
                    for i=1:length(y)
                        if y(i)>0
                            f(i) = (bp^ap)*exp(-bp*(sqrt(y(i))))*sqrt(y(i))^(ap-1)/ gamma(ap)/2/sqrt(y(i));
                        end
                    end
                end
            case 'Normal (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = (exp(-1/(2*bp)*(sqrt(y(i))-ap)^2)+exp(-1/(2*bp)*(-sqrt(y(i))-ap)^2))/(sqrt(2*bp*pi))/2/sqrt(y(i)); 
                    end
                end
            case 'Cauchy (a,b)'
                for i=1:length(y)
                    if y(i)>0
                        f(i) = (1/(bp+((sqrt(y(i))-ap)/bp)^2)+1/(bp+((-sqrt(y(i))-ap)/bp)^2))/pi/2/sqrt(y(i));
                    end
                end
        end
        %f = max(epmf)/max(f)*f;
        plot(f,y,'LineWidth',2);
    case 'Monotonic'
        %Haven't done the symbolic part yet
        switch strx{valx};
            case 'Uniform (a,b)'
                %insert
            case 'Exponential (a)'
                %insert
            case 'Gamma (a,b)'
                %insert
            case 'Normal (a,b)'
                %insert
            case 'Cauchy (a,b)'
                %insert
        end
        %f = max(epmf)/max(f)*f;
        %plot(f,y);
end
% set axes limit properties
set(handles.axesPDFY,'YAxisLocation','right');
set(handles.axesPDFY,'YTickLabel','');
set(handles.axesPDFY,'YTickLabelMode','manual');
set(handles.axesPDFY,'XTickLabel','');
set(handles.axesPDFY,'XTickLabelMode','manual');
set(handles.axesPDFY,'XDir','reverse');
set(handles.axesPDFY,'YLim',binrange);
set(handles.axesPDFY,'XLim',[0 1.05*max([max(f) max(epmf)])]);
set(handles.pdfymax,'String',num2str(1.05*max([max(f) max(epmf)]),3));

hold off;



% --- Executes on button press in ResetSim.
function ResetSim_Callback(hObject, eventdata, handles)
% hObject    handle to ResetSim (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Clear the plot of the pdf of Y
% Redraw the plots of transormation and pdf of X.
%set(handles.aconst,'String','1');
%set(handles.bconst,'String','0');
plotPdfXtf(hObject,handles);




%--------------------------------------------------------------------------
% Define functions to draw plots of transformation and pdf of X
%--------------------------------------------------------------------------
% Plot pdf of X
function plotPdfXtf(hObject,handles)

axes(handles.axesPDFX);

valx = get(handles.pdfX,'Value');
strx = get(handles.pdfX, 'String');
a = str2double(get(handles.aparam,'String'));
b = str2double(get(handles.bparam,'String'));

% Set axes limit properties
switch strx{valx};
    case 'Uniform (a,b)'
        x = [a-(b-a)/10 a b b+(b-a)/10];
        f = [0 1/(b-a) 0 0];
        stairs(x,f);
        x = a-(b-a)/10:(b-a)/1000:b+(b-a)/10;
        set(handles.axesPDFX,'YLim',[0 1.1/(b-a)]);
        set(handles.axesPDFX,'YLimMode','manual');
        set(handles.axesPDFX,'XLim',[a-(b-a)/10 b+(b-a)/10]);
        set(handles.axesPDFX,'XLimMode','manual');
    case 'Exponential (a)'
        x = 0:a/100:10/a;
        f = a * exp(-a*x);
        plot(x,f);
        set(handles.axesPDFX,'XLim',[0 10/a]);
        set(handles.axesPDFX,'XLimMode','manual');
    case 'Gamma (a,b)'
        x = 0:b/1000:10/b;
        f = b^a.*exp(-b.*x(:)).*x(:).^(a-1) ./ gamma(a);
        plot(x,f);
        set(handles.axesPDFX,'XLim',[0 10/b]);
        set(handles.axesPDFX,'XLimMode','manual');
    case 'Normal (a,b)'
        x = a-4*sqrt(b):sqrt(b)/1000:a+4*sqrt(b);
        f = exp(-1/(2*b)*(x(:)-a).^2)/(sqrt(2*b*pi));
        plot(x,f);
        set(handles.axesPDFX,'XLim',[a-4*sqrt(b) a+4*sqrt(b)]);
        set(handles.axesPDFX,'XLimMode','manual');
    case 'Cauchy (a,b)'
        x = a-10*b:b/500:a+10*b;
        f = 1./(b+((x-a)/b).^2)./pi;
        plot(x,f);
        set(handles.axesPDFX,'XLim',[a-10*b a+10*b]);
        set(handles.axesPDFX,'XLimMode','manual');
end
set(handles.axesPDFX,'XAxisLocation','top');
set(handles.axesPDFX,'XTickLabel','');
set(handles.axesPDFX,'XTickLabelMode','manual');
set(handles.axesPDFX,'YTickLabel','');
set(handles.axesPDFX,'YTickLabelMode','manual');

%--------------------------------------------------------------------------
% Plot transform Y = f(X)

axes(handles.axesTF);

valt = get(handles.selectTF,'Value');
strt = get(handles.selectTF,'String');
ac = str2double(get(handles.aconst,'String'));
bc = str2double(get(handles.bconst,'String'));
tfunc = get(handles.tfFunction,'String');

switch strt{valt};
    case 'Y = aX + b'
        y = ac*x+bc;
    case 'Y = X^2'
        y = x.^2;
    case {'Monotonic','General'}
        X=x;
        y = eval(tfunc);
end
plot(x,y);
% Set axes limit properties
switch strx{valx};
    case 'Uniform (a,b)'
        set(handles.axesTF,'XLim',[a-(b-a)/10 b+(b-a)/10]);
        set(handles.axesTF,'XLimMode','manual');
    case 'Exponential (a)'
        set(handles.axesTF,'XLim',[0 10/a]);
        set(handles.axesTF,'XLimMode','manual');
    case 'Gamma (a,b)'
        set(handles.axesTF,'XLim',[0 10/b]);
        set(handles.axesTF,'XLimMode','manual');
    case 'Normal (a,b)'
        set(handles.axesTF,'XLim',[a-4*sqrt(b) a+4*sqrt(b)]);
        set(handles.axesTF,'XLimMode','manual');
    case 'Cauchy'
        set(handles.axesTF,'XLim',[a-10*b a+10*b]);
        set(handles.axesTF,'XLimMode','manual');
end
yrange = get(handles.axesTF,'YLim');
set(handles.tfymin,'String',num2str(yrange(1),3));
set(handles.tfymax,'String',num2str(yrange(2),3));


% Clear plot of pdf of Y
axes(handles.axesPDFY);
hold off;
plot(x,y,'w');
set(handles.axesPDFY,'YAxisLocation','right');
set(handles.axesPDFY,'YTickLabel','');
set(handles.axesPDFY,'YTickLabelMode','manual');
set(handles.axesPDFY,'XTickLabel','');
set(handles.axesPDFY,'XTickLabelMode','manual');
set(handles.pdfymax,'String','1');


% --- Executes during object creation, after setting all properties.
function pdfymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pdfymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function pdfymax_Callback(hObject, eventdata, handles)
% hObject    handle to pdfymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ymax = str2double(get(handles.pdfymax,'String'));
set(handles.axesPDFY,'XLim',[0 ymax]);

% Hints: get(hObject,'String') returns contents of pdfymax as text
%        str2double(get(hObject,'String')) returns contents of pdfymax as a double


% --- Executes during object creation, after setting all properties.
function tfymin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tfymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tfymin_Callback(hObject, eventdata, handles)
% hObject    handle to tfymin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ymin = str2double(get(handles.tfymin,'String'));
ymax = str2double(get(handles.tfymax,'String'));
set(handles.axesTF,'YLim',[ymin ymax]);
set(handles.axesPDFY,'YLim',[ymin ymax]);

% Hints: get(hObject,'String') returns contents of tfymin as text
%        str2double(get(hObject,'String')) returns contents of tfymin as a double


% --- Executes during object creation, after setting all properties.
function tfymax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tfymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function tfymax_Callback(hObject, eventdata, handles)
% hObject    handle to tfymax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

ymin = str2double(get(handles.tfymin,'String'));
ymax = str2double(get(handles.tfymax,'String'));
set(handles.axesTF,'YLim',[ymin ymax]);
set(handles.axesPDFY,'YLim',[ymin ymax]);

% Hints: get(hObject,'String') returns contents of tfymax as text
%        str2double(get(hObject,'String')) returns contents of tfymax as a double


