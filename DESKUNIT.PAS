unit deskunit;

interface

uses crt,dos,turbo3,drivers,printer;

type select     = array[0..19] of string;
     menuitem   = record
                    menutext: string[25];
                    nummer  : integer;
                    help    : string[80];
                    key     : char;
                  end;
     menuitems  = array[1..20] of menuitem;

const maxcountcl  = 120000;
      maxcountncl = 3200000;

var nachricht :string;
    mhotkey,
    mhelptext,
    saver,
    clock     :boolean;
    mereig,
    tereig    :tevent;
    fkeys     :array[1..10] of string[15];
    ftast     :boolean;
    sicherung :array[1..25,1..80,1..2] of byte;
    count     :longint;
    savermsg  :string[70];

procedure drucke_datei(dateiname:string);
function tage_monat(monat:string):integer;
procedure screen_saver;
procedure frame(x,y,xl,yl,tcolour,tback:integer; titel:string);
procedure open_window(x,y,xl,yl,backcol,textcol:integer;titel:string);
procedure process_text(zeile:string);
procedure help(helptext:string);
procedure write_row(row:integer;textinhalt:string);
procedure init_desktop;
procedure init_statusline(zeilentext:string);
procedure clear_window(x,y,xl,yl:integer;backcol:integer);
procedure use_window(x,y,xl,yl,tcol,bcol:integer);
procedure unuse_window;
function datum:string;
function uhrzeit:string;
function yes(textzeile:string):boolean;
function upperline(zeile:string):string;
function checkkeyboard:char;
function exist(dateiname:string):boolean;
procedure prreturn;
procedure menuselect(anzahlpunkte:integer; items:menuitems; var selected:integer);
function input_boolean(x,y,colt,colb:integer; defa, defb:string; var msg:string):string;
function input_select(x,y,len,anz:integer; var beg:integer; colt,colb:integer; choice:select; var msg:string):string;
function input_field(x,y,len,colt,colb:integer; default:string; var msg:string):string;
function new_path(pfad:string):boolean;
procedure colorbox(x,y,xl,yl,tcol,tback:integer; titel:string);
procedure colorbox_close;

implementation

procedure drucke_datei;
var datei    :text;
    zeile    :string;
    counter  :integer;
begin
  counter:=0;
{  printererr:=false; }
  if not exist(dateiname) then exit;
  assign(datei,dateiname);
  reset(datei);
  while not eof(datei) do
  begin
    readln(datei,zeile);
    if pos(#12,zeile)<>0 then counter:=0;
    repeat
      {$I-}
      write(lst,zeile,#13,#10);
      {$I+}
      if IOresult<>0 then
      begin
        colorbox(20,11,43,2,white,red,'Drucker nicht bereit');
        gotoxy(1,1);
        write('Drucker bereitmachen und RETURN drcken');
        colorbox_close;
        prreturn;
        clear_window(20,11,44,4,black);
      end;
    until IOresult=0;
    inc(counter);
    if counter=66 then
    begin
      counter:=0;
      write(lst,#12);
    end;
  end;
  write(lst,#12);
  close(datei);
end;


function tage_monat;
const tage:array[1..12] of integer = (31,28,31,30,31,30,31,31,30,31,30,31);
var   code,tag   :integer;
begin
  if monat='Januar' then tage_monat:=tage[1];
  if monat='Februar' then tage_monat:=tage[2];
  if monat='M„rz' then tage_monat:=tage[3];
  if monat='April' then tage_monat:=tage[4];
  if monat='Mai' then tage_monat:=tage[5];
  if monat='Juni' then tage_monat:=tage[6];
  if monat='Juli' then tage_monat:=tage[7];
  if monat='August' then tage_monat:=tage[8];
  if monat='September' then tage_monat:=tage[9];
  if monat='Oktober' then tage_monat:=tage[10];
  if monat='November' then tage_monat:=tage[11];
  if monat='Dezember' then tage_monat:=tage[12];
end;


function exist;
var datname  :file;
begin
  assign(datname,dateiname);
  {$I-}
  reset(datname);
  {$I+}
  if IOresult<>0 then exist:=false
  else
  begin
    exist:=true;
    close(datname);
  end;
end;

procedure screen_saver;
var vga_screen    :array[1..25,1..80,1..2] of byte absolute $b800:$0000;
    x,y,a,c,c1    :integer;
    ch,t          :char;
    darstellung   :boolean;
begin
  darstellung:=true;
  if not saver then exit;
  for y:=1 to 25 do
    for x:=1 to 80 do
      for a:=1 to 2 do
        sicherung[y,x,a]:=vga_screen[y,x,a];
  for y:=1 to 25 do
    for x:=1 to 80 do
      for a:=1 to 2 do
        vga_screen[y,x,a]:=0;
  ch:=#0;
  c1:=0;
  x:=random(80-length(savermsg)-1)+1;
  y:=random(25)+1;
  repeat
    if keypressed then ch:=readkey;
    if not darstellung then
    begin
      x:=random(80-length(savermsg)-1)+1;
      y:=random(25)+1;
      c1:=0;
      darstellung:=true;
    end;
    for c:=1 to length(savermsg) do
    begin
      t:=savermsg[c];
      vga_screen[y,x+(c-1),1]:=ord(t);
      vga_screen[y,x+(c-1),2]:=31;
    end;
    inc(c1);
    if c1=20000 then
    begin
      darstellung:=false;
      for y:=1 to 25 do
        for x:=1 to 80 do
          for a:=1 to 2 do
            vga_screen[y,x,a]:=0;
    end;
  until ch<>#0;
  for y:=1 to 25 do
    for x:=1 to 80 do
      for a:=1 to 2 do
        vga_screen[y,x,a]:=sicherung[y,x,a];
    count:=0;
end;

function new_path;
var i                            :integer;
    ausgang,zeile,temppfad,drive :string;
    f,erstes                     :boolean;
begin
  erstes:=true;
  getdir(0,ausgang);
  drive:=copy(pfad,1,3);
  if drive[2]<>':' then
  begin
    new_path:=false;
    exit;
  end;
  if pfad[2]=':' then zeile:=copy(pfad,4,length(pfad))
  else zeile:=pfad;
  repeat
    temppfad:=copy(zeile,1,pos('\',zeile)-1);
    zeile:=copy(zeile,pos('\',zeile)+1,length(zeile));
    if pos('.',temppfad)=0 then
    begin
      if erstes then
      begin
        {$I-}
        chdir(drive+temppfad);
        {$I+}
        if IOresult<>0 then
        begin
          {$I-}
          mkdir(drive+temppfad);
          {$I+}
          if IOresult<>0 then
          begin
            new_path:=false;
            exit;
          end;
          chdir(drive+temppfad);
        end;
        erstes:=false;
      end
      else
      begin
        {$I-}
        chdir(temppfad);
        {$I+}
        if IOresult<>0 then
        begin
          {$I-}
          mkdir(temppfad);
          {$I+}
          if IOresult<>0 then
          begin
            new_path:=false;
            exit;
          end;
          chdir(temppfad);
        end;
      end;
    end;
  until temppfad='';
  chdir(ausgang);
  new_path:=true;
end;

procedure frame{(x,y,xl,yl,tcolour,tback:integer; titel:string)};
var i:integer;
begin
  textcolor(tcolour);
  textbackground(tback);
  gotoxy(x,y);
  write(copy('ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',1,xl));
  gotoxy(x+xl-1,y);
  write('¿');
  for i:=y+1 to y+yl-1 do
  begin
    gotoxy(x,i);
    write('³');
    gotoxy(x+xl-1,i);
    write('³');
  end;
  gotoxy(x,y+yl);
  write(copy('ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ',1,xl));
  gotoxy(x+xl-1,y+yl);
  write('Ù');
  if titel<>'' then
  begin
    gotoxy(trunc((x+xl/2)-(length(titel)+4)/2),y);
    write('´ ');
    textcolor(black);
    textbackground(white);
    write(titel);
    textcolor(tcolour);
    textbackground(tback);
    write(' Ã');
  end;
  textbackground(black);
  textcolor(white);
end;

procedure colorbox;

begin
  frame(x,y,xl,yl,tcol,tback,titel);
  textcolor(tcol);
  textbackground(tback);
  window(x+1,y+1,(x+xl)-2,(y+yl)-1);
  clrscr;
end;

procedure colorbox_close;

begin
  window(1,1,80,25);
  textcolor(lightgray);
  textbackground(black);
end;

procedure open_window{(x,y,xl,yl,backcol,textcol:integer;titel:string)};
begin
  window(x,y,x+xl-1,y+yl-1);
  textbackground(backcol);
  clrscr;
  window(1,1,80,25);
  frame(x,y,xl,yl,textcol,backcol,titel);
  textbackground(black);
  textcolor(white);
end;

procedure process_text{(zeile:string)};
var i   :integer;
    rot :boolean;
begin
  rot:=false;
  for i:=1 to length(zeile) do
  begin
    if (zeile[i]='~') and (not rot) then
    begin
      textcolor(red);
      rot:=true;
    end
    else
      if (zeile[i]='~') and (rot) then
      begin
        textcolor(black);
        rot:=false;
      end;
    if zeile[i]<>'~' then write(zeile[i]);
  end;
end;

procedure help{(helptext:hlpstring)};
begin
  gotoxy(1,25);
  textcolor(black);
  textbackground(white);
  write(' ':79);
  gotoxy(1,25);
  write(' ',helptext, copy('                                                         ',1,78-length(helptext)));
  normvideo;
end;

procedure write_row{(row:integer;textinhalt:string)};
begin
  textcolor(black);
  textbackground(white);
  gotoxy(1,row);
  write(' ':79);
  gotoxy(1,row);
  process_text(textinhalt);
  textcolor(white);
  textbackground(black);
end;

procedure init_desktop;
var i :integer;
begin
  clrscr;
  for i:=2 to 24 do
    write_row(i,copy('°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°',1,79));
  write_row(1,copy('',1,79));
  write_row(25,copy('',1,79));
end;

procedure init_statusline{(zeilentext:string)};
begin
  write_row(25,zeilentext);
end;

procedure clear_window{(x,y,xl,yl:integer;backcol:integer)};
begin
  window(x,y,x+xl-2,y+yl-2);
  textbackground(backcol);
  clrscr;
  textbackground(black);
  window(1,1,80,25);
end;

procedure use_window{(x,y,xl,yl,tcol,bcol:integer)};
begin
  window(x+1,y+1,x+xl-2,y+yl-2);
  textcolor(tcol);
  textbackground(bcol);
end;

procedure unuse_window;
begin
  window(1,1,80,25);
  textcolor(white);
  textbackground(black);
end;


function datum{:string};
var t,m,j,dw :word;
    jahr, monat, tag :string;
begin
  getdate(j,m,t,dw);
  str(j,jahr);
  str(m,monat);
  str(t,tag);
  if length(tag)=1 then tag:='0'+tag;
  if length(monat)=1 then monat:='0'+monat;
  datum:=tag+'.'+monat+'.'+jahr
end;

function uhrzeit:string;
var h,m,s,s1 :word;
    stunde, minute, sekunde :string;
begin
  gettime(h,m,s,s1);
  str(h,stunde);
  str(m,minute);
  str(s,sekunde);
  if length(stunde)=1 then stunde:='0'+stunde;
  if length(minute)=1 then minute:='0'+minute;
  if length(sekunde)=1 then sekunde:='0'+sekunde;
  uhrzeit:=stunde+':'+minute+':'+sekunde;
end;

function yes{(textzeile:string):boolean};
var ch  :char;
    ret :boolean;
begin
  ret:=false;
  if textzeile[1]='#' then
  begin
    textzeile:=copy(textzeile,2,length(textzeile));
    ret:=true;
  end;
  textzeile:=textzeile+'(J/N)?';
  gotoxy(1,25);
  textcolor(black);
  textbackground(white);
  write(' ':79);
  gotoxy(1,25);
  write(' ',textzeile, copy('                                                         ',1,78-length(textzeile)));
  normvideo;
  gotoxy(2+length(textzeile),25);
  repeat
    ch:=checkkeyboard;
    if ch=#255 then
      if mereig.where.y=24 then
      begin
        if mereig.where.x=length(textzeile)-4 then ch:='j';
        if mereig.where.x=length(textzeile)-2 then ch:='n';
      end;
    if (ret) and (ch=#13) then ch:='j';
    ch:=upcase(ch);
  until ch in ['J','N','Y'];
  if ch in ['J','Y'] then yes:=true
  else yes:=false;
end;

function upperline{(zeile:string):string};
var i :integer;
begin
  for i:=1 to length(zeile) do
    zeile[i]:=upcase(zeile[i]);
  upperline:=zeile;
end;

function checkkeyboard{:char};
var ch :char;
    xmem,ymem :integer;
    textmem :byte;
begin
  repeat
    getmouseevent(mereig);
    getkeyevent(tereig);
    inc(count);
    if clock and (count=maxcountcl) then screen_saver;
    if (not clock) and (count=maxcountncl) then screen_saver;
    xmem:=wherex;
    ymem:=wherey;
    if clock then
    begin
      textmem:=textattr;
      gotoxy(59,25);
      textcolor(black);
      textbackground(white);
      write(datum,' / ',uhrzeit);
      textattr:=textmem;
      gotoxy(xmem,ymem);
    end;
  until (tereig.what<>evnothing) or (mereig.buttons=mbleftbutton) or (mereig.buttons=mbrightbutton);
  count:=0;
  if mereig.buttons=mbleftbutton then
  begin
    checkkeyboard:=#255;
    exit;
  end;
  if mereig.buttons=mbrightbutton then
  begin
    checkkeyboard:=#27;
    exit;
  end;
  ch:=tereig.charcode;
  if tereig.keycode=kbup then ch:=chr(ord('H')+128);
  if tereig.keycode=kbdown then ch:=chr(ord('P')+128);
  if tereig.keycode=kbleft then ch:=chr(ord('K')+128);
  if tereig.keycode=kbright then ch:=chr(ord('M')+128);
  if tereig.keycode=kbend then ch:=chr(ord('O')+128);
  if tereig.keycode=kbhome then ch:=chr(ord('G')+128);
  if tereig.keycode=kbins then ch:=chr(ord('R')+128);
  if tereig.keycode=kbdel then ch:=chr(ord('S')+128);
  if tereig.keycode=kbesc then ch:=#27;
  if tereig.keycode=kbenter then ch:=#13;
  if tereig.keycode=kbshifttab then ch:=#143;
  checkkeyboard:=ch;
end;

procedure prreturn;
var ch :char;
begin
  repeat
    ch:=checkkeyboard;
  until (ch=#13) or (ch=#255);
end;

procedure menuselect{(anzahlpunkte:integer; items:menuitems; var selected:integer)};
var i,c,balken, bpos, balkenmax :integer;
    ch                          :char;
    hkeys                       :string;
begin
  balken:=1;
  bpos:=5;
  repeat
    hidemouse;
    hkeys:='';
    textcolor(lightgreen);
    textbackground(black);
    c:=5;
    balkenmax:=(anzahlpunkte+5)*2;
    for i:=1 to anzahlpunkte do
    begin
      gotoxy(25,c);
      inc(c,2);
      if mhotkey then
      begin
        write('  ',copy(items[i].menutext,1,pos(items[i].key,items[i].menutext)-1));
        textcolor(white);
        write(copy(items[i].menutext,pos(items[i].key,items[i].menutext),1));
        textcolor(lightgreen);
        write(copy(items[i].menutext,pos(items[i].key,items[i].menutext)+1,length(items[i].menutext)),'                   ');
        hkeys:=hkeys+items[i].key;
      end
      else
        write('  ',items[i].menutext,'                      ');
    end;
    gotoxy(25,bpos);
    textcolor(black);
    textbackground(white);
    write('  ',items[balken].menutext,copy('                     ',1,25-length(items[balken].menutext)));
    if mhelptext then
    begin
      textcolor(cyan);
      textbackground(black);
      gotoxy(1,24);
      write(' ':75);
      gotoxy(40-(trunc(length(items[balken].help)/2)),24);
      write(items[balken].help);
    end;
    showmouse;
    ch:=checkkeyboard;
    if mhotkey then
    begin
      i:=0;
      repeat
        inc(i);
      until (upcase(ch)=hkeys[i]) or (i>anzahlpunkte);
      if i<=anzahlpunkte then
      begin
        balken:=i;
        ch:=#13;
      end;
    end;
    if ch=#27 then
    begin
      if balken=anzahlpunkte then ch:=#13
      else
      begin
        balken:=anzahlpunkte;
        bpos:=3+anzahlpunkte*2;
      end;
    end;
    if ch=#255 then
    begin
      if (mereig.where.y+1>=5) and (mereig.where.y+1<=3+anzahlpunkte*2) then
        if (mereig.where.x+1>=25) and (mereig.where.x+1<=51) then
        begin
          balken:=0;
          case mereig.where.y+1 of
            5  : balken:=1;
            7  : balken:=2;
            9  : balken:=3;
            11 : balken:=4;
            13 : balken:=5;
            15 : balken:=6;
            17 : balken:=7;
            19 : balken:=8;
            20 : balken:=9;
          end;
          normvideo;
          selected:=balken;
          ch:=#0;
          exit;
        end;
    end
    else
      if ch=#255 then ch:=#0;
    case ch of
      chr(ord('H')+128) : begin
                            if bpos=5 then
                            begin
                              bpos:=3+anzahlpunkte*2;
                              balken:=anzahlpunkte;
                            end
                            else
                            begin
                              dec(bpos,2);
                              dec(balken);
                            end;
                          end;
      chr(ord('P')+128) : begin
                            if bpos>=3+anzahlpunkte*2 then
                            begin
                              bpos:=5;
                              balken:=1;
                            end
                            else
                            begin
                              inc(bpos,2);;
                              inc(balken);
                            end;
                          end;
      chr(ord('G')+128) : begin
                            bpos:=5;
                            balken:=1;
                          end;
      chr(ord('O')+128) : begin
                            bpos:=3+anzahlpunkte*2;
                            balken:=anzahlpunkte;
                          end;
    end;
  until ch=#13;
  selected:=balken;
  normvideo;
end;

function input_boolean{(x,y,colt,colb:integer; defa, defb:string; var msg:string):string};
var ch   :char;
    work :string;
    farben :byte;
begin
  farben:=textattr;
  msg:='';
  work:=defa;
  textcolor(colt);
  textbackground(colb);
  gotoxy(x,y);
  if length(defa)>=length(defb) then write(' ':length(defa));
  if length(defa)<length(defb) then write(' ':length(defb));
  gotoxy(x,y);
  write(work);
  repeat
    ch:=checkkeyboard;
    if ((ch=#32) or (ch=#205) or (ch=#203)) and (work=defa) then work:=defb
    else if ((ch=#32) or (ch=#203) or (ch=#205)) and (work=defb) then work:=defa;
    gotoxy(x,y);
    if length(defa)>=length(defb) then write(' ':length(defa));
    if length(defa)<length(defb) then write(' ':length(defb));
    gotoxy(x,y);
    write(work);
  until ch in [#200,#208,#13,#27];
  if ch=#27 then
  begin
    work:=defa;
    msg:='can';
  end;
  if ch=#200 then msg:='up';
  if ch=#208 then msg:='down';
  textattr:=farben;
  gotoxy(x,y);
  if length(defa)>=length(defb) then write(' ':length(defa));
  if length(defa)<length(defb) then write(' ':length(defb));
  gotoxy(x,y);
  write(work);
  input_boolean:=work;
end;

function input_select{(x,y,len,anz:integer var beg:integer; colt,colb:integer;choice:select; var msg:string):string};
var ch   :char;
    work :string;
    farben,zeiger :byte;
begin
  zeiger:=beg;
  farben:=textattr;
  msg:='';
  work:=choice[beg];
  textcolor(colt);
  textbackground(colb);
  gotoxy(x,y);
  write(' ':len);
  gotoxy(x,y);
  write(work);
  repeat
    gotoxy(x,y);
    write(' ':len);
    gotoxy(x,y);
    write(work);
    ch:=checkkeyboard;
    if (ch=#205) or (ch=#32) then
    begin
      if zeiger<anz-1 then inc(zeiger);
      work:=choice[zeiger];
    end
    else if (ch=#203) or (ch=#8) then
    begin
      if zeiger>0 then dec(zeiger);
      work:=choice[zeiger];
    end;
  until ch in [#255,#208,#200,#13,#27];
  if ch=#27 then
  begin
    msg:='can';
    work:=choice[beg];
    zeiger:=beg;
  end;
  if ch=#200 then msg:='up';
  if ch=#208 then msg:='down';
  textattr:=farben;
  gotoxy(x,y);
  write(work,' ':len-length(work));
  beg:=zeiger;
  input_select:=work;
end;

function input_field{(x,y,len,colt,colb:integer; default:string; var msg:string):string};
var work  :string;
    ch    :char;
    xp    :integer;
    farben:byte;
begin
  farben:=textattr;
  msg:='';
  work:=default;
  xp:=length(work)+1;
  gotoxy(x,y);
  textcolor(colt);
  textbackground(colb);
  write(' ':len);
  gotoxy(x,y);
  write(default);
  repeat
    ch:=checkkeyboard;
    if ftast then
    case tereig.keycode of
      kbf1  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[1])<=len then
                begin
                  write(work+fkeys[1]);
                  work:=work+fkeys[1];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf2  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[2])<=len then
                begin
                  write(work+fkeys[2]);
                  work:=work+fkeys[2];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf3  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[3])<=len then
                begin
                  write(work+fkeys[3]);
                  work:=work+fkeys[3];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf4  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[4])<=len then
                begin
                  write(work+fkeys[4]);
                  work:=work+fkeys[4];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf5  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[5])<=len then
                begin
                  write(work+fkeys[5]);
                  work:=work+fkeys[5];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf6  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[6])<=len then
                begin
                  write(work+fkeys[6]);
                  work:=work+fkeys[6];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf7  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[7])<=len then
                begin
                  write(work+fkeys[7]);
                  work:=work+fkeys[7];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf8  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[8])<=len then
                begin
                  write(work+fkeys[8]);
                  work:=work+fkeys[8];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf9  : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[9])<=len then
                begin
                  write(work+fkeys[9]);
                  work:=work+fkeys[9];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
      kbf10 : begin
                gotoxy(x,y);
                if length(work)+length(fkeys[10])<=len then
                begin
                  write(work+fkeys[10]);
                  work:=work+fkeys[10];
                end;
                xp:=length(work)+1;
                ch:=#0;
              end;
    end;
    if ch=#255 then ch:=#13;
    case ch of
      #203 : begin
               if xp>=1 then dec(xp);
               gotoxy(x+xp-1,y);
               if xp=0 then ch:=#200;
             end;
      #205 : begin
               if xp<=length(work)+1 then inc(xp);
               gotoxy(x+xp-1,y);
               if xp=length(work)+2 then ch:=#208;
             end;
      #199 : begin
               xp:=1;
               gotoxy(x+xp-1,y);
             end;
      #207 : begin
               xp:=length(work)+1;
               gotoxy(x+xp-1,y);
             end;
      #211 : begin
               if xp<length(work)+1 then
               begin
                 work:=copy(work,1,xp-1)+copy(work,xp+1,length(work));
                 gotoxy(x,y);
                 write(' ':len);
                 gotoxy(x,y);
                 write(work);
                 gotoxy(x+xp-1,y);
               end;
             end;
      #8   : begin
               if (xp<=length(work)+1) and (xp>1) then
               begin
                 work:=copy(work,1,xp-2)+copy(work,xp,length(work));
                 dec(xp);
                 gotoxy(x,y);
                 write(' ':len);
                 gotoxy(x,y);
                 write(work);
                 gotoxy(x+xp-1,y);
               end;
             end;
    end;
    if not (ch in [#0,#9,#13,#27,#143,#200,#208,#203,#205,#210,#8,#207,#199,#211]) and (length(work)<len) then
    begin
      work:=copy(work,1,xp-1)+ch+copy(work,xp,length(work));
      inc(xp);
      gotoxy(x,y);
      write(' ':len);
      gotoxy(x,y);
      write(work);
      gotoxy(x+xp-1,y);
    end;
  until ch in [#9,#13,#27,#143,#200,#208];
  if ch=#27 then
  begin
    work:=default;
    msg:='can';
  end;
  if (ch=#200) or (ch=#143) then msg:='up';
  if ch=#208 then msg:='down';
  textattr:=farben;
  gotoxy(x,y);
  write(' ':len);
  gotoxy(x+(len-length(work)),y);
  write(work);
  input_field:=work;
  textcolor(white);
  textbackground(black);
  textattr:=farben;
end;

begin
  count:=0;
  savermsg:='Die Anwendung l„uft noch!';
  mhotkey:=false;
  mhelptext:=false;
  ftast:=false;
  saver:=false;
  clock:=false;
end.
