{************************************************************************}
{* Dbase.Pas                                                            *}
{************************************************************************}

unit dbase;
{$B-,V-,I-}
interface {-------------------------------------------------------------}


uses dos;

const maxfelder = 50 ; {MaxFelder pro Datei}

type FeldStr = string[10];
     Dbfeld  = record
               name : FeldStr; {Feldname}
               typ  : char;    {Feldtyp}
               size : byte;    {FeldlÑnge}
               nk   : byte;    {Nachkomma}
               off  : word;
               end;

     DbStruktur = record
               felder : word;     {Anzahl der Felder}
               feld   : array[1..MaxFelder] of Dbfeld;
               datei  : file;     {I/O Datei}
               j,m,t  : byte;     {Datum d. letzten énderung}
               recs,              {DatensÑtze}
               Fpos   : longint ; {Datensatzzeiger}
               hdsize,            {HeaderlÑnge +1}
               rsize : word;     {Datensatzgrî·e +1}
               buff   : pointer;  {I/O Buffer}
               modi   : boolean;  {Flag f. geÑndert}
               end;

     Dbpointer = ^Dbstruktur;
     PathStr   = string[79];

var  Dbresult : integer;
     Dbeof    : boolean;

     {result > 0 I/O Fehler, 0 = ok, -1=ungÅltige Satznummer, -2 ung Feldn.}

{***** proceduren *****}
procedure DbUse(f:Dbpointer; name:string);        {Datei îffnen}
procedure DbClose(f:Dbpointer);                   {Datei schlie·en}
procedure DbGo(f:Dbpointer; p:longint);           {Zeiger bewegen}
procedure Dbskip(f:Dbpointer);                    {Satz vor}
function  DbRead(f:Dbpointer; Fname:FeldStr):string;{Feld auslesen}
procedure DbReadT(f:Dbpointer; Fname:FeldStr; var x);{dito TP Format}

procedure DbCreate(f:Dbpointer; name:string);      {Datei anlegen}
procedure DbAppend(f:Dbpointer);                   {Satz anhÑngen}
procedure DbReplace(f:Dbpointer; Fname:FeldStr; s:string); {F. schreiben}
procedure DbReplT(f:Dbpointer; Fname:FeldStr; var x); {Turbo Format}

procedure DbDelete(f:Dbpointer);                   {Satz lîschen}
procedure DbRecover(f:Dbpointer);                  {Satz wiederherstellen}
function DbDeleted(f:dbpointer) : boolean;         {Satz gelîscht ?}

implementation {---------------------------------------------------------}

type xa = array[0..$ff00] of byte;

var  header : record
              ID,j,m,t     : byte;
              recs         : longint;
              hdsize,rsize : word;
              dummy        : array[1..20] of byte;
              end;
     XFeld  : record
              name         : array[1..10] of char;
              dummy1       : byte;
              typ          : char;
              dummy2       : array[1..4] of byte;
              size,nk      : byte;
              dummy3       : array[1..14] of byte;
              end;
     FeldNr : word;

procedure FeldNummer(f:Dbpointer; Fname:string);
var i : word;
begin
  FeldNr :=1;
  while (FeldNr <= f^.felder) and (f^.feld[FeldNr].name<>fname) do inc(FeldNr);
  if FeldNr >f^.felder then
    DbResult :=-2
  else
    DbResult :=0;
end;

{Datei îffnen,  f: Dateizeiger    }
{            name: Name der Datei }

procedure DbUse(f:Dbpointer; name:string);
var I : word;
    L : byte;
    o : word;

begin
  fillchar(f^,sizeof(f^),0);
  if pos('.',name)=0 then name:=name+'.DBF';
  assign(f^.datei,name);
  reset(f^.datei,1) ;
  DbResult:= IOResult;
  if DbResult=0 then begin
    with f^ do begin
       blockread(datei,Header,SizeOf(Header));
       J:=header.j; m:=header.m; t:=header.t;
       recs:=header.recs; rsize:=header.rsize;
       felder:=(header.hdsize-$21) div $20;
       hdsize:=header.hdsize+1;
       o:=0;
       for i:=1 to felder do begin
         blockread(datei,Xfeld,SizeOf(XFeld));
         l:=1;
         while(l<=10)and(XFeld.name[l]<>#0) do inc(l);
         move(XFeld.name[1],feld[i].name[1],l-1);
         feld[i].name[0]:=chr(l-1);
         feld[i].typ:=XFeld.typ;
         feld[i].size:=XFeld.size;
         feld[i].nk:=XFeld.nk;
         feld[i].off:=o;
         inc(o,XFeld.size);
       end;
       modi:=false;
       DbEOF:=(recs=0);
       getmem(buff,rsize);
       If not DbEof then DbGo(f,1);
       FPos:=1
    end;
    DbResult:=IOResult;
  end;
end;

{ Datei schlie·en; f:Dateizeiger }

Procedure DbClose(f:Dbpointer);
var ja,ta,mo,wt : word;

begin
  with f^ do begin
    if modi then begin
      seek(datei,0);
      blockread(datei,header,SizeOf(header));
      GetDate(ja,mo,ta,wt);
      Header.j:=ja-1900; Header.m:=mo; Header.t:=ta;
      Header.recs:=recs;
      seek(datei,0);
      blockwrite(datei,header,SizeOf(Header));
    end;
    close(datei);
    freemem(buff,rsize);
  end;
  DbResult:=IOResult;
end;

{ Satzzeiger bewegen, f:Dateizeiger  }
{                     p:Neue Position}

Procedure DbGo(f:DbPointer; p:longint);

begin
  with f^ do
  if (p>recs) or (p<1) then
    DbResult:=-1
  else begin
    seek(datei,hdsize+(p-1)*rsize);
    blockread(datei,buff^,rsize);
    DbResult:=IOResult;
    Fpos:=p;
  end;
end;

{ Satzzeiger um 1 weiterbewegen, f:dateizeiger }

Procedure DbSkip(f:DbPointer);

begin
  with f^ do
  if Fpos>recs then
    DbEOF:=true
  else begin
    inc(Fpos);
    seek(datei,hdsize+(FPos-1)*rsize);
    blockread(datei,buff^,rsize);
  end;
  DbResult:=IOResult;
end;

{ Datensatz auslesen,  f:Dateizeiger   }
{                  fname:Feldname      }

Function DbRead(f:Dbpointer; fname: FeldStr) :string;
var h:string;

begin
  with f^ do
  if Fpos>recs then
    DbRead:=''
  else begin
    feldnummer(f,fname);
    if DbResult<0 then Dbread:=''
    else begin
      move(xa(buff^)[Feld[FeldNr].off],h[1],feld[FeldNr].size);
      h[0]:=chr(feld[FeldNr].size);
      DbRead:=h;
      DbResult:=0;
    end;
  end;
end;

{ Datensatz auslesen; RÅckgabe im Turbo-Pascal Format }
{  f        : Dateizeiger                             }
{  fname    : Feldname                                }
{  x        : RÅckgabevariable                        }

Procedure DbReadT(f:DbPointer; Fname:FeldStr; var x);
var h     : string;
    r     : real;
    res   : integer;

begin
  h:=Dbread(f,Fname);
  with f^ do
  if h<>'' then
    case feld[FeldNr].typ of
      'C' : begin
              while (h<>'') and (h[length(h)]=' ') do
              delete(h,length(h),1);
              string(x):=h;
            end;
      'N' : begin
              val(h,r,res);
              real(x):=r;
            end;
      'D' : string(x) :=copy(h,7,2)+'.'+copy(h,5,2)+'.'+copy(h,1,4);
      'L' : boolean(x):=(h='J') or (h='T');
  end;
end;

{ Datei anlegen,     f     : Dateizeiger }
{                    fname : Feldname    }

Procedure DbCreate(f:Dbpointer; name:string);
var       i : word;
          o : word;
          x : array[1..2] of char;

          ta,mo,ja,wt : word;

begin
  if pos('.',name)=0 then name:=name+'.DBF';
  assign(f^.datei,name);
  rewrite(f^.datei,1) ;
  DbResult:= IOResult;
  if DbResult=0 then begin
    with f^ do begin
      fillchar(Header,Sizeof(Header),0);
      Header.Id:=3;
      GetDate(ja,mo,ta,wt);
      Header.j:=ja-1900; Header.m:=mo; Header.t:=ta;
      Header.Hdsize:=felder*$20+$21;
      rsize:=1;
      for i:=1 to felder do begin
        if feld[i].typ='D' then feld[i].size:=8;
        if feld[i].typ='L' then feld[i].size:=1;
        inc(rsize,feld[i].size);
      end;
      Header.rsize:=rsize;
      blockwrite(datei,Header,SizeOf(header));
      hdsize:=header.hdsize+1;
      o:=0;
      for i:=1 to felder do begin
        fillchar(XFeld,SizeOf(Xfeld),0);
        move(Feld[i].name[1],Xfeld.name,length(Feld[i].name));
        XFeld.typ:=Feld[i].typ;
        XFeld.size:=Feld[i].size;
        if Feld[i].typ='N' then XFeld.nk:=Feld[i].nk;
        blockwrite(datei,XFeld,SizeOf(XFeld));
        feld[i].off:=o;
        inc(o,feld[i].size);
      end;
      modi:=false;
      DbEof:=true;
      getmem(buff,rsize+1);
      recs:=0;
      fpos:=1;
      x[1]:=^M;
      x[2]:=^Z;
      blockwrite(datei,x,2);
    end;
    DbResult:=IOResult;
  end;
end;

{leere Satz anhÑngen,  f   : Dateizeiger}

Procedure DbAppend(f:DbPointer);

begin
 with f^ do begin
   inc(recs);
   fillchar(buff^,rsize,' ');
   xa(buff^)[rsize]:=$1a;
   seek(datei,hdsize+(recs-1)*rsize-1);
   blockwrite(datei,buff^,rsize+1);
   FPos:=recs;
   modi:=true;
 end;
 DbResult:=IOResult;
end;

{ Feld schreiben      f     : Dateizeiger  }
{                     fname : Feldname     }
{                     s     : neuer Inhalt }

Procedure DbReplace(f:DbPointer; Fname:FeldStr; S :string);

begin
  with f^ do
  if (FPos>recs) or (FPos<1) then
    DbResult:=-3
  else begin
    FeldNummer(f,Fname);
    if DbResult=0 then begin
       fillchar(buff^,rsize,' ');
       move(s[1],buff^,length(copy(s,1,feld[FeldNr].size)));
       seek(datei,hdsize+(Fpos-1)*rsize+feld[feldnr].off);
       blockwrite(datei,buff^,feld[feldnr].size);
       modi:=true;
       DbResult:=IOResult;
     end;
  end;
end;

{ Feld schreiben öbergabe in Turbo-Pascal Format  }
{                f      : Dateizeiger             }
{                fname  : Feldname                }
{                x      : zu schreibende Variable }

Procedure DbReplT(f:Dbpointer ; Fname:Feldstr;var x);
var h : string;

begin
 Feldnummer(f, fname);
 if Dbresult=0 then
   with f^ do begin
    case feld[FeldNr].typ of
      'C' : h:=string(x);
      'N' : str(real(x):feld[feldnr].size:feld[feldnr].nk,h);
      'D' : begin
             h:=string(x); h:=copy(h,7,4)+copy(h,4,2)+copy(h,1,2);
            end;
      'L' : if boolean(x) then h:='T' else h:='F';
    end;
    DbReplace(f, fname, h);
  end;
end;


Procedure SetDelFlag(f:Dbpointer; c:char);

begin
  with f^ do begin
   if (FPos>recs) or (FPos<1) then exit;
   seek(datei,hdsize+(Fpos-1)*rsize-1);
   blockwrite(datei,c,1);
   DbResult:=IOResult;
 end;
end;

Procedure DbDelete(F:Dbpointer);

begin
  SetDelFlag(f,'*');
end;

Procedure DbRecover(F:Dbpointer);

begin
  SetDelFlag(f,' ');
end;

Function DbDeleted(f:DbPointer) :boolean;
var c : char;

begin
  with f^ do
   if (FPos>recs) or (FPos<1) then DbDeleted:=false
   else begin
    seek(datei,hdsize+(Fpos-1)*rsize-1);
    blockread(datei,c,1);
    DbResult:=IOResult;
    DbDeleted:=(c='*');
   end;
end;
end.
