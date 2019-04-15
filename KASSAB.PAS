program kassierer_abrechnung;

{$define siemens}

uses crt,dos,turbo3,dbase,drivers,deskunit,printer;

const copyright='(c)1993 M.Reimann';
      version='~V1.01b~';
      lizenz='SHAREWARE-VERSION';
      firma1='SHAREWARE-VERSION';
      firma2='- Veranstaltungsservice -';
      dreissig='                              ';
      passwd='NAWIBO';
      pause   : string[4] = ('|/-\');
      monatek : array [1..12] of string[3] = ('JAN','FEB','MR','APR','MAI',
                                              'JUN','JUL','AUG','SEP','OKT',
                                              'NOV','DEZ');
      monatel : array [1..12] of string[10] = ('Januar','Februar','M„rz',
                                               'April','Mai','Juni','Juli',
                                               'August','September',
                                               'Oktober','November','Dezember');


type persadr = record
                 persnr,
                 name,
                 zus1,
                 zus2,
                 strasse,
                 ort,
                 telefon,
                 fax,
                 bank,
                 kto,
                 blz,
                 versnr,
                 geburtsdat,
                 geburtsort,
                 krankenkasse       :string[80];
               end;

type stunde = array[1..32] of record
                                arbeitsdatum :string[10];
                                anzstd,
                                stdlohn,
                                gesamt       :real;
                              end;


type stunden = record
                 persnr   :string;
                 name     :string[80];
                 monat    :string[10];
                 jahr     :string[4];
                 nachweis :stunde;
               end;


var adrdatei    :file of persadr;
    datenbank   :file of stunden;
    db          :stunden;
    vvadresse   :persadr;
    i           :integer;
    zeile       :string;
    kopftext    :string;
    printererr  :boolean;


procedure drucke_datei(dateiname:string);
var datei    :text;
    zeile    :string;
    counter  :integer;
begin
  counter:=0;
  printererr:=false;
  if not exist(dateiname) then exit;
  assign(datei,dateiname);
  reset(datei);
  while not eof(datei) do
  begin
    readln(datei,zeile);
    if pos(#12,zeile)<>0 then counter:=0;
    repeat
      {$I-}
      writeln(lst,zeile);
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

procedure screen_init(titeltext:string);
begin
  textcolor(white);
  textbackground(black);
  clrscr;
  write_row(1,'  PERS-Abrechungssystem, '+version+', '+copyright+'      '+titeltext);
  write_row(25,' Diese Version ist eine ~'+lizenz+'~         '+datum+' / '+uhrzeit);
end;

function monatnummer(monatstr:string):integer;
var i  :integer;
begin
  i:=0;
  repeat
    inc(i);
  until (monatstr=monatel[i]) or (i>12);
  monatnummer:=i;
end;

function adreingabe(var vorgabe:persadr):boolean;
var x,code                                                   :integer;
    vvn,rbn,z1,z2,st,ot,tel,fx,bnk,k,bl,geb,gebo,vers,msg    :string;
    ende                                                     :boolean;
begin
  ende:=false;
  hidemouse;
  x:=1;
  help('Bitte Maske ausfllen, RETURN in der letzten Zeile=Speichern, ESC=Abbruch');
  textcolor(lightcyan);
  gotoxy(3,5);
  write('Pers.-Nr.: ');
  gotoxy(3,6);
  write('Name     : ');
  gotoxy(3,7);
  write('Zusatz 1 : ');
  gotoxy(3,8);
  write('Zusatz 2 : ');
  gotoxy(3,9);
  write('Straáe   : ');
  gotoxy(3,10);
  write('Ort      : ');
  gotoxy(3,11);
  write('Telefon  : ');
  gotoxy(3,12);
  write('Faxnummer: ');
  gotoxy(3,14);
  write('Bank     : ');
  gotoxy(3,15);
  write('Konto    : ');
  gotoxy(3,16);
  write('BLZ      : ');
  gotoxy(3,18);
  write('Geb-Datum: ');
  gotoxy(3,19);
  write('Geb-Ort  : ');
  gotoxy(3,20);
  write('Vers.-Nr.: ');
  with vorgabe do
  begin
    vvn:=persnr;
    rbn:=name;
    z1:=zus1;
    z2:=zus2;
    st:=strasse;
    ot:=ort;
    tel:=telefon;
    fx:=fax;
    bnk:=bank;
    k:=kto;
    bl:=blz;
    vers:=versnr;
    geb:=geburtsdat;
    gebo:=geburtsort;
  end;
  textcolor(black);
  textbackground(white);
  gotoxy(14,5);
  write(vvn,' ':3-length(vvn));
  gotoxy(14,6);
  write(rbn,' ':30-length(rbn));
  gotoxy(14,7);
  write(z1,' ':30-length(z1));
  gotoxy(14,8);
  write(z2,' ':30-length(z2));
  gotoxy(14,9);
  write(st,' ':30-length(st));
  gotoxy(14,10);
  write(ot,' ':30-length(ot));
  gotoxy(14,11);
  write(tel,' ':15-length(tel));
  gotoxy(14,12);
  write(fx,' ':15-length(fx));
  gotoxy(14,14);
  write(bnk,' ':30-length(bnk));
  gotoxy(14,15);
  write(k,' ':12-length(k));
  gotoxy(14,16);
  write(bl,' ':8-length(bl));
  gotoxy(14,18);
  write(geb,' ':10-length(geb));
  gotoxy(14,19);
  write(gebo,' ':30-length(gebo));
  gotoxy(14,20);
  write(vers,' ':15-length(vers));
  repeat
    case x of
      1 : begin
            textcolor(black);
            textbackground(white);
            vvn:=input_field(14,5,3,white,blue,vvn,msg);
            if msg='up'then x:=11;
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      2 : begin
            textcolor(black);
            textbackground(white);
            rbn:=input_field(14,6,30,white,blue,rbn,msg);
            gotoxy(14,6);
            write(rbn,' ':30-length(rbn));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      3 : begin
            textcolor(black);
            textbackground(white);
            z1:=input_field(14,7,30,white,blue,z1,msg);
            gotoxy(14,7);
            write(z1,' ':30-length(z1));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      4 : begin
            textcolor(black);
            textbackground(white);
            z2:=input_field(14,8,30,white,blue,z2,msg);
            gotoxy(14,8);
            write(z2,' ':30-length(z2));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      5 : begin
            textcolor(black);
            textbackground(white);
            st:=input_field(14,9,30,white,blue,st,msg);
            gotoxy(14,9);
            write(st,' ':30-length(st));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      6 : begin
            textcolor(black);
            textbackground(white);
            ot:=input_field(14,10,30,white,blue,ot,msg);
            gotoxy(14,10);
            write(ot,' ':30-length(ot));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      7 : begin
            textcolor(black);
            textbackground(white);
            tel:=input_field(14,11,15,white,blue,tel,msg);
            gotoxy(14,11);
            write(tel,' ':15-length(tel));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      8 : begin
            textcolor(black);
            textbackground(white);
            fx:=input_field(14,12,15,white,blue,fx,msg);
            gotoxy(14,12);
            write(fx,' ':15-length(fx));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      9 : begin
            textcolor(black);
            textbackground(white);
            bnk:=input_field(14,14,30,white,blue,bnk,msg);
            gotoxy(14,14);
            write(bnk,' ':30-length(bnk));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     10 : begin
            textcolor(black);
            textbackground(white);
            k:=input_field(14,15,12,white,blue,k,msg);
            gotoxy(14,15);
            write(k,' ':12-length(k));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     11 : begin
            textcolor(black);
            textbackground(white);
            bl:=input_field(14,16,8,white,blue,bl,msg);
            gotoxy(14,16);
            write(bl,' ':8-length(bl));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     12 : begin
            textcolor(black);
            textbackground(white);
            geb:=input_field(14,18,10,white,blue,geb,msg);
            gotoxy(14,18);
            write(geb,' ':10-length(geb));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     13 : begin
            textcolor(black);
            textbackground(white);
            gebo:=input_field(14,19,30,white,blue,gebo,msg);
            gotoxy(14,19);
            write(gebo,' ':30-length(gebo));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     14 : begin
            textcolor(black);
            textbackground(white);
            vers:=input_field(14,20,15,white,blue,vers,msg);
            gotoxy(14,20);
            write(vers,' ':15-length(vers));
            if msg='up'then dec(x);
            if msg='down' then x:=1;
            if (msg='') and (vvn<>'') then ende:=true
            else if (msg='') then x:=1;
          end;
      end;
    until (ende) or (msg='can');
    if msg='can' then adreingabe:=false
    else
    begin
      adreingabe:=true;
      with vorgabe do
      begin
        persnr:=vvn;
        name:=rbn;
        zus1:=z1;
        zus2:=z2;
        strasse:=st;
        ort:=ot;
        telefon:=tel;
        fax:=fx;
        bank:=bnk;
        kto:=k;
        blz:=bl;
        versnr:=vers;
        geburtsdat:=geb;
        geburtsort:=gebo;
      end;
    end;
end;

function t(wert:real):real;
var m :real;
    i :integer;
begin
{  m:=wert*100;
  i:=trunc(wert);
  t:=i/100; }
  t:=(trunc(wert*100))/100;
end;

function wirklich:boolean;
var ch :char;
begin
  colorbox(35,17,36,2,white,green,'EINGABE SPEICHERN');
  write('Eingabe wirklich speichern (J/N)?');
  colorbox_close;
  wirklich:=yes('Eingabe wirklich speichern ');
end;

procedure neuerfassung;
var erfasst       :boolean;
    neuadr,pruef  :persadr;
begin
  with neuadr do
  begin
    persnr:='';
    name:='';
    zus1:='';
    zus2:='';
    strasse:='';
    ort:='';
    telefon:='';
    fax:='';
    bank:='';
    kto:='';
    blz:='';
    geburtsdat:='';
    geburtsort:='';
    versnr:='';
  end;
  repeat
    screen_init('Neuerfassung');
    clock:=false;
    erfasst:=adreingabe(neuadr);
    clock:=true;
    if not erfasst then exit;
    if erfasst and wirklich then
    begin
      reset(adrdatei);
      if filesize(adrdatei)>0 then
      begin
        i:=0;
        repeat
          seek(adrdatei,i);
          read(adrdatei,pruef);
          if pruef.persnr=neuadr.persnr then i:=-2;
          inc(i);
        until (i=filesize(adrdatei)) or (i=-1);
        if i=-1 then erfasst:=false;
      end;
      close(adrdatei);
    end;
  until erfasst;
  reset(adrdatei);
  seek(adrdatei,filesize(adrdatei));
  write(adrdatei,neuadr);
  close(adrdatei);
end;

function findeadr(var zusuchen:persadr):integer;
var vvn,rbn,msg           :string;
    x                     :integer;
    ende                  :boolean;
    pruef                 :persadr;
begin
  clock:=false;
  textcolor(lightcyan);
  gotoxy(3,5);
  write('Pers.-Nr.: ');
  gotoxy(3,6);
  write('Name     : ');
  textcolor(black);
  textbackground(white);
  gotoxy(14,5);
  write(' ':3);
  gotoxy(14,6);
  write(' ':30);
  x:=1;
  vvn:='';
  rbn:='';
  ende:=false;
  help('Bitte entweder Personal Nr. oder Name eingeben');
  repeat
    case x of
      1 : begin
            textcolor(black);
            textbackground(white);
            vvn:=input_field(14,5,3,white,blue,vvn,msg);
            if msg='up'then x:=2;
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      2 : begin
            textcolor(black);
            textbackground(white);
            rbn:=input_field(14,6,30,white,blue,rbn,msg);
            gotoxy(14,6);
            write(rbn,' ':30-length(rbn));
            if msg='up'then dec(x);
            if msg='down' then x:=1;
            if msg='' then ende:=true;
          end;
    end;
  until (ende) or (msg='can');
  if (msg='can') or ((rbn='') and (vvn='')) then
  begin
    findeadr:=-1;
    clock:=true;
    exit;
  end;
  x:=0;
  if not exist('ADRESS.DAT') then
  begin
    findeadr:=-1;
    clock:=true;
    exit;
  end;
  reset(adrdatei);
  repeat
    seek(adrdatei,x);
    read(adrdatei,pruef);
    textcolor(lightcyan);
    textbackground(black);
    gotoxy(5,7);
    write('Suche  : ');
    textcolor(white);
    write(pause[(x mod 4)+1]);
    if (vvn='') and (rbn<>'') then
    begin
      if pruef.name=rbn then
      begin
        findeadr:=x;
        close(adrdatei);
        clock:=true;
        exit;
      end;
    end;
    if (vvn<>'') and (rbn='') then
    begin
      if pruef.persnr=vvn then
      begin
        findeadr:=x;
        close(adrdatei);
        clock:=true;
        exit;
      end;
    end;
    if (vvn<>'') and (rbn<>'') then
    begin
      if (pruef.persnr=vvn) and (pruef.name=rbn) then
      begin
        findeadr:=x;
        close(adrdatei);
        clock:=true;
        exit;
      end;
    end;
    inc(x);
  until x=filesize(adrdatei);
  findeadr:=-1;
  close(adrdatei);
  clock:=true;
end;

procedure aenderung;
var posi             :integer;
    suchen,pruef     :persadr;
    geaendert        :boolean;
    vv               :string;
begin
  screen_init('Adress„nderung');
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  close(adrdatei);
  vv:=suchen.persnr;
  repeat
    screen_init('Adress„nderung');
    clock:=false;
    geaendert:=adreingabe(suchen);
    clock:=true;
    if not geaendert then exit;
    if (vv<>suchen.persnr) and geaendert and wirklich then
    begin
      reset(adrdatei);
      if filesize(adrdatei)>0 then
      begin
        i:=0;
        repeat
          seek(adrdatei,i);
          read(adrdatei,pruef);
          if pruef.persnr=suchen.persnr then i:=-2;
          inc(i);
        until (i=filesize(adrdatei)) or (i=-1);
        if i=-1 then geaendert:=false;
      end;
      close(adrdatei);
    end
    else
      if wirklich then geaendert:=true
      else exit;
  until geaendert;
  reset(adrdatei);
  seek(adrdatei,posi);
  write(adrdatei,suchen);
  close(adrdatei);
end;

function wloeschen:boolean;
var ch :char;
begin
  colorbox(35,17,34,2,white,green,'ADRESSE L™SCHEN');
  write('Adresse wirklich l”schen (J/N)?');
  colorbox_close;
  wloeschen:=yes('Adresse wirklich l”schen ');
end;

procedure loeschen;
var posi           :integer;
    suchen         :persadr;
begin
  screen_init('Adressl”schung');
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  close(adrdatei);
  screen_init('Adressl”schung');
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(3,5);
  write('Pers.-Nr.: ');
  gotoxy(3,6);
  write('Name     : ');
  gotoxy(3,7);
  write('Zusatz 1 : ');
  gotoxy(3,8);
  write('Zusatz 2 : ');
  gotoxy(3,9);
  write('Straáe   : ');
  gotoxy(3,10);
  write('Ort      : ');
  gotoxy(3,11);
  write('Telefon  : ');
  gotoxy(3,12);
  write('Faxnummer: ');
  gotoxy(3,14);
  write('Bank     : ');
  gotoxy(3,15);
  write('Konto    : ');
  gotoxy(3,16);
  write('BLZ      : ');
  gotoxy(3,18);
  write('Geb-Datum: ');
  gotoxy(3,19);
  write('Geb-Ort  : ');
  gotoxy(3,20);
  write('Vers.-Nr.: ');
  textcolor(white);
  with suchen do
  begin
    gotoxy(14,5);
    write(persnr);
    gotoxy(14,6);
    write(name);
    gotoxy(14,7);
    write(zus1);
    gotoxy(14,8);
    write(zus2);
    gotoxy(14,9);
    write(strasse);
    gotoxy(14,10);
    write(ort);
    gotoxy(14,11);
    write(telefon);
    gotoxy(14,12);
    write(fax);
    gotoxy(14,14);
    write(bank);
    gotoxy(14,15);
    write(kto);
    gotoxy(14,16);
    write(blz);
    gotoxy(14,18);
    write(geburtsdat);
    gotoxy(14,19);
    write(geburtsort);
    gotoxy(14,20);
    write(versnr);
  end;
  if wloeschen then
  begin
    reset(adrdatei);
    seek(adrdatei,posi);
    suchen.persnr:='$$$$$';
    write(adrdatei,suchen);
    close(adrdatei);
  end;
end;

procedure listen;
var i,y,beg,x :integer;
    auswahl   :select;
    ausgabe,
    msg       :string;
    listdr    :text;
begin
  reset(adrdatei);
  if filesize(adrdatei)=0 then exit;
  screen_init('Personalliste');
  help('Bitte Ausgabeger„t mit dem Pfeiltasten w„hlen, ESC=Abbruch');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Ausgabe auf: ');
  auswahl[0]:='Bildschirm';
  auswahl[1]:='Drucker';
  beg:=0;
  ausgabe:=input_select(18,5,11,2,beg,white,blue,auswahl,msg);
  if msg='can' then exit;
  if ausgabe='Bildschirm' then
  begin
    textcolor(white);
    gotoxy(1,4);
    write('Nummer Name                          Zusatz                   Telefon');
    textcolor(cyan);
    y:=5;
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,vvadresse);
      textcolor(cyan);
      if vvadresse.persnr<>'$$$$$' then
      begin
        gotoxy(3,y);
        write(vvadresse.persnr:4,' ',vvadresse.name+copy(dreissig,1,30-length(vvadresse.name)));
        write(vvadresse.zus1+copy(dreissig,1,25-length(vvadresse.zus1)),vvadresse.telefon);
        inc(y);
      end;
      if y mod 22=0 then
      begin
        help('Bitte RETURN drcken ...');
        prreturn;
        screen_init('Personalliste');
        textcolor(white);
        gotoxy(1,4);
        write('Nummer Name                          Zusatz                   Telefon');
        textcolor(cyan);
        y:=5;
      end;
    end;
  end
  else
  begin
    assign(listdr,'LISTE.TXT');
    rewrite(listdr);
    writeln(listdr,'');
    writeln(listdr,'Liste der Aushilfen');
    writeln(listdr,'Stand: ',datum);
    writeln(listdr,'');
    x:=1;
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,vvadresse);
      if vvadresse.persnr<>'$$$$$' then
      begin
       with vvadresse do
       begin
         writeln(listdr,'PersNr.   : ',persnr);
         writeln(listdr,'Name      : ',name);
         writeln(listdr,'Zusatz 1  : ',zus1);
         writeln(listdr,'Zusatz 2  : ',zus2);
         writeln(listdr,'Straáe    : ',strasse);
         writeln(listdr,'Ort       : ',ort);
         writeln(listdr,'Telefon   : ',telefon);
         writeln(listdr,'VersNr.   : ',versnr);
         writeln(listdr,'Geb.Datum : ',geburtsdat);
         writeln(listdr,'Bank      : ',bank,' BLZ (',blz,')');
         writeln(listdr,'Konto     : ',kto);
         writeln(listdr,'');
         writeln(listdr,'-----------------------------------------------------------------------');
         writeln(listdr,'');
         inc(x);
         if x mod 4 = 0 then
         begin
           writeln(listdr,#12);
         end;
       end;
      end;
    end;
    writeln(listdr,'Gedruck mit PERSABRECHNUNG, ',version,' ',copyright);
    close(listdr);
    drucke_datei('LISTE.TXT');
  end;
  close(adrdatei);
  help('Bitte RETURN drcken ...');
  prreturn;
end;

procedure adrevamen;
var menu     :menuitems;
    auswahl  :integer;
    passwort :string;
    msg      :string;
begin
  screen_init('Adressverwaltung');
  mhotkey:=true;
  mhelptext:=true;
  clock:=false;
  help('Bitte Zungangscode eingeben, oder ESC fr Abbruch');
  colorbox(25,10,31,4,white,red,'Zugangskontrolle');
  gotoxy(2,2);
  write('Bitte Zugangscode eingeben:');
  passwort:=upperline(input_field(2,3,10,red,red,'',msg));
  if msg='can' then
  begin
    colorbox_close;
    exit;
  end;
  if passwort<>passwd then
  begin
    colorbox_close;
    exit;
  end;
  colorbox_close;
  clock:=true;
  showmouse;
  menu[1].menutext:='Neuerfassung';
  menu[1].help:='Mitarbeiter neu aufnehmen';
  menu[1].key:='N';
  menu[2].menutext:='nderung';
  menu[2].help:='Mitarbeiterdaten bearbeiten';
  menu[2].key:='';
  menu[3].menutext:='L”schen';
  menu[3].help:='Mitarbeiterdaten l”schen';
  menu[3].key:='L';
  menu[4].menutext:='Liste erstellen';
  menu[4].help:='Liste aller Mitarbeiter';
  menu[4].key:='i';
  menu[5].menutext:='Zurck ins Hauptmen';
  menu[5].help:='Ins Hauptmen wechseln';
  menu[5].key:='Z';
  repeat
    screen_init('Adressverwaltung');
    menuselect(5,menu,auswahl);
    case auswahl of
      1  : neuerfassung;
      2  : aenderung;
      3  : loeschen;
      4  : listen;
    end;
  until (auswahl=5);
  hidemouse;
end;

procedure erfassen;
var posi,
    beg,j    :integer;
    suchen   :persadr;
    datei,
    abmon,
    abjahr,
    msg,
    tag,
    st,
    stl,
    mo,
    pausch    :string;
    moint    :integer;
    stddat   :file of stunden;
    std      :stunden;
    x,
    tagnum,
    code     :integer;
    auswahl  :select;
    px,py    :integer;
    ges      :real;
begin
  clock:=false;
  for x:=0 to 11 do
    auswahl[x]:=monatel[x+1];
  screen_init('Stunden erfassen');
  clock:=false;
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  screen_init('Stunden erfassen');
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(3,5);
  write('Pers.-Nr.: ');
  gotoxy(3,6);
  write('Name     : ');
  textcolor(white);
  gotoxy(14,5);
  write(suchen.persnr);
  gotoxy(14,6);
  write(suchen.name);
  datei:=suchen.persnr+'.DAT';
  assign(stddat,datei);
  {$I-}
  reset(stddat);
  {$I+}
  if IOresult<>0 then
  begin
    x:=1;
    beg:=0;
    val(copy(datum,4,2),beg,code);
    dec(beg);
    rewrite(stddat);
    std.persnr:=suchen.persnr;
    std.name:=suchen.name;
    textcolor(lightcyan);
    gotoxy(40,5);
    write('Abrechnungsmonat: ');
    gotoxy(40,6);
    write('Abrechnungsjahr : ');
    abjahr:=copy(datum,7,4);
    clock:=false;
    repeat
      case x of
        1 : begin
              msg:='';
              clock:=false;
              abmon:=input_select(58,5,15,12,beg,white,blue,auswahl,msg);
              gotoxy(58,5);
              textcolor(black);
              textbackground(white);
              write(' ':15-length(abmon),abmon);
              if msg='can'then
              begin
                close(stddat);
                erase(stddat);
                exit;
              end;
              if (msg='') or (msg='down') or (msg='up') then inc(x);
            end;
        2 : begin
              msg:='';
              clock:=false;
              abjahr:=input_field(58,6,4,white,blue,abjahr,msg);
              textcolor(black);
              textbackground(white);
              gotoxy(58,6);
              write(abjahr);
              if msg='can' then
              begin
                close(stddat);
                erase(stddat);
                exit;
              end;
              if msg='' then inc(x);
              if msg='up' then dec(x);
              if msg='down' then dec(x);
            end;
      end;
    until x=3;
    textcolor(white);
    textbackground(black);
    gotoxy(58,5);
    write(abmon,' ':15-length(abmon));
    gotoxy(58,6);
    write(abjahr);
    std.monat:=abmon;
    std.jahr:=abjahr;
    for x:=1 to 32 do
    begin
      std.nachweis[x].arbeitsdatum:='';
      std.nachweis[x].anzstd:=0.0;
      std.nachweis[x].stdlohn:=0.0;
      std.nachweis[x].gesamt:=0.0;
    end;
    seek(stddat,0);
    write(stddat,std);
    close(stddat);
  end;
  screen_init('Stunden erfassen');
  reset(stddat);
  read(stddat,std);
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(3,3);
  write('Pers.-Nr.: ');
  gotoxy(3,4);
  write('Name     : ');
  textcolor(white);
  gotoxy(14,3);
  write(suchen.persnr);
  gotoxy(14,4);
  write(suchen.name);
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(40,3);
  write('Abrechnungsmonat: ');
  gotoxy(40,4);
  write('Abrechnungsjahr : ');
  textcolor(white);
  gotoxy(58,3);
  write(std.monat);
  gotoxy(58,4);
  write(std.jahr);
  textcolor(lightcyan);
  repeat
    px:=2;
    py:=6;
    ges:=0.0;
    textcolor(lightcyan);
    gotoxy(2,5);
    write('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    gotoxy(2,23);
    write('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
    textcolor(white);
    gotoxy(3,5);
    write('Datum:');
    gotoxy(13,5);
    write('Std:');
    gotoxy(21,5);
    write('Stdlohn:');
    gotoxy(30,5);
    write('Gesamt:');
    gotoxy(43,5);
    write('Datum:');
    gotoxy(53,5);
    write('Std:');
    gotoxy(61,5);
    write('Stdlohn:');
    gotoxy(70,5);
    write('Gesamt:');
    gotoxy(67,23);
    write('Auszahlung:');
    clear_window(2,6,78,18,black);
    if std.nachweis[32].gesamt<>0.0 then
    begin
      textcolor(lightgray);
      gotoxy(22,22);
      write('1.-31. d.M. Pauschale: ',std.nachweis[32].gesamt:6:2,' DM');
      gotoxy(20,24);
      write(' ':38);
      ges:=ges+std.nachweis[32].gesamt;
    end;
    for x:=1 to 31 do
    begin
      if std.nachweis[x].anzstd<>0.0 then
      begin
        gotoxy(px,py);
        if py mod 2=0 then textcolor(white)
        else textcolor(lightgray);
        write(std.nachweis[x].arbeitsdatum,', ');
        write(std.nachweis[x].anzstd:5:2,'h   ');
        write(std.nachweis[x].stdlohn:5:2,' DM ');
        write(std.nachweis[x].gesamt:6:2,' DM');
        ges:=ges+std.nachweis[x].gesamt;
        inc(py);
        if py=22 then
        begin
          py:=6;
          px:=42;
        end;
      end;
    end;
    gotoxy(70,24);
    write('         ');
    gotoxy(70,24);
    if ges>500.0 then textcolor(white+blink)
    else textcolor(white);
    write(ges:6:2);
    textcolor(lightcyan);
    write(' DM');
    x:=1;
    gotoxy(20,24);
    write(' ':38);
    textcolor(lightcyan);
    gotoxy(2,24);
    write('Datum (TT)    : ');
    gotoxy(26,24);
    write('Std: ');
    gotoxy(38,24);
    write('Std.Lohn: ');
    repeat
      repeat
        clock:=false;
        help('Bitte den Tag eingeben, ''p''= Pauschale, ''l''= l”schen, ESC=Ende');
        textcolor(white);
        tag:=input_field(18,24,2,white,blue,'',msg);
        if tag='p' then tag:='P';
        if tag='l' then tag:='L';
        if tag='L' then
        begin
          if not yes('Die gesamten Daten dieser Arbeitskraft l”schen ') then
            tag:='';
        end;
        val(tag,tagnum,code);
      until (code=0) or (msg='can') or (tag='P') or (tag='L') or (tagnum>0);
      if (tag<>'P') then
      begin
        if tag<>'L' then
        begin
          if length(tag)=1 then tag:='0'+tag;
          moint:=monatnummer(std.monat);
          str(moint:2,mo);
          if mo[1]=' ' then mo[1]:='0';
          if msg='can'then
          begin
            close(stddat);
            if ges=0.0 then erase(stddat);
            clock:=true;
            exit;
          end;
        end;
      end;
    until (pos(':',tag)=0) and (pos('.',tag)=0) and (pos(',',tag)=0) and (tagnum<32);
    if (tag='P') then
    begin
      textcolor(lightcyan);
      gotoxy(20,24);
      write(' ':38);
      gotoxy(31,24);
      write('Pauschalbetrag: ');
      repeat
        msg:='';
        if std.nachweis[32].gesamt<>0.0 then
          str(std.nachweis[32].gesamt:6:2,pausch)
        else
          pausch:='';
        help('Bitte den Pauschalbetrag eingeben, ESC=Ende');
        textcolor(white);
        pausch:=input_field(47,24,6,white,blue,pausch,msg);
        if pos(',',pausch)<>0 then
          pausch[pos(',',pausch)]:='.';
        if msg='can' then
        begin
          close(stddat);
          if ges=0.0 then erase(stddat);
          clock:=true;
          exit;
        end;
        val(pausch,std.nachweis[32].gesamt,code);
      until (code=0) or (msg='');
    end;
    if (tag<>'L') and (tag<>'P') then
    begin
      textcolor(white);
      gotoxy(18,24);
      write(tag);
      val(copy(tag,1,2),tagnum,code);
      if std.nachweis[tagnum].stdlohn=0.00 then
      begin
        st:='';
        stl:='';
      end
      else
      begin
        str(std.nachweis[tagnum].stdlohn:5:2,stl);
        str(std.nachweis[tagnum].anzstd:5:2,st);
        if stl=' 0.00' then stl:='';
        if st=' 0.00' then st:='';
      end;
      repeat
        case x of
          1 : begin
                msg:='';
                repeat
                  clock:=false;
                  help('Bitte Anzahl der gearbeiteten Stunden eingeben, 0=Eintrag l”schen');
                  textcolor(white);
                  st:=input_field(31,24,6,white,blue,st,msg);
                  if pos(',',st)<>0 then
                    st[pos(',',st)]:='.';
                  val(st,std.nachweis[tagnum].anzstd,code);
                until (code=0) or (msg<>'');
                textcolor(white);
                gotoxy(58,24);
                std.nachweis[tagnum].gesamt:=std.nachweis[tagnum].anzstd*std.nachweis[tagnum].stdlohn;
                write(std.nachweis[tagnum].gesamt:6:2);
                textcolor(lightcyan);
                write(' DM');
                textcolor(white);
                if msg='can' then
                begin
                  close(stddat);
                  if ges=0.0 then erase(stddat);
                  clock:=true;
                  exit;
                end;
                if (msg='') or (msg='left') or (msg='right') or (msg='up') or (msg='down') then inc(x);
              end;
          2 : begin
                msg:='';
                repeat
                  clock:=false;
                  ftast:=true;
                  fkeys[1]:='10';
                  fkeys[2]:='12';
                  fkeys[3]:='14';
                  fkeys[4]:='15';
                  fkeys[5]:='25';
                  help('Bitte Stundenlohn eingeben, oder F1=10DM, F2=12DM, F3=14DM, F4=15DM, F5=25DM');
                  textcolor(white);
                  stl:=input_field(48,24,6,white,blue,stl,msg);
                  ftast:=false;
                  if pos(',',stl)<>0 then
                    stl[pos(',',stl)]:='.';
                  val(stl,std.nachweis[tagnum].stdlohn,code);
                until (code=0) or (msg<>'');
                textcolor(white);
                gotoxy(58,24);
                std.nachweis[tagnum].gesamt:=std.nachweis[tagnum].anzstd*std.nachweis[tagnum].stdlohn;
                write(std.nachweis[tagnum].gesamt:6:2);
                textcolor(lightcyan);
                write(' DM');
                textcolor(white);
                if msg='can' then
                begin
                  close(stddat);
                  if ges=0.0 then erase(stddat);
                  clock:=true;
                  exit;
                end;
                if (msg='up') or (msg='down') then dec(x);
                if msg='' then inc(x);
              end;
        end;
      until x=3;
    end;
    if tag='L' then
    begin
      for j:=1 to 32 do
      begin
        std.nachweis[j].anzstd:=0.0;
        std.nachweis[j].stdlohn:=0.0;
        std.nachweis[j].gesamt:=0.0;
      end;
    end;
    std.nachweis[tagnum].arbeitsdatum:=tag+'.'+mo+'.'+copy(std.jahr,3,2);
    seek(stddat,0);
    write(stddat,std);
  until (tag='XXXXX');
  prreturn;
end;

procedure stornieren;
begin
end;

procedure nachdrucken;
begin
end;

procedure ohnedruck;
begin
end;

procedure belegmenu;
begin
end;

procedure erzeuge_abrechnung(suchen:persadr);
var i,z,anztage      :integer;
    abdatei          :text;
    ges,
    gst              :real;
    stddat           :file of stunden;
    std              :stunden;
begin
  screen_init('Erzeuge Abrechnung');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Bitte warten, erzeuge Abrechnung fr ');
  if not exist(suchen.persnr+'.DAT') then exit;
  assign(stddat,suchen.persnr+'.DAT');
  reset(stddat);
  seek(stddat,0);
  read(stddat,std);
  close(stddat);
  textcolor(white);
  write(std.name);
  assign(abdatei,suchen.persnr+'.TXT');
  rewrite(abdatei);
  ges:=0.0;
  gst:=0.0;
  for i:=1 to 32 do
  begin
    ges:=ges+std.nachweis[i].gesamt;
    gst:=gst+std.nachweis[i].anzstd;
  end;
  for i:=1 to 5 do
    writeln(abdatei,'');
  writeln(abdatei,'     Kassierer Abrechnung Monat ',std.monat,' / ',std.jahr);
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Name         : ',suchen.name);
  writeln(abdatei,'     Geburtsdatum : ',suchen.geburtsdat);
  writeln(abdatei,'     Straáe       : ',suchen.strasse);
  writeln(abdatei,'     Wohnort      : ',suchen.ort);
  writeln(abdatei,'     RentenversNr.: ',suchen.versnr);
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Vorraussetzungen: weniger als 15 Wochenstunden,');
  writeln(abdatei,'                       maximaler Verdienst 500,-- DM');
  writeln(abdatei,'');
  writeln(abdatei,'     Arbeitszeitabrechung:');
  writeln(abdatei,'     ---------------------');
  writeln(abdatei,'');
  writeln(abdatei,'         Datum:       Stunden:     Stundenlohn:       Betrag:');
  writeln(abdatei,'');
  if std.nachweis[32].gesamt<>0.0 then
  begin
  writeln(abdatei,'         1.-31. d.M.         pauschal                ',std.nachweis[32].gesamt:6:2,' DM');
    writeln(abdatei,'');
  end;
  z:=1;
  anztage:=0;
  for i:=1 to 31 do
  begin
    if std.nachweis[i].anzstd<>0.0 then
    begin
      write(abdatei,'     ',z:2,'. ',std.nachweis[i].arbeitsdatum,'     ',std.nachweis[i].anzstd:5:2,'         ');
      writeln(abdatei,std.nachweis[i].stdlohn:6:2,' DM        ',std.nachweis[i].gesamt:6:2,' DM');
      inc(z);
      inc(anztage);
    end;
  end;
  writeln(abdatei,'');
  writeln(abdatei,'     ',anztage:2,' Tage          ',gst:5:2,' Stunden          Gesamt: ',ges:6:2,' DM');
  writeln(abdatei,'     =========================================================');
  for i:=1 to 18-anztage do
    writeln(abdatei,'');
  writeln(abdatei,'     Ich erkl„re, daá ich im vorgenannten Monatszeitraum keine weitere');
  writeln(abdatei,'     Nebenbesch„ftigung im Sinne der gesetzlichen Regelung der Sozial-');
  writeln(abdatei,'     versicherung fr unregelm„áig Besch„ftigte ausbe.');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Datum __________________  Unterschrift _X_______________________ ');
  writeln(abdatei,'');
  writeln(abdatei,'     Wir versichern, daá die oben genannten Aufzeichnungen richtig sind,');
  writeln(abdatei,'     und weisen den Gesamtbetrag von ',ges:6:2,' DM hiermit an.');
  writeln(abdatei,'     Die šberweisung erfolgt auf das Konto ',suchen.kto);
  writeln(abdatei,'     bei ''',suchen.bank,''', (BLZ ',suchen.blz,')');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Datum __________________  Unterschrift _________________________ ');
  close(abdatei);
  erase(stddat);
  reset(datenbank);
  seek(datenbank,filesize(datenbank));
  std.nachweis[32].arbeitsdatum:=copy(datum,1,5)+'.'+copy(datum,9,2);
  write(datenbank,std);
  close(datenbank);
end;

procedure einzelab;
var posi      :integer;
    such      :persadr;
    passwort  :string[10];
    msg       :string;
begin
  screen_init('Einzelabrechung');
  clock:=false;
  help('Bitte Zungangscode eingeben, oder ESC fr Abbruch');
  colorbox(25,10,31,4,white,red,'Zugangskontrolle');
  gotoxy(2,2);
  write('Bitte Zugangscode eingeben:');
  passwort:=upperline(input_field(2,3,10,red,red,'',msg));
  if msg='can' then
  begin
    colorbox_close;
    exit;
  end;
  if passwort<>passwd then
  begin
    colorbox_close;
    exit;
  end;
  colorbox_close;
  screen_init('Einzelabrechung');
  clock:=true;
  posi:=findeadr(such);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,such);
  close(adrdatei);
  erzeuge_abrechnung(such);
  if exist(such.persnr+'.TXT') then drucke_datei(such.persnr+'.TXT');
end;

procedure gesamtab;
var abmon,
    abjahr,
    msg          :string;
    ges,
    geszu,
    kist         :real;
    auswahl      :select;
    x,
    beg,
    i,
    j,
    code         :integer;
    such         :persadr;
    zusfas       :text;
    stddat           :file of stunden;
    std              :stunden;
    arbeiterka       :real;
    angestka         :real;
    passwort         :string[10];
begin
  screen_init('Gesamtabrechung');
  clock:=false;
  help('Bitte Zungangscode eingeben, oder ESC fr Abbruch');
  colorbox(25,10,31,4,white,red,'Zugangskontrolle');
  gotoxy(2,2);
  write('Bitte Zugangscode eingeben:');
  passwort:=upperline(input_field(2,3,10,red,red,'',msg));
  if msg='can' then
  begin
    colorbox_close;
    exit;
  end;
  if passwort<>passwd then
  begin
    colorbox_close;
    exit;
  end;
  colorbox_close;
  clock:=true;
  screen_init('Gesamtabrechung');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Abrechnungsmonat: ');
  gotoxy(5,6);
  write('Abrechnungsjahr : ');
  abjahr:=copy(datum,7,4);
  clock:=false;
  arbeiterka:=0.0;
  angestka:=0.0;
  for x:=0 to 11 do
    auswahl[x]:=monatel[x+1];
  x:=1;
  beg:=0;
  val(copy(datum,4,2),beg,code);
  dec(beg);
  ges:=0.0;
  geszu:=0.0;
  repeat
    case x of
      1 : begin
            msg:='';
            clock:=false;
            abmon:=input_select(23,5,15,12,beg,white,blue,auswahl,msg);
            gotoxy(23,5);
            textcolor(black);
            textbackground(white);
            write(' ':15-length(abmon),abmon);
            if msg='can'then exit;
            if (msg='') or (msg='down') or (msg='up') then inc(x);
          end;
      2 : begin
            msg:='';
            clock:=false;
            abjahr:=input_field(23,6,4,white,blue,abjahr,msg);
            textcolor(black);
            textbackground(white);
            gotoxy(23,6);
            write(abjahr);
            if msg='can' then exit;
            if msg='' then inc(x);
            if msg='up' then dec(x);
            if msg='down' then dec(x);
          end;
    end;
  until x=3;
  assign(zusfas,'ZUSFAS.TXT');
  rewrite(zusfas);
  writeln(zusfas,'     Zusammenfassung fr Monat ',abmon,' / ',abjahr);
  writeln(zusfas,'');
  reset(adrdatei);
  close(adrdatei);
  reset(adrdatei);
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,such);
    if exist(such.persnr+'.DAT') then
    begin
      assign(stddat,such.persnr+'.DAT');
      reset(stddat);
      seek(stddat,0);
      read(stddat,std);
      close(stddat);
      if (std.monat=abmon) and (std.jahr=abjahr) then
      begin
        for j:=1 to 32 do
          ges:=ges+std.nachweis[j].gesamt;
        writeln(zusfas,'     ',such.persnr:3,' ',such.name:30,'    ',ges:6:2,' DM');
        if such.persnr>'900' then
        begin
          if ges>=100.0 then
          begin
            if frac(ges/100)=0.0 then arbeiterka:=arbeiterka+(0.15*int(ges/100));
            if frac(ges/100)<>0.0 then arbeiterka:=arbeiterka+(0.15*(int(ges/100)+1));
          end
          else arbeiterka:=arbeiterka+0.15;
        end
        else
        begin
          if ges>=100.0 then
          begin
            if frac(ges/100)=0.0 then angestka:=angestka+(0.15*int(ges/100));
            if frac(ges/100)<>0.0 then angestka:=angestka+(0.15*(int(ges/100)+1));
          end
          else angestka:=angestka+0.15;
        end;
        geszu:=geszu+ges;
        ges:=0.0;
        erzeuge_abrechnung(such);
        drucke_datei(such.persnr+'.TXT');
      end;
    end;
  end;
  close(adrdatei);
  kist:=0.0;
  writeln(zusfas,'                                         -----------');
  writeln(zusfas,'                                 Gesamt: ',geszu:8:2,' DM');
  writeln(zusfas,'                                         ===========');
  writeln(zusfas,'');
  writeln(zusfas,'     Pauschale Steuern:');
  writeln(zusfas,'');
  writeln(zusfas,'                       15% Lohnsteuer  : ',(15*geszu)/100:8:2,' DM');
  kist:=(7*((15*geszu)/100)/100);
  writeln(zusfas,'                       davon 7% Ki-St. : ',kist:8:2,' DM');
  writeln(zusfas,'                               80% Ev. : ',(80*kist)/100:8:2,' DM');
  writeln(zusfas,'                               20% Kat.: ',(20*kist)/100:8:2,' DM');
  writeln(zusfas,'');
  writeln(zusfas,'                    Angestelltenkammer : ',angestka:8:2,' DM');
  writeln(zusfas,'                        Arbeiterkammer : ',arbeiterka:8:2,' DM');
  close(zusfas);
  if geszu<>0.0 then
  begin
    drucke_datei('ZUSFAS.TXT');
    drucke_datei('ZUSFAS.TXT');
    drucke_datei('ZUSFAS.TXT');
    drucke_datei('ZUSFAS.TXT');
  end;
end;

procedure nachab;
begin
end;

procedure abrechmenu;
var menu      :menuitems;
    auswahl   :integer;
begin
  screen_init('Abrechnungsmen');
  mhotkey:=true;
  mhelptext:=true;
  showmouse;
  menu[1].menutext:='Einzelne Abrechnung';
  menu[1].help:='Monatsabrechnung fr eine einzelne Aushilfe';
  menu[1].key:='E';
  menu[2].menutext:='Alle abrechnen';
  menu[2].help:='Monatsabrechnug fr alle Aushilfen';
  menu[2].key:='A';
  menu[3].menutext:='Nachdrucken';
  menu[3].help:='Monatsabrechnug fr eine Aushilfe nachdrucken';
  menu[3].key:='N';
  menu[4].menutext:='Zurck ins Hauptmen';
  menu[4].help:='Ins Hauptmen wechseln';
  menu[4].key:='Z';
  repeat
    screen_init('Abrechnungsmen');
    menuselect(4,menu,auswahl);
    case auswahl of
      1  : einzelab;
      2  : gesamtab;
      3  : nachab;
    end;
    clock:=true;
  until auswahl=4;
  hidemouse;
end;

procedure startbild;
begin
  assign(adrdatei,'ADRESS.DAT');
  {$I-}
  reset(adrdatei);
  {$I+}
  if IOresult<>0 then
    rewrite(adrdatei);
  close(adrdatei);
  assign(datenbank,'DATENBNK.DAT');
  if not exist('DATENBNK.DAT') then
  begin
    rewrite(datenbank);
    close(datenbank);
  end;
  screen_init('Programm Start');
  if pos('beta',version)<>0 then
  begin
    textcolor(red+blink);
    gotoxy(21,21);
    writeln('Dies ist eine Vorabversion zum Testen!');
    gotoxy(21,22);
    writeln('   Bei St”rungen: Tel.: 0172 4078556');
    textcolor(white);
  end;
  colorbox(20,7,40,10,white,green,'Willkommen');
  gotoxy(7,2);
  write('PERS-Abrechungssystem ',version);
  gotoxy(11,3);
  write(copyright);
  gotoxy(12,5);
  write('Lizensiert fr:');
  gotoxy(6,6);
  write(lizenz);
  gotoxy(9,8);
  write('Bitte Enter drcken ...');
  initevents;
  hidemouse;
  colorbox_close;
  prreturn;
end;

function schluss:boolean;
var ch :char;
begin
  colorbox(20,18,35,2,white,green,'PROGRAMM BEENDEN');
  write('Programm wirklich beenden (J/N)?');
  colorbox_close;
  schluss:=yes('Programm wirklich beenden');
end;

procedure erfliste;
var  i,j,y   :integer;
     stddat  :file of stunden;
     std     :stunden;
     ges     :real;
     total   :real;
begin
  screen_init('Bereits erfasst');
  ges:=0.0;
  total:=0.0;
  if not exist('ADRESS.DAT') then exit;
  reset(adrdatei);
  y:=5;
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,vvadresse);
    textcolor(white);
    gotoxy(79,24);
    write(pause[(i mod 4)+1]);
    if exist(vvadresse.persnr+'.DAT') then
    begin
      assign(stddat,vvadresse.persnr+'.DAT');
      reset(stddat);
      read(stddat,std);
      textcolor(cyan);
      gotoxy(3,y);
      inc(y);
      write(vvadresse.persnr:4,' ',vvadresse.name+copy(dreissig,1,30-length(vvadresse.name)));
      ges:=0.0;
      for j:=1 to 32 do
        ges:=ges+std.nachweis[j].gesamt;
      write(ges:6:2,' DM   ');
      total:=total+ges;
      write(std.monat,' / ',std.jahr);
      gotoxy(30,24);
      write('Total: ',total:8:2,' DM');
      if y mod 22=0 then
      begin
        gotoxy(79,24);
        write(' ');
        help('Bitte RETURN drcken ...');
        prreturn;
        screen_init('Personalliste');
        gotoxy(3,5);
        y:=5;
      end;
      close(stddat);
    end;
  end;
  close(adrdatei);
  gotoxy(79,24);
  write(' ');
  help('Bitte RETURN drcken ...');
  prreturn;
end;

procedure alteanzeig;
var vvn,rbn,msg,dummy     :string;
    x,beg                 :integer;
    ende                  :boolean;
    pruef                 :persadr;
    auswahl               :select;
    abmon,abjahr          :string;
    std                   :stunden;
    px,py                 :integer;
    ges                   :real;
    posi,code             :integer;
    aj,am,na,pn           :boolean;
    druckdat              :text;
begin
  clock:=false;
  screen_init('Alte anzeigen');
  textcolor(lightcyan);
  gotoxy(3,5);
  write('Pers.-Nr.: ');
  gotoxy(3,6);
  write('Name     : ');
  gotoxy(3,7);
  write('Monat    : ');
  gotoxy(3,8);
  write('Jahr     : ');
  textcolor(black);
  textbackground(white);
  gotoxy(14,5);
  write(' ':3);
  gotoxy(14,6);
  write(' ':30);
  gotoxy(14,7);
  write(' ':15);
  gotoxy(14,8);
  write(' ':4);
  x:=1;
  vvn:='';
  rbn:='';
  msg:='';
  abmon:='';
  abjahr:=copy(datum,7,4);
  ende:=false;
  for x:=1 to 12 do
    auswahl[x]:=monatel[x];
  auswahl[0]:='';
  x:=1;
  beg:=0;
  val(copy(datum,4,2),beg,code);
  help('Bitte die Anzeige einschr„nken!');
  repeat
    case x of
      1 : begin
            help('Bitte die Anzeige einschr„nken! Hier Personalnummer eingeben');
            textcolor(black);
            textbackground(white);
            vvn:=input_field(14,5,3,white,blue,vvn,msg);
            if msg='up'then x:=4;
            if msg='down' then inc(x);
            if msg='' then inc(x);
            if msg='can' then exit;
          end;
      2 : begin
            help('Bitte die Anzeige einschr„nken! Hier bei Bedarf Namen eingeben');
            textcolor(black);
            textbackground(white);
            rbn:=input_field(14,6,30,white,blue,rbn,msg);
            gotoxy(14,6);
            write(rbn,' ':30-length(rbn));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
            if msg='can' then exit;
          end;
      3 : begin
            help('Bitte die Anzeige einschr„nken! Monat ausw„hlen mit den Pfeiltasten');
            textcolor(black);
            textbackground(white);
            abmon:=input_select(14,7,15,13,beg,white,blue,auswahl,msg);
            gotoxy(14,7);
            textcolor(black);
            textbackground(white);
            write(' ':15-length(abmon),abmon);
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
            if msg='can'then exit;
          end;
      4 : begin
            help('Bitte die Anzeige einschr„nken! Hier bei Bedarf das Jahr eingeben');
            textcolor(black);
            textbackground(white);
            abjahr:=input_field(14,8,4,white,blue,abjahr,msg);
            gotoxy(14,8);
            write(abjahr,' ':4-length(abjahr));
            if msg='up'then dec(x);
            if msg='down' then x:=1;
            if msg='' then ende:=true;
            if msg='can' then exit;
          end;
    end;
  until (ende) or (msg='can');
  assign(datenbank,'DATENBNK.DAT');
  if not exist('DATENBNK.DAT') then exit;
  reset(datenbank);
  posi:=0;
  aj:=false;
  am:=aj;
  na:=am;
  pn:=na;
  if abmon='' then am:=true;
  if abjahr='' then aj:=true;
  if vvn='' then pn:=true;
  if rbn='' then na:=true;
  repeat
    screen_init('Alte anzeigen');
    seek(datenbank,posi);
    read(datenbank,std);
    if am then abmon:=std.monat;
    if aj then abjahr:=std.jahr;
    if na then rbn:=std.name;
    if pn then vvn:=std.persnr;
    if (std.monat=abmon) and (std.jahr=abjahr) and (std.name=rbn) and (std.persnr=vvn) then
    begin
      textcolor(lightcyan);
      textbackground(black);
      gotoxy(3,3);
      write('Pers.-Nr.: ');
      gotoxy(3,4);
      write('Name     : ');
      textcolor(white);
      gotoxy(14,3);
      write(std.persnr);
      gotoxy(14,4);
      write(std.name);
      textcolor(lightcyan);
      textbackground(black);
      gotoxy(40,3);
      write('Abrechnungsmonat: ');
      gotoxy(40,4);
      write('Abrechnungsjahr : ');
      textcolor(white);
      gotoxy(58,3);
      write(std.monat);
      gotoxy(58,4);
      write(std.jahr);
      textcolor(lightcyan);
      px:=2;
      py:=6;
      ges:=0.0;
      textcolor(lightcyan);
      gotoxy(2,5);
      write('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      gotoxy(2,23);
      write('ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ');
      gotoxy(2,24);
      write('Abgeschlossen am: ');
      textcolor(white);
      gotoxy(3,5);
      write('Datum:');
      gotoxy(13,5);
      write('Std:');
      gotoxy(21,5);
      write('Stdlohn:');
      gotoxy(30,5);
      write('Gesamt:');
      gotoxy(43,5);
      write('Datum:');
      gotoxy(53,5);
      write('Std:');
      gotoxy(61,5);
      write('Stdlohn:');
      gotoxy(70,5);
      write('Gesamt:');
      gotoxy(67,23);
      write('Auszahlung:');
      gotoxy(20,24);
      write(std.nachweis[32].arbeitsdatum);
      clear_window(2,6,78,18,black);
      if std.nachweis[32].gesamt<>0.0 then
      begin
        textcolor(lightgray);
        gotoxy(22,22);
        write('1.-31. d.M. Pauschale: ',std.nachweis[32].gesamt:6:2,' DM');
        ges:=ges+std.nachweis[32].gesamt;
      end;
      for x:=1 to 31 do
      begin
        if std.nachweis[x].anzstd<>0.0 then
        begin
          gotoxy(px,py);
          if py mod 2=0 then textcolor(white)
          else textcolor(lightgray);
          write(std.nachweis[x].arbeitsdatum,', ');
          write(std.nachweis[x].anzstd:5:2,'h   ');
          write(std.nachweis[x].stdlohn:5:2,' DM ');
          write(std.nachweis[x].gesamt:6:2,' DM');
          ges:=ges+std.nachweis[x].gesamt;
          inc(py);
          if py=22 then
          begin
            py:=6;
            px:=42;
          end;
        end;
      end;
      gotoxy(70,24);
      write('         ');
      gotoxy(70,24);
      if ges>500.0 then textcolor(white+blink)
      else textcolor(white);
      write(ges:6:2);
      textcolor(lightcyan);
      write(' DM');
      help('Mit den Pfeiltasten bl„ttern, ''p''=Ausdruck, ESC=Abbruch');
      dummy:=input_field(60,24,1,white,blue,'',msg);
      if msg='can' then
      begin
        close(datenbank);
        exit;
      end;
      if dummy='p' then
      begin
        assign(druckdat,std.persnr+'.TX1');
        rewrite(druckdat);
        writeln(druckdat,'');
        writeln(druckdat,'Nachdruck der Kassiererabrechnung');
        writeln(druckdat,'');
        writeln(druckdat,'Fr: ',std.name,' im ',std.monat,' / ',std.jahr);
        writeln(druckdat,'');
        for x:=1 to 31 do
        begin
          if std.nachweis[x].anzstd<>0.0 then
          begin
            write(druckdat,std.nachweis[x].arbeitsdatum,', ');
            write(druckdat,std.nachweis[x].anzstd:5:2,'h   ');
            write(druckdat,std.nachweis[x].stdlohn:5:2,' DM ');
            writeln(druckdat,std.nachweis[x].gesamt:6:2,' DM');
          end;
        end;
        if std.nachweis[32].gesamt<>0.0 then
          writeln(druckdat,'Pauschal: ',std.nachweis[32].gesamt:6:2,' DM');
        writeln(druckdat,'');
        writeln(druckdat,'Gesamt  : ',ges:6:2,' DM');
        writeln(druckdat,'          =========');
        writeln(druckdat,'');
        writeln(druckdat,'Nachgedruckt am : ',datum);
        writeln(druckdat,'Abgerechnet am  : ',std.nachweis[32].arbeitsdatum);
        close(druckdat);
        drucke_datei(std.persnr+'.TX1');
        erase(druckdat);
      end;
      if (msg='up') and (posi>0) then dec(posi);
      if (msg='down') and (posi<filesize(datenbank)-1) then inc(posi);
    end
    else
      inc(posi);
  until posi>filesize(datenbank)-1;
  close(datenbank);
end;

procedure adressortna;
var adr1,adr2   :persadr;
    zweite      :file of persadr;
    i,j         :integer;
    x,y         :longint;
begin
  if not exist('ADRESS.DAT') then exit;
  assign(adrdatei,'ADRESS.DAT');
  reset(adrdatei);
  screen_init('Adressen sortieren');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Bitte warten, ich sortiere ');
  textcolor(white);
  x:=0;
  y:=0;
  for i:=filesize(adrdatei)-1 downto 0 do
    for j:=0 to i-1 do
      inc(x);
  for i:=filesize(adrdatei)-1 downto 0 do
    for j:=0 to i-1 do
    begin
      gotoxy(32,5);
      if x>0 then
        write(pause[(j mod 4)+1],' ',round((y*100)/x):3,' %');
      inc(y);
      seek(adrdatei,j);
      read(adrdatei,adr1);
      seek(adrdatei,j+1);
      read(adrdatei,adr2);
      if adr1.name>adr2.name then
      begin
        seek(adrdatei,j);
        write(adrdatei,adr2);
        seek(adrdatei,j+1);
        write(adrdatei,adr1);
      end;
    end;
  gotoxy(32,5);
  write('                   ');
  assign(zweite,'adrtem.$$$');
  rewrite(zweite);
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,adr1);
    gotoxy(32,5);
    write(pause[(i mod 4)+1]);
    if adr1.persnr<>'$$$$$' then
      write(zweite,adr1);
  end;
  close(zweite);
  close(adrdatei);
  erase(adrdatei);
  rename(zweite,'ADRESS.DAT');
end;

procedure adressortnr;
var adr1,adr2   :persadr;
    zweite      :file of persadr;
    i,j         :integer;
    x,y         :longint;
begin
  if not exist('ADRESS.DAT') then exit;
  assign(adrdatei,'ADRESS.DAT');
  reset(adrdatei);
  screen_init('Adressen sortieren');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Bitte warten, ich sortiere ');
  textcolor(white);
  x:=0;
  y:=0;
  for i:=filesize(adrdatei)-1 downto 0 do
    for j:=0 to i-1 do
      inc(x);
  for i:=filesize(adrdatei)-1 downto 0 do
    for j:=0 to i-1 do
    begin
      gotoxy(32,5);
      if x>0 then
        write(pause[(j mod 4)+1],' ',round((y*100)/x):3,' %');
      inc(y);
      seek(adrdatei,j);
      read(adrdatei,adr1);
      seek(adrdatei,j+1);
      read(adrdatei,adr2);
      if adr1.persnr>adr2.persnr then
      begin
        seek(adrdatei,j);
        write(adrdatei,adr2);
        seek(adrdatei,j+1);
        write(adrdatei,adr1);
      end;
    end;
  assign(zweite,'adrtem.$$$');
  rewrite(zweite);
  gotoxy(32,5);
  write('                   ');
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,adr1);
    gotoxy(32,5);
    write(pause[(i mod 4)+1]);
    if adr1.persnr<>'$$$$$' then
      write(zweite,adr1);
  end;
  close(zweite);
  close(adrdatei);
  erase(adrdatei);
  rename(zweite,'ADRESS.DAT');
end;

procedure dienstmenu;
var dienstmen  :menuitems;
    auswahl    :integer;
begin
  screen_init('Dienste');
  mhotkey:=true;
  mhelptext:=true;
  clock:=false;
  showmouse;
  dienstmen[1].menutext:='Liste der Erfassten';
  dienstmen[1].help:='Erzeugt eine Liste von bereits erfassten Betr„gen';
  dienstmen[1].key:='L';
  dienstmen[2].menutext:='Alte Abrechnungen';
  dienstmen[2].help:='Anzeige alter, bereits abgeschlossener Abrechungen';
  dienstmen[2].key:='A';
  dienstmen[3].menutext:='adressen Sortieren (Name)';
  dienstmen[3].help:='Adressen in der Adressverwaltung nach Namen sortieren';
  dienstmen[3].key:='S';
  dienstmen[4].menutext:='Adressen Sortieren (Nr.)';
  dienstmen[4].help:='Adressen in der Adressverwaltung nach Nummern sortieren';
  dienstmen[4].key:='N';
  dienstmen[5].menutext:='Zurck zum Hauptmen';
  dienstmen[5].help:='Ins Hauptmen wechseln';
  dienstmen[5].key:='Z';
  repeat
    screen_init('Dienstmen');
    menuselect(5,dienstmen,auswahl);
    case auswahl of
      1 : erfliste;
      2 : alteanzeig;
      3 : adressortna;
      4 : adressortnr;
    end;
  until auswahl=5;
  clock:=true;
  hidemouse;
end;

procedure menue;
var hauptmenu :menuitems;
    auswahl   :integer;
begin
  screen_init('Hauptmen');
  mhotkey:=true;
  mhelptext:=true;
  showmouse;
  hauptmenu[2].menutext:='Adressverwaltung ...';
  hauptmenu[2].help:='Personaladressen bearbeiten';
  hauptmenu[2].key:='A';
  hauptmenu[1].menutext:='Stunden erfassen';
  hauptmenu[1].help:='Stunden der Aushilfen erfassen';
  hauptmenu[1].key:='S';
  hauptmenu[3].menutext:='Abrechnungen ...';
  hauptmenu[3].help:='Abrechungen fr Personal erstellen';
  hauptmenu[3].key:='r';
  hauptmenu[4].menutext:='Dienste ...';
  hauptmenu[4].help:='Zus„tzliche Funktionen';
  hauptmenu[4].key:='D';
  hauptmenu[5].menutext:='Programm beenden';
  hauptmenu[5].help:='Personalprogramm beenden';
  hauptmenu[5].key:='P';
  repeat
    screen_init('Hauptmen');
    menuselect(5,hauptmenu,auswahl);
    case auswahl of
      2  : adrevamen;
      1  : erfassen;
      3  : abrechmenu;
      4  : dienstmenu;
    end;
  until (auswahl=5) and (schluss);
  hidemouse;
end;

procedure endbild;
begin
  screen_init('Programm Ende');
  colorbox(20,7,40,10,white,red,'Auf Wiedersehen');
  gotoxy(2,2);
  write(' Denken Sie an die Datensicherung!');
  gotoxy(2,4);
  write('Vielen Dank, daá sie dieses Programm');
  gotoxy(2,5);
  write('          benutzt haben.');
  gotoxy(2,7);
  write('      Bitte Enter drcken ...');
  colorbox_close;
  prreturn;
  lowvideo;
  clrscr;
  writeln;
  writeln('PERS-Abrechungssystem, ',version,', ',copyright);
  writeln('Lizensiert fr : ',lizenz);
end;

begin
  saver:=true;
  clock:=true;
  savermsg:='PERSABRECHUNG '+version+' aktiv, bitte eine Taste drcken!';
  startbild;
  menue;
  endbild;
end.