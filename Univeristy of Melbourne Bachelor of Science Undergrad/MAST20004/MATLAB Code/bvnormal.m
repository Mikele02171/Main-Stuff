

function bvnormal(option, first)
% BVNORMAL Interactive bivariate normal distribution

%Peter Dunn
%15 September 1998


if nargin==0,

   option=0;
   figure('Name','Interactive Bivariate Normal Distribution',  ...
          'Resize','off');

   %SET UP THE CANVAS
   border = 0.02;
   dimen1 = 0.20;

   %parameters window
   uicontrol('Style','Frame',  'Units','normalized',...
             'Position',[border border 1-2*border 0.2-border]);

   %options:
   uicontrol('Style','Frame',  'Units','normalized',...
             'Position',[0.76 0.2+border  0.24-border 1-0.2-2*border]);


   %Parameter `buttons'
   pbborder = 0.02;
   pbwidth = ( 1 - (2 * border) - 6*pbborder ) / 5;
   uicontrol('Style','text','String','mu x','Units','normalized',...
             'Position',[0.02+pbborder 0.14 pbwidth 0.05]);
   uicontrol('Style','Slider',  'Max',5,  'Min',-5,  ...
             'Callback','bvnormal(8);','value',0.0,...
             'tag','hmx', 'Units','normalized',  ...
             'Position',[0.02+pbborder 0.04 pbwidth 0.05]);
   uicontrol('Style','Edit','String','0.0','Units','normalized',...
             'Position',[0.02+pbborder 0.09 pbwidth 0.05],...
             'tag','hmxedit','Callback','bvnormal(9);');

   uicontrol('Style','text','String','mu y','Units','normalized',...
             'Position',[0.02+2*pbborder+pbwidth 0.14 pbwidth 0.05]);
   uicontrol('Style','Slider',  'Max',5,  'Min',-5,  ...
             'Callback','bvnormal(8);','value',0.0,...
             'tag','hmy', 'Units','normalized',  ...
             'Position',[0.02+2*pbborder + pbwidth 0.04 pbwidth 0.05]);
   uicontrol('Style','Edit','String','0.0','Units','normalized',...
             'Position',[0.02+2*pbborder + pbwidth 0.09 pbwidth 0.05],...
             'tag','hmyedit','Callback','bvnormal(9);');

   uicontrol('Style','text','String','sigma x','Units','normalized',...
             'Position',[0.02+3*pbborder + 2*pbwidth 0.14 pbwidth 0.05]);
   uicontrol('Style','Slider',  'Max',5,  'Min',0.1,...
             'Callback','bvnormal(8);',...
             'Value',1.0,'tag','hsx', 'Units','normalized',...
             'Position',[0.02+3*pbborder + 2*pbwidth 0.04 pbwidth 0.05]);
   uicontrol('Style','Edit','String','1.0','Units','normalized',...
             'Position',[0.02+3*pbborder + 2*pbwidth 0.09 pbwidth 0.05],...
             'tag','hsxedit','Callback','bvnormal(9);');

   uicontrol('Style','text','String','sigma y','Units','normalized',...
             'Position',[0.02+4*pbborder + 3*pbwidth 0.14 pbwidth 0.05]);
   uicontrol('Style','Slider',  'Max',5,  'Min',0.1,  ...
             'Callback','bvnormal(8);',...
             'Value',1.0,'tag','hsy', 'Units','normalized',  ...
             'Position',[0.02+4*pbborder + 3*pbwidth 0.04 pbwidth 0.05]);
   uicontrol('Style','Edit','String','1.0','Units','normalized',...
             'Position',[0.02+4*pbborder + 3*pbwidth 0.09 pbwidth 0.05],...
             'tag','hsyedit','Callback','bvnormal(9);');

   uicontrol('Style','text','String','rho','Units','normalized',...
             'Position',[0.02+5*pbborder + 4*pbwidth 0.14 pbwidth 0.05]);
   uicontrol('Style','Slider',  'Max',0.99,  'Min',-0.99,  ...
             'Callback','bvnormal(8);','value',0,...
             'tag','hrho', 'Units','normalized', ...
              'Position',[0.02+5*pbborder + 4*pbwidth 0.04 pbwidth 0.05]);
   uicontrol('Style','Edit','String','0.0','Units','normalized',...
             'Position',[0.02+5*pbborder + 4*pbwidth 0.09 pbwidth 0.05],...
             'tag','hrhoedit','Callback','bvnormal(9);');

   %options `buttons'

   oborder = 0.78;
   owidth =  0.18;
   oheight = 0.07;

   uicontrol('Style','Text','String','Type','Units','normalized',...
             'Position', [ oborder 0.96-0.08 owidth oheight] );
   uicontrol('Style','Popup','String','Mesh|Surf|B&W','Units','normalized',...
             'Position',[ oborder 0.96-2*0.08+0.03  owidth oheight],...
             'tag','htypeplot','value',1,...
             'Callback','bvnormal(10);');
 
   uicontrol('Style','Text','String','View','Units','normalized',...
             'Position', [ oborder 0.96-3*0.08 owidth oheight] );
   uicontrol('Style','Popup','String','Default|Overhead|Conditnl X|Conditnl Y', ...
             'tag','hview',...
             'Callback','bvnormal(1);','Units','normalized',...
             'Position',[ oborder 0.96-4*0.08+0.03  owidth oheight]);
 
   uicontrol('Style','Text','String','Elevation','Units','normalized',...
             'Position',[oborder 0.96-5*0.08 owidth oheight]);
   uicontrol('Style','Slider','Max',180,'Min',-180,'Units','normalized',...
             'Position',[ oborder 0.96-6*0.08+0.03 owidth 0.05],...
             'value',30.0,...
             'tag','helevation','Callback','bvnormal(2);');

   uicontrol('Style','Text','String','Azimuth','Units','normalized',...
             'Position',[oborder 0.96-7*0.08 owidth oheight]);
   uicontrol('Style','Slider','Max',180,'Min',-180,'Units','normalized',...
             'Position',[ oborder 0.96 - 8*0.08+0.03  owidth 0.05],...
             'value',-37.5,...
             'tag','hazimuth','Callback','bvnormal(3);');

   uicontrol('Style','Pushbutton','String','Close','Units','normalized',...
              'Position',[ oborder 0.25 owidth oheight], ...
              'Callback','close(gcf);');



   %PLOT THE FUNCTION
   axes('Position',[0.08 0.30 0.65 0.65 ])
   bvnormal(10, 1);


   %Now, after rotate3d had been done, we have to set the
   %elevation and azimuth slide controls to their proper values,
   %so we alter the WindowButtonUpFcn to include this change:

   cwbuf = get(gcf,'WindowButtonUpFcn');
   set(gcf,'WindowButtonUpFcn',[cwbuf,'; bvnormal(4);']);
   set(gcf,'HandleVisibility','Callback');

end;


if option == 1, %Changes the view

   value = get( findobj('tag','hview'), 'Value');

   if (value==1),     %default
      view(-37.5, 30);
      set( findobj('tag','hazimuth'),'value',-37.5);
      set( findobj('tag','helevation'),'value',30.0);
   elseif (value==2), %overhead
      view(0, 90);
      set( findobj('tag','hazimuth'),'value',0.0);
      set( findobj('tag','helevation'),'value',90.0);
   elseif (value==3), %conditional x
      view(0, 0);
      set( findobj('tag','hazimuth'),'value',0.0);
      set( findobj('tag','helevation'),'value',0.0);
   elseif (value==4), %conditional y
      view(90,0);
      set( findobj('tag','hazimuth'),'value',90.0);
      set( findobj('tag','helevation'),'value',90.0);
   end;

elseif (option==2), %Changes the elevation

   value = get( findobj('tag','helevation'), 'value');

   [az, el] = view;
   view(az, value);

elseif (option==3), %Changes the azimuth

   value = get( findobj('tag','hazimuth'), 'value');
   if value>180,
      value = 360-value;
      set( findobj('tag','hazimuth'), 'value', value );
   elseif value<-180
      value = 360+value;
      set( findobj('tag','hazimuth'), 'value', value );
   end;

   [az, el] = view;
   view(value, el);

elseif (option==4), %sets the azimuth and elevation after  rotate3d

   [az, el] = view;
   if az>180,
      az = 360-az;
      set( findobj('tag','hazimuth'), 'value', az );
   elseif az<-180
      az = 360+az;
      set( findobj('tag','hazimuth'), 'value', az );
   end;
   set( findobj('tag','hazimuth'),'value',az);

   set( findobj('tag','helevation'),'value',el);

elseif (option==8), %Parameters slid

   set( findobj('tag','hmxedit'),  ...
        'string', num2str(get(findobj('tag','hmx'),'value')) );

   set( findobj('tag','hmyedit'),  ...
        'string', num2str(get(findobj('tag','hmy'),'value')) );

   set( findobj('tag','hsxedit'),  ...
        'string', num2str(get(findobj('tag','hsx'),'value')) );

   set( findobj('tag','hsyedit'),  ...
        'string', num2str(get(findobj('tag','hsy'),'value')) );

   set( findobj('tag','hrhoedit'),  ...
        'string', num2str(get(findobj('tag','hrho'),'value')) );

   bvnormal(10);

elseif (option==9), %Parameters editted

   entval = str2num( get(findobj('tag','hmxedit'),'string') );
   if (entval < -5 ) 
      set( findobj('tag','hmxedit'),'string', '-5.0');
      entval = -5.0;
   elseif (entval > 5)
      set( findobj('tag','hmxedit'),'string', '5.0');
      entval = 5.0;
   end
   set( findobj('tag','hmx'), 'value', entval );

   entval = str2num( get(findobj('tag','hmyedit'),'string') );
   if (entval < -5 )
      set( findobj('tag','hmyedit'),'string', '-5.0');
      entval = -5.0;
   elseif (entval > 5)
      set( findobj('tag','hmyedit'),'string', '5.0');
      entval = 5.0;
   end
   set( findobj('tag','hmy'), 'value', entval );

   entval = str2num( get(findobj('tag','hsxedit'),'string') );
   if (entval < 0.1 )
      set( findobj('tag','hsxedit'),'string', '0.1');
      entval = 0.1;
   elseif (entval > 5)
      set( findobj('tag','hsxedit'),'string', '5.0');
      entval = 5.0;
   end
   set( findobj('tag','hsx'), 'value', entval );

   entval = str2num( get(findobj('tag','hsyedit'),'string') );
   if (entval < 0.1 )
      set( findobj('tag','hsyedit'),'string', '0.1');
      entval = 0.1;
   elseif (entval > 5)
      set( findobj('tag','hsyedit'),'string', '5.0');
      entval = 5.0;
   end
   set( findobj('tag','hsy'), 'value', entval );

   entval = str2num( get(findobj('tag','hrhoedit'),'string') );
   if (entval < -0.99 )
      set( findobj('tag','hrhoedit'),'string', '-0.99');
      entval = -0.99;
   elseif (entval > 0.99)
      set( findobj('tag','hrhoedit'),'string', '0.99');
      entval = 0.99;
   end
   set( findobj('tag','hrho'), 'value', entval );

   bvnormal(10);

elseif (option==10), %Changes the parameters

   %Return to view before the change...but on
   %first call, there is no view yet.  So we juggle it...
   %Thus, the second input,  first,  is just a flag to indicate this.
   if  nargin==2,
      el = get( findobj('tag','helevation'), 'value');
      az = get( findobj('tag','hazimuth'), 'value');
   else
      [az, el] = view;
   end;

   meanx = get(findobj('tag','hmx'), 'Value');
   meany = get(findobj('tag','hmy'), 'Value');
   stdx = get(findobj('tag','hsx'), 'Value');
   stdy = get(findobj('tag','hsy'), 'Value');
   rho = get(findobj('tag','hrho'), 'Value');

   [zx, zy] = meshgrid( linspace(-3.5, 3.5, 40), linspace(-3.5, 3.5, 40) );

   x = meanx + stdx*zx;
   y = meany + stdy*zy;

   Q = ( zx.^2 - 2*rho*zx.*zy + zy.^2 ) ./ ( 1 - rho^2 );

   z = exp( -0.5*Q ) ./ ( 2*pi*stdx*stdy*sqrt(1-rho^2) );

   how = get( findobj( 'tag','htypeplot' ), 'value');
   if (how==1),  %mesh
      hplot = mesh(x, y, z);
      colormap default;
   elseif (how==2),  %surface
      hplot = surf(x, y, z); 
      colormap default;
   elseif (how==3),  %black and white
      hplot = surf(x, y, z); 
      colormap gray; brighten(0.5);
   end

   view(az, el);

   rotate3d on;

   xlabel('x-axis');
   ylabel('y-axis');

   drawnow;

end
