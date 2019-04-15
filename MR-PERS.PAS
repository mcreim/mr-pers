program kassierer_abrechnung;

uses crt,dos,turbo3,dbase,drivers,deskunit,printer,selfkabu;

const copyright='(c)1993-98 M.Reimann';
      version='~V1.24·~';
      patchversion='';
      noreg = 'ÄΩë ÇÉ©úà(◊ úùûü† ~Ä';
      dummy  : string[5] = ('ÄÅÇÉÑ');
      lizenz : string[20] = ('ÄΩë ÇÉ©úà(◊ úùûü† ~Ä');
      dreissig='                              ';
      pause   : string[4] = ('|/-\');
      monatek : array [1..12] of string[3] = ('JAN','FEB','MéR','APR','MAI',
                                              'JUN','JUL','AUG','SEP','OKT',
                                              'NOV','DEZ');
      monatel : array [1..12] of string[10] = ('Januar','Februar','MÑrz',
                                               'April','Mai','Juni','Juli',
                                               'August','September',
                                               'Oktober','November','Dezember');
      drucker : array [1..2] of string[10] = ('Standard','Kyocera');


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

{type persneu = record
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
                 kennzeichen        :byte;
                 erweitert          :array[1..1024] of byte
               end;}

type persneu = record
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
                 kennzeichen        :byte;
                 geburtsname        :string[80];
                 erweitert          :array[1..943] of byte
               end;

type abogeld = record
                 persnr,
                 von,
                 bis,
                 zuletzt            :string[80];
                 betrag             :real;
               end;

type stunde = array[1..32] of record
                                arbeitsdatum :string[10];
                                anzstd,
                                stdlohn,
                                gesamt       :real;
                              end;

type config = record
                firma1    :string[70];
                firma2    :string[70];
                maxlohn   :real;
                maxwoche  :integer;
                lohnst    :integer;
                kist      :integer;
                ankam     :real;
                abkam     :real;
                passwd    :longint;
                initdat   :string[10];
                counter   :byte;
                anzdru    :byte;
                druckerinit :string[30];
                erweitert :array[1..68] of byte;
              end;


type stunden = record
                 persnr   :string;
                 name     :string[80];
                 monat    :string[10];
                 jahr     :string[4];
                 nachweis :stunde;
               end;


var adrdatei    :file of persneu;
    datenbank   :file of stunden;
    confile     :file of config;
    configurat  :config;
    db          :stunden;
    vvadresse   :persneu;
    altadr      :persadr;
    i           :integer;
    zeile       :string;
    kopftext    :string;
    printererr  :boolean;
    temporaer   :boolean;
    nichtmehr   :boolean;
    umlaute     :string;
    mand        :string; (* Der Mandant auf dem gearbeitet wird *)
{
function konvert_date(gebdatum:string):string;
var arbeitsstring :string;
begin
  if pos(gebdatum,'.')=0 then
  begin
    arbeitsstring:=copy(gebdatum,1,2)+'.'+copy(gebdatum,3,2)+'.'+copy(gebdatum,5,4);

}

procedure konverter;

var i,j             :integer;
    vvadresseneu    :persneu;
    vvadresse       :persadr;
    adrdatei_alt    :file of persadr;
    adrdatei_neu    :file of persneu;


begin
  if exist(mand+'ADRESSEN.DAT') then exit;
  if not exist(mand+'ADRESS.DAT') then exit;
  assign(adrdatei_alt,mand+'ADRESS.DAT');
  assign(adrdatei_neu,mand+'ADRESSEN.DAT');
  reset(adrdatei_alt);
  rewrite(adrdatei_neu);
  for i:=0 to filesize(adrdatei_alt)-1 do
  begin
    seek(adrdatei_alt,i);
    read(adrdatei_alt,vvadresse);
    with vvadresse do
    begin
      vvadresseneu.persnr:=persnr;
      vvadresseneu.name:=name;
      vvadresseneu.zus1:=zus1;
      vvadresseneu.zus2:=zus2;
      vvadresseneu.strasse:=strasse;
      vvadresseneu.ort:=ort;
      vvadresseneu.telefon:=telefon;
      vvadresseneu.fax:=fax;
      vvadresseneu.bank:=bank;
      vvadresseneu.kto:=kto;
      vvadresseneu.blz:=blz;
      vvadresseneu.versnr:=versnr;
      vvadresseneu.geburtsdat:=geburtsdat;
      vvadresseneu.geburtsort:=geburtsort;
      vvadresseneu.krankenkasse:=krankenkasse;
      vvadresseneu.kennzeichen:=1;
      vvadresseneu.geburtsname:='';
      for j:=1 to 943 do
        vvadresseneu.erweitert[j]:=0;
    end;
    write(adrdatei_neu,vvadresseneu);
    write('.');
  end;
  close(adrdatei_alt);
  close(adrdatei_neu);
  erase(adrdatei_alt);
end;

procedure protokoll(eintrag:string);
var protdat   :text;
begin
  assign(protdat,mand+'MR-PERS.LOG');
  if not exist(mand+'MR-PERS.LOG') then
    rewrite(protdat)
  else
    append(protdat);
  writeln(protdat,datum,', ',uhrzeit,': ',eintrag);
  close(protdat);
end;

function write_name:string;
var zeile    :string;
    i        :integer;
begin
  if temporaer then
  begin
    write_name:='TEMPORéRE VOLLVERSION';
    exit;
  end;
  i:=1;
  zeile:='';
  repeat
    zeile:=zeile+chr(ord(lizenz[i]) xor 127);
    inc(i);
  until (chr(ord(lizenz[i]) xor 127)='!') or (i=21);
  write_name:=zeile;
end;

procedure screen_init(titeltext:string);
begin
  textcolor(white);
  textbackground(black);
  clrscr;
  write_row(1,'  MR-PERS Abrechungssystem, '+version+', '+copyright+'   '+titeltext);
  if lizenz=noreg then
  begin
    write_row(25,' Diese Version ist eine ~SHAREWARE VERSION~                 '+datum+' / '+uhrzeit);
  end
  else
  begin
    write_row(25,' Vollversion fÅr ~'+write_name+'~                    '+datum+' / '+uhrzeit);
  end;
  if mand<>'' then
  begin
    textcolor(cyan);
    gotoxy(57,2);
    write('Mandant: ',mand);
  end;
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

function adreingabe(var vorgabe:persneu):boolean;
var x,test,code                                              :integer;
    kk,vvn,rbn,z1,z2,st,ot,tel,fx,bnk,k,bl,geb,gebo,vers,msg :string;
    kennz,gebname                                            :string;
    ende                                                     :boolean;
begin
  ende:=false;
  hidemouse;
  x:=1;
  help('Bitte Maske ausfÅllen, RETURN in der letzten Zeile=Speichern, ESC=Abbruch');
  textcolor(lightcyan);
  gotoxy(3,5);
  write('Kennz.   : ');
  gotoxy(3,6);
  write('Name     : ');
  gotoxy(3,7);
  write('Zusatz 1 : ');
  gotoxy(3,8);
  write('Zusatz 2 : ');
  gotoxy(3,9);
  write('Stra·e   : ');
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
  write('Geb.Datum: ');
  gotoxy(3,19);
  write('Geb.Ort  : ');
  gotoxy(3,22);
  write('Vers.-Nr.: ');
  gotoxy(3,21);
  write('Krankenk.: ');
  gotoxy(3,20);
  write('Geb.Name : ');
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
    kk:=krankenkasse;
    if kennzeichen>3 then kennz:='A';
    if kennzeichen=1 then kennz:='S';
    if kennzeichen=2 then kennz:='A';
    if kennzeichen=3 then kennz:='G';
    gebname:=geburtsname;
  end;
  textcolor(black);
  textbackground(white);
  gotoxy(14,5);
  write(kennz);
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
  gotoxy(14,22);
  write(vers,' ':15-length(vers));
  if length(vorgabe.krankenkasse)>=80 then
  begin
    kk:='';
  end;
  gotoxy(14,21);
  write(kk,' ':30-length(kk));
  gotoxy(14,20);
  write(gebname,' ':30-length(gebname));
  repeat
    case x of
      1 : begin
            repeat
              help('Kennzeichen eingeben: ''S''=Student, ''A''=Angestellter, ''G''=GeringbeschÑftigt');
              textcolor(black);
              textbackground(white);
              kennz:=input_field(14,5,1,white,blue,kennz,msg);
              kennz:=upperline(kennz);
            until (kennz='S') or (kennz='A') or (kennz='G');
            if msg='up'then x:=15;
            if msg='down' then inc(x);
            if msg='' then inc(x);
            textcolor(black);
            textbackground(white);
            gotoxy(14,5);
            write(kennz);
          end;
      2 : begin
            help('Namen eingeben: Nachname, Vorname');
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
            help('Zusatzinformationen eingeben. Werden Bei Bildschirmliste angezeigt.');
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
            help('Weitere Zusatzinformationen eingeben, oder freilassen.');
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
            help('Stra·e und Hausnummer eingeben.');
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
            help('Postleitzahl und Wohnort eingeben.');
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
            help('Telefonnummer eingeben.');
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
            help('Wenn vorhanden, Faxnummer eingeben.');
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
            help('Name des Kreditinstitutes eingeben.');
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
            help('Kontonummer eingeben.');
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
            help('Bankleitzahl eingeben');
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
            help('Geburtsdatum in der Form TT.MM.JJJJ eingeben.');
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
            help('Geburtsort eingeben.');
            textcolor(black);
            textbackground(white);
            gebo:=input_field(14,19,30,white,blue,gebo,msg);
            gotoxy(14,19);
            write(gebo,' ':30-length(gebo));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     16 : begin
            help('Versicherungsnummer eingeben.');
            textcolor(black);
            textbackground(white);
            vers:=input_field(14,22,15,white,blue,vers,msg);
            gotoxy(14,22);
            write(vers,' ':15-length(vers));
            if msg='up'then dec(x);
            if msg='down' then x:=1;
            if (msg='') and (vvn<>'') then ende:=true
            else if (msg='') then x:=1;
          end;
      15 : begin
            help('Krankenkasse eingeben.');
            textcolor(black);
            textbackground(white);
            kk:=input_field(14,21,30,white,blue,kk,msg);
            gotoxy(14,21);
            write(kk,' ':30-length(kk));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            {if (msg='') and (vvn<>'') then ende:=true
            else if (msg='') then x:=1;}
            if msg='' then inc(x);
          end;
      14 : begin
            help('Geburtsname eingeben.');
            textcolor(black);
            textbackground(white);
            gebname:=input_field(14,20,30,white,blue,gebname,msg);
            gotoxy(14,20);
            write(gebname,' ':30-length(gebname));
            if msg='up'then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;

      end;
    until (ende) or (msg='can');
    if msg='can' then adreingabe:=false
    else
    begin
      adreingabe:=true;
      with vorgabe do
      begin
        if kennz='S' then kennzeichen:=1;
        if kennz='A' then kennzeichen:=2;
        if kennz='G' then kennzeichen:=3;
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
        krankenkasse:=kk;
        geburtsname:=gebname;
        protokoll('Adresse: '+name);
        protokoll('Adresse: '+zus1);
        protokoll('Adresse: '+zus2);
        protokoll('Adresse: '+strasse);
        protokoll('Adresse: '+ort);
        protokoll('Adresse: '+telefon);
        protokoll('Adresse: '+fax);
        protokoll('Adresse: '+bank);
        protokoll('Adresse: '+kto);
        protokoll('Adresse: '+blz);
        protokoll('Adresse: '+versnr);
        protokoll('Adresse: '+geburtsdat);
        protokoll('Adresse: '+geburtsort);
        protokoll('Adresse: '+geburtsname);
      end;
    end;
end;

function t(wert:real):real;
var m :real;
    i :integer;
begin
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

procedure adressortna;
var adr1,adr2   :persneu;
    zweite      :file of persneu;
    i,j         :integer;
    x,y         :longint;
begin
  if not exist(mand+'ADRESSEN.DAT') then exit;
  assign(adrdatei,mand+'ADRESSEN.DAT');
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
  assign(zweite,mand+'adrtem.$$$');
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
  rename(zweite,mand+'ADRESSEN.DAT');
  protokoll('Adressen nach Namen sortiert');
end;


procedure neuerfassung;
var erfasst       :boolean;
    neuadr,pruef  :persneu;
    code,pnr,ppr  :integer;
    groesse       :integer;
begin
  screen_init('Neuerfassung');
  colorbox(20,11,38,2,white,red,'ERMITTLE NEUE PERS-NR.');
  write('Bitte warten Sie einen Moment ...');
  with neuadr do
  begin
    persnr:='100';
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
    krankenkasse:='';
    kennzeichen:=2;
    geburtsname:='';
  end;
  reset(adrdatei);
  if filesize(adrdatei)>0 then
  begin
    code:=0;
    val(neuadr.persnr,pnr,code);
    repeat
      i:=0;
      if pnr<999 then inc(pnr);
      repeat
        seek(adrdatei,i);
        read(adrdatei,pruef);
        val(pruef.persnr,ppr,code);
        if ppr=pnr then i:=-2;
        inc(i);
        gotoxy(35,1);
        write(pause[(i mod 4)+1]);
      until (i=filesize(adrdatei)) or (i=-1);
    until (pnr=999) or (i>1);
    if i>0 then
      str(pnr,neuadr.persnr);
    close(adrdatei);
  end;
  colorbox_close;
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
        if i=-1 then
        begin
          erfasst:=false;
          colorbox(20,16,55,3,white,red,'Fehleingabe');
          gotoxy(1,1);
          write('Personalnummer bereits vergeben, ermittle neue.');
          code:=0;
          val(neuadr.persnr,pnr,code);
          repeat
            i:=0;
            if pnr<999 then inc(pnr);
            repeat
              seek(adrdatei,i);
              read(adrdatei,pruef);
              val(pruef.persnr,ppr,code);
              if ppr=pnr then i:=-2;
              inc(i);
            until (i=filesize(adrdatei)) or (i=-1);
          until (pnr=999) or (i>1);
          if i>0 then
            str(pnr,neuadr.persnr);
          gotoxy(1,2);
          write('Neue Personalnummer ist: ',pnr,'. Bitte RETURN drÅcken!');
          colorbox_close;
          help('Bitte RETURN drÅcken.');
          prreturn;
        end;
      end;
      close(adrdatei);
    end
    else
      erfasst:=false;
  until erfasst;
  reset(adrdatei);
  seek(adrdatei,filesize(adrdatei));
  write(adrdatei,neuadr);
  close(adrdatei);
  reset(adrdatei);
  groesse:=filesize(adrdatei);
  close(adrdatei);
  if groesse>1 then
    adressortna;
  protokoll('Neuaufnahme Adresse "'+neuadr.name+'"');
end;

function findeadr(var zusuchen:persneu):integer;

type listeneintrag = record
                       listentext :string[30];
                       dateipos   :longint;
                     end;

var vvn,rbn,msg           :string;
    x                     :integer;
    ende                  :boolean;
    pruef                 :persneu;
    liste                 :array[1..100] of listeneintrag;
    listcount             :integer;

  function auswahlbox:longint;
  var xx,i,offsetx,offsety    :integer;
      ch                      :char;
  begin
    screen_init('AuswÑhlen');
    help('Bitte einen Namen auswÑhlen');
    offsetx:=0;
    offsety:=1;
    for i:=1 to listcount do
    begin
      textcolor(lightcyan);
      gotoxy(5+offsetx,4+offsety);
      if (i mod 18)=0 then
      begin
        offsetx:=offsetx+32;
        offsety:=0;
      end;
      write(liste[i].listentext);
      inc(offsety);
    end;
    xx:=1;
    offsetx:=0;
    repeat
      textcolor(black);
      textbackground(white);
      gotoxy(5+offsetx,4+xx);
      write(liste[xx].listentext,copy('                              ',1,30-length(liste[xx].listentext)));
      textcolor(lightcyan);
      textbackground(black);
      if xx>1 then
      begin
        gotoxy(5,4+xx-1);
        write(liste[xx-1].listentext,copy('                              ',1,30-length(liste[xx-1].listentext)));

      end;
      if xx<listcount then
      begin
        if xx mod 18=0 then
          inc(offsetx,32);
        gotoxy(5+offsetx,4+xx+1);
        write(liste[xx+1].listentext,copy('                              ',1,30-length(liste[xx+1].listentext)));
      end;
      ch:=checkkeyboard;
      if (ch=chr(ord('H')+128)) and (xx>1) then dec(xx);
      if (ch=chr(ord('P')+128)) and (xx<listcount) then inc(xx);
    until (ch=#13) or (ch=#27);
    if ch=#27 then
    begin
      auswahlbox:=-1;
    end
    else
      auswahlbox:=liste[xx].dateipos;
  end;

begin
  listcount:=0;
  clock:=false;
  textcolor(lightcyan);
{  gotoxy(3,6);
  write('Pers.-Nr.: ');}
  gotoxy(3,5);
  write('Name     : ');
  textcolor(black);
  textbackground(white);
{  gotoxy(14,6);
  write(' ':3);}
  gotoxy(14,5);
  write(' ':30);
  x:=1;
  vvn:='';
  rbn:='';
  ende:=false;
  help('Bitte Namen eingeben');
  repeat
    case x of
      2 : begin
            if rbn='' then
            begin
              textcolor(black);
              textbackground(white);
              vvn:=input_field(14,6,3,white,blue,vvn,msg);
              if msg='up'then dec(x);
              if msg='down' then x:=1;
              if msg='' then ende:=true;
            end
            else
              ende:=true;
          end;
      1 : begin
            textcolor(black);
            textbackground(white);
            rbn:=input_field(14,5,30,white,blue,rbn,msg);
            gotoxy(14,5);
            write(rbn,' ':30-length(rbn));
            if msg='up'then x:=1;
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
  if not exist(mand+'ADRESSEN.DAT') then
  begin
    findeadr:=-1;
    clock:=true;
    exit;
  end;
  reset(adrdatei);
  if filesize(adrdatei)=0 then
  begin
    close(adrdatei);
    findeadr:=-1;
    clock:=true;
    exit;
  end;
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
      if upperline(copy(pruef.name,1,length(rbn)))=upperline(rbn) then
      begin
      {  findeadr:=x;
        close(adrdatei);
        clock:=true;
        exit;}
        if pruef.persnr<>'$$$$$' then
        begin
          inc(listcount);
          liste[listcount].listentext:=pruef.name;
          liste[listcount].dateipos:=x;
        end;
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
  if listcount=0 then
  begin
    findeadr:=-1;
    close(adrdatei);
    clock:=true;
    exit;
  end
  else
  if listcount>1 then
  begin
    close(adrdatei);
    findeadr:=auswahlbox;
    clock:=true;
    exit;
  end
  else
    findeadr:=liste[1].dateipos;
  close(adrdatei);
  clock:=true;
end;

procedure aenderung;
var posi             :integer;
    suchen,pruef     :persneu;
    geaendert        :boolean;
    vv               :string;
begin
  screen_init('AdressÑnderung');
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  close(adrdatei);
  vv:=suchen.persnr;
  repeat
    screen_init('AdressÑnderung');
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
  protokoll('Adresse geÑndert:');
  protokoll('Adresse: '+suchen.name);
  protokoll('Adresse: '+suchen.zus1);
  protokoll('Adresse: '+suchen.zus2);
  protokoll('Adresse: '+suchen.strasse);
  protokoll('Adresse: '+suchen.ort);
  protokoll('Adresse: '+suchen.telefon);
  protokoll('Adresse: '+suchen.fax);
  protokoll('Adresse: '+suchen.bank);
  protokoll('Adresse: '+suchen.kto);
  protokoll('Adresse: '+suchen.blz);
  protokoll('Adresse: '+suchen.versnr);
  protokoll('Adresse: '+suchen.geburtsname);
  protokoll('Adresse: '+suchen.geburtsdat);
  protokoll('Adresse: '+suchen.geburtsort);
  adressortna;
end;

function wloeschen:boolean;
var ch :char;
begin
  colorbox(35,17,34,2,white,green,'ADRESSE LôSCHEN');
  write('Adresse wirklich lîschen (J/N)?');
  colorbox_close;
  wloeschen:=yes('Adresse wirklich lîschen ');
end;

procedure loeschen;
var posi           :integer;
    suchen         :persneu;
    loeschfile     :file;
begin
  screen_init('Adresslîschung');
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  close(adrdatei);
  screen_init('Adresslsîschung');
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(3,6);
  write('Name     : ');
  gotoxy(3,7);
  write('Zusatz 1 : ');
  gotoxy(3,8);
  write('Zusatz 2 : ');
  gotoxy(3,9);
  write('Stra·e   : ');
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
  write('Geb.Datum: ');
  gotoxy(3,19);
  write('Geb.Ort  : ');
  gotoxy(3,21);
  write('Vers.-Nr.: ');
  gotoxy(3,20);
  write('Geb.Name : ');
  textcolor(white);
  with suchen do
  begin
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
    gotoxy(14,21);
    write(versnr);
    gotoxy(14,20);
    write(geburtsname);
  end;
  if wloeschen then
  begin
    reset(adrdatei);
    seek(adrdatei,posi);
    if exist(mand+suchen.persnr+'.DAT') then
    begin
       colorbox(15,19,55,2,white,red,'DATEN LôSCHEN');
       write('Es existieren Abrechnungsdaten, alles lîschen (J/N)?');
       colorbox_close;
       if yes('Es existieren Abrechnungsdaten, alles lîschen ') then
       begin
         assign(loeschfile,mand+suchen.persnr+'.DAT');
         erase(loeschfile);
         if exist(mand+suchen.persnr+'.REG') then
         begin
           assign(loeschfile,mand+suchen.persnr+'.REG');
           erase(loeschfile);
         end;
         suchen.persnr:='$$$$$';
         write(adrdatei,suchen);
         close(adrdatei);
         adressortna;
       end;
    end
    else
    begin
      suchen.persnr:='$$$$$';
      write(adrdatei,suchen);
      close(adrdatei);
      adressortna;
    end;
    protokoll('Adresse gelîscht "'+suchen.name+'"');
  end;
end;

procedure listen;
var i,y,beg,x :integer;
    auswahl   :select;
    ausgabe,
    msg       :string;
    listdr    :text;
    abog      :file of abogeld;
    abo       :abogeld;
    counter   :integer;
begin
  reset(adrdatei);
  if filesize(adrdatei)=0 then exit;
  screen_init('Personalliste');
  help('Bitte Ausgabeart mit dem Pfeiltasten wÑhlen, ESC=Abbruch');
  textcolor(lightcyan);
  gotoxy(5,5);
  write('Ausgabeliste: ');
  auswahl[0]:='Telefonliste/Bildschirm';
  auswahl[1]:='Adressliste/Drucker';
  auswahl[2]:='RegelmÑ·ige Zahlungen';
  beg:=0;
  counter:=1;
  ausgabe:=input_select(19,5,23,3,beg,white,blue,auswahl,msg);
  if msg='can' then exit;
  if ausgabe='Telefonliste/Bildschirm' then
  begin
    textcolor(lightred);
    gotoxy(1,24);
    write(' # ');
    textcolor(cyan);
    write('= RegelmÑ·ige Zahlung gespeichert');
    textcolor(white);
    gotoxy(1,23);
    write(' * ');
    textcolor(cyan);
    write('= Zahlungen erfasst');
    textcolor(white);
    gotoxy(1,4);
    write(' Nr.  Name                          Zusatz                   Telefon');
    textcolor(cyan);
    y:=5;
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,vvadresse);
      textcolor(cyan);
      if vvadresse.persnr<>'$$$$$' then
      begin
        gotoxy(1,y);
        write(counter:4);
        inc(counter);
        if exist(mand+vvadresse.persnr+'.DAT') then
        begin
          textcolor(white);
          write('*');
          textcolor(cyan);
        end
        else write(' ');
        if exist(mand+vvadresse.persnr+'.REG') then
        begin
          textcolor(lightred);
          write('#');
          textcolor(cyan);
        end
        else write(' ');
        write(vvadresse.name+copy(dreissig,1,30-length(vvadresse.name)));
        write(vvadresse.zus1+copy(dreissig,1,25-length(vvadresse.zus1)),vvadresse.telefon);
        inc(y);
      end;
      if y mod 22=0 then
      begin
        help('Bitte RETURN drÅcken ...');
        prreturn;
        screen_init('Personalliste');
        textcolor(lightred);
        gotoxy(1,24);
        write(' # ');
        textcolor(cyan);
        write('= RegelmÑ·ige Zahlung gespeichert');
        textcolor(white);
        gotoxy(1,23);
        write(' * ');
        textcolor(cyan);
        write('= Zahlungen erfasst');
        textcolor(white);

        textcolor(white);
        gotoxy(1,4);
        write(' Nr.  Name                          Zusatz                   Telefon');
        textcolor(cyan);
        y:=5;
      end;
    end;
  end;
  if ausgabe='Adressliste/Drucker' then
  begin
{    assign(listdr,'LISTE.TXT');
    rewrite(listdr);}
    writeln(lst,'');
    writeln(lst,'Liste der Aushilfen');
    writeln(lst,'Stand: ',datum);
    writeln(lst,'');
    x:=0;
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,vvadresse);
      if vvadresse.persnr<>'$$$$$' then
      begin
       with vvadresse do
       begin
         {writeln(lst,'PersNr.   : ',persnr);}
         write(lst,'Name      : ',name,' ');
         if geburtsname<>'' then
           writeln(lst,'(Geb. ',geburtsname,')')
         else
           writeln(lst,'');
         writeln(lst,'Zusatz 1  : ',zus1);
         writeln(lst,'Zusatz 2  : ',zus2);
         writeln(lst,'Stra·e    : ',strasse);
         writeln(lst,'Ort       : ',ort);
         writeln(lst,'Telefon   : ',telefon);
         writeln(lst,'VersNr.   : ',versnr);
         writeln(lst,'Geb.Datum : ',geburtsdat);
         writeln(lst,'Bank      : ',bank,' BLZ (',blz,')');
         writeln(lst,'Konto     : ',kto);
         writeln(lst,'Krankenk. : ',krankenkasse);
         writeln(lst,'');
         writeln(lst,'-----------------------------------------------------------------------');
         writeln(lst,'');
         inc(x);
         if x = 4 then
         begin
           writeln(lst,#12);
           x:=0;
         end;
       end;
      end;
    end;
    protokoll('Ausdruck: Adressliste');
    writeln(lst,#12);
  end;
  if ausgabe='RegelmÑ·ige Zahlungen' then
  begin
    textcolor(white);
    gotoxy(1,4);
    write(' Nr.  Name                          Betrag');
    textcolor(cyan);
    y:=5;
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,vvadresse);
      textcolor(cyan);
      if vvadresse.persnr<>'$$$$$' then
      begin
        gotoxy(1,y);
        write(counter:4);
        inc(counter);
        if exist(mand+vvadresse.persnr+'.DAT') then
        begin
          textcolor(white);
          write('*');
          textcolor(cyan);
        end
        else write(' ');
        if exist(mand+vvadresse.persnr+'.REG') then
        begin
          assign(abog,mand+vvadresse.persnr+'.REG');
          reset(abog);
          read(abog,abo);
          close(abog);
          textcolor(lightred);
          write('#');
          textcolor(cyan);
        end
        else write(' ');
        write(vvadresse.name+copy(dreissig,1,30-length(vvadresse.name)));
        if exist(mand+vvadresse.persnr+'.REG') then
          write(abo.betrag:6:2,' DM  ')
        else
          write('             ');
        inc(y);
      end;
      if y mod 22=0 then
      begin
        help('Bitte RETURN drÅcken ...');
        prreturn;
        screen_init('Personalliste');
        textcolor(lightred);
        gotoxy(1,24);
        write(' # ');
        textcolor(cyan);
        write('= RegelmÑ·ige Zahlung gespeichert');
        textcolor(white);
        gotoxy(1,23);
        write(' * ');
        textcolor(cyan);
        write('= Zahlungen erfasst');
        textcolor(white);

        textcolor(white);
        gotoxy(1,4);
        write(' Nr.  Name                          Betrag');
        textcolor(cyan);
        y:=5;
      end;
    end;
  end;
  close(adrdatei);
  help('Bitte RETURN drÅcken ...');
  prreturn;
end;


procedure erfassen;
var posi,
    beg,j    :integer;
    suchen   :persneu;
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
    ges,gst  :real;
    passwort :string;
    passcode,
    n        :integer;
    achtung  :boolean;

begin
  if not exist(mand+'ADRESSEN.DAT') then exit;
  clock:=false;
  achtung:=false;
  for x:=0 to 11 do
    auswahl[x]:=monatel[x+1];
  screen_init('Stunden erfassen');
  clock:=false;
  posi:=findeadr(suchen);
  if posi=-1 then
  begin
    nichtmehr:=true;
    exit;
  end;
  screen_init('Stunden erfassen');
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  textcolor(lightcyan);
  textbackground(black);
{  gotoxy(3,5);
  write('Pers.-Nr.: ');}
  gotoxy(3,5);
  write('Name     : ');
  textcolor(white);
{  gotoxy(14,5);
  write(suchen.persnr);}
  gotoxy(14,5);
  write(suchen.name);
  datei:=suchen.persnr+'.DAT';
  assign(stddat,mand+datei);
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
  gotoxy(3,4);
  write('Name     : ');
  textcolor(white);
  gotoxy(14,4);
  write(suchen.name);
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(40,4);
  write('Abrechnungszeitraum : ');
  textcolor(white);
  gotoxy(62,4);
  write(std.monat,' ',std.jahr);
  textcolor(lightcyan);
  repeat
    px:=2;
    py:=6;
    ges:=0.0;
    textcolor(lightcyan);
    gotoxy(2,5);
    write('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');
    gotoxy(2,23);
    write('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');
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
    gotoxy(16,23);
    write('Gesamtstunden: ');
    clear_window(2,6,78,18,black);
    if std.nachweis[32].gesamt<>0.0 then
    begin
      textcolor(red);
      gotoxy(22,22);
      write('1.-',tage_monat(std.monat),'. d.M. Pauschale: ',std.nachweis[32].gesamt:6:2,' DM');
      gotoxy(20,24);
      write(' ':38);
      ges:=ges+std.nachweis[32].gesamt;
    end;
    gst:=0.0;
    for x:=1 to 31 do
    begin
      if (std.nachweis[x].anzstd=0.0) or (std.nachweis[x].gesamt=0.0) or (std.nachweis[x].stdlohn=0.0) then
      begin
        std.nachweis[x].anzstd:=0.0;
        std.nachweis[x].stdlohn:=0.0;
        std.nachweis[x].gesamt:=0.0;
      end;
      if std.nachweis[x].gesamt<>0.0 then
      begin
        gotoxy(px,py);
        if py mod 2=0 then textcolor(white)
        else textcolor(lightgray);
        write(std.nachweis[x].arbeitsdatum,', ');
        if (py mod 2=0) and (std.nachweis[x].anzstd>=configurat.maxwoche) then
          textcolor(white+blink)
        else
          if (py mod 2<>0) and (std.nachweis[x].anzstd>=configurat.maxwoche) then
            textcolor(lightgray+blink);
        write(std.nachweis[x].anzstd:5:2,'h † ');
        write(std.nachweis[x].stdlohn:5:2,' DM ');
        write(std.nachweis[x].gesamt:6:2,' DM');
        ges:=ges+std.nachweis[x].gesamt;
        gst:=gst+std.nachweis[x].anzstd;
        inc(py);
        if py=22 then
        begin
          py:=6;
          px:=42;
        end;
      end;
    end;
    textcolor(white);
    gotoxy(31,23);
    write(gst:4:2);
    gotoxy(70,24);
    write('         ');
    gotoxy(70,24);
    if ges>configurat.maxlohn then textcolor(white+blink)
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
        help('Tag eingeben (RETURN=Heute), ''p''= Pauschale, ''l''= lîschen, ESC=Ende');
        textcolor(white);
        tag:=input_field(18,24,2,white,blue,'',msg);
        if tag='p' then tag:='P';
        if tag='l' then tag:='L';
        if tag='L' then
        begin
          if not yes('Die gesamten Arbeitszeit-Daten dieser Arbeitskraft lîschen ') then
            tag:='+';
        end;
        if (msg='') and (tag='') then tag:=copy(datum,1,2);
        val(tag,tagnum,code);
      until (code=0) or (msg='can') or (tag='P') or (tag='*') or (tag='L') or (tagnum>0);
      if (tag<>'P') and (tag<>'*') then
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
    until (pos(':',tag)=0) and (pos('.',tag)=0) and (pos(',',tag)=0) and (tagnum<=tage_monat(std.monat));
    if (tag='P') or (tag='*') then
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
        pausch:=input_field(47,24,8,white,blue,pausch,msg);
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
    if (tag<>'L') and (tag<>'P') and (tag<>'*') then
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
                  help('Bitte Anzahl der gearbeiteten Stunden eingeben, 0=Eintrag lîschen');
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
                  if ges=0.0 then
                  begin
                    close(stddat);
                    erase(stddat);
                    clock:=true;
                    exit;
                  end
                  else
                  begin
                    x:=3;
                    if (stl='') or (st='') then
                    begin
                      std.nachweis[tagnum].anzstd:=0.0;
                      std.nachweis[tagnum].stdlohn:=0.0;
                      std.nachweis[tagnum].gesamt:=0.0;
                    end;
                  end;
                end;
                if (msg='') or (msg='left') or (msg='right') or (msg='up') or (msg='down') then inc(x);
              end;
          2 : begin
                msg:='';
                repeat
                  if stl='' then
                  begin
                    stl:='12';
                    achtung:=false;
                  end
                  else
                    achtung:=true;
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
                  stl:='';
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
                  if ges=0.0 then
                  begin
                    close(stddat);
                    erase(stddat);
                    clock:=true;
                    exit;
                  end
                  else
                  begin
                    msg:='';
                    if ((stl='') or (st='')) and (not achtung) then
                    begin
                      std.nachweis[tagnum].anzstd:=0.0;
                      std.nachweis[tagnum].stdlohn:=0.0;
                      std.nachweis[tagnum].gesamt:=0.0;
                    end;
                  end;
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
    protokoll('Stunden erfasst fÅr "'+std.name+'"');
  until (tag='XXXXX');
  prreturn;
end;

procedure erzeuge_abrechnung(suchen:persneu);
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
  write('Bitte warten, erzeuge Abrechnung fÅr ');
  if not exist(mand+suchen.persnr+'.DAT') then exit;
  assign(stddat,mand+suchen.persnr+'.DAT');
  reset(stddat);
  seek(stddat,0);
  read(stddat,std);
  close(stddat);
  textcolor(white);
  write(std.name);
  assign(abdatei,mand+suchen.persnr+'.TXT');
  rewrite(abdatei);
  ges:=0.0;
  gst:=0.0;
  for i:=1 to 32 do
  begin
    ges:=ges+std.nachweis[i].gesamt;
    gst:=gst+std.nachweis[i].anzstd;
  end;
  for i:=1 to 2 do
    writeln(abdatei,'');
  writeln(abdatei,'     ',configurat.firma1);
  writeln(abdatei,'     ',configurat.firma2);
  writeln(abdatei,'');
  writeln(abdatei,'     Aushilfen Abrechnung Monat ',std.monat,' / ',std.jahr);
  writeln(abdatei,'');
  write  (abdatei,'     Name         : ',suchen.name,' ');
  if suchen.geburtsname<>'' then writeln(abdatei,'geb. ',suchen.geburtsname)
  else writeln(abdatei,'');
  writeln(abdatei,'     Zusatz Nr. 1 : ',suchen.zus1);
  writeln(abdatei,'     Zusatz Nr. 2 : ',suchen.zus2);
  writeln(abdatei,'     Geburtsdatum : ',suchen.geburtsdat);
  writeln(abdatei,'     Stra·e       : ',suchen.strasse);
  writeln(abdatei,'     Wohnort      : ',suchen.ort);
  writeln(abdatei,'     SozialversNr.: ',suchen.versnr);
  writeln(abdatei,'     Krankenkasse : ',suchen.krankenkasse);
  writeln(abdatei,'');
  writeln(abdatei,'      Voraussetzungen: weniger als ',configurat.maxwoche:2,' Wochenstunden,');
  writeln(abdatei,'                       maximaler Verdienst ',configurat.maxlohn:8:2,' DM');
  writeln(abdatei,'');
  writeln(abdatei,'     Arbeitszeitabrechung:');
  writeln(abdatei,'     ---------------------');
  writeln(abdatei,'');
  writeln(abdatei,'         Datum:       Stunden:     Stundenlohn:       Betrag:');
  writeln(abdatei,'');
  if std.nachweis[32].gesamt<>0.0 then
  begin
    write(abdatei,'         1.-',tage_monat(std.monat));
    writeln(abdatei,'. d.M.         pauschal                ',std.nachweis[32].gesamt:8:2,' DM');
    writeln(abdatei,'');
  end;
  z:=1;
  anztage:=0;
  for i:=1 to 31 do
  begin
    if std.nachweis[i].anzstd<>0.0 then
    begin
      write(abdatei,'     ',z:2,'. ',std.nachweis[i].arbeitsdatum,'     ',std.nachweis[i].anzstd:5:2,'    †    ');
      writeln(abdatei,std.nachweis[i].stdlohn:6:2,' DM        ',std.nachweis[i].gesamt:8:2,' DM');
      inc(z);
      inc(anztage);
    end;
  end;
  if anztage<>0 then
  begin
    writeln(abdatei,'');
    writeln(abdatei,'     ',anztage:2,' Tage         ',gst:6:2,' Stunden          Gesamt: ',ges:8:2,' DM');
  end;
  writeln(abdatei,'     ===========================================================');
  for i:=1 to 18-anztage do
    writeln(abdatei,'');
  writeln(abdatei,'     Ich erklÑre, da· ich im vorgenannten Monatszeitraum keine weitere');
  writeln(abdatei,'     NebenbeschÑftigung im Sinne der gesetzlichen Regelung der Sozial-');
  writeln(abdatei,'     versicherung fÅr unregelmÑ·ig BeschÑftigte ausÅbe.');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Datum __________________  Unterschrift _X_______________________ ');
  writeln(abdatei,'');
  writeln(abdatei,'     Wir versichern, da· die oben genannten Aufzeichnungen richtig sind,');
  writeln(abdatei,'     und weisen den Gesamtbetrag von ',ges:6:2,' DM hiermit an.');
  if suchen.kto<>'' then
  begin
    writeln(abdatei,'     Die öberweisung erfolgt auf das Konto ',suchen.kto);
    writeln(abdatei,'     bei ''',suchen.bank,''', (BLZ ',suchen.blz,')');
  end
  else
  begin
    writeln(abdatei,'     Die Auszahlung erfolgt in BAR.');
    writeln(abdatei,'');
  end;
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     Datum __________________  Unterschrift _________________________ ');
  if lizenz=noreg then
  begin
    writeln(abdatei,'');
    writeln(abdatei,'   ---> Gedruckt mit einer unregistrierten Version von MR-PERS!!! <---');
  end;
  close(abdatei);
  erase(stddat);
  protokoll('Abrechung erzeugt fÅr "'+suchen.name+'"');
  reset(datenbank);
  seek(datenbank,filesize(datenbank));
  std.nachweis[32].arbeitsdatum:=copy(datum,1,5)+'.'+copy(datum,9,2);
  write(datenbank,std);
  close(datenbank);
end;

(* procedure erzeuge_abrechnung_leer(suchen:persneu);
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
  write('Bitte warten, erzeuge Abrechnung fÅr ');
  if not exist(mand+suchen.persnr+'.DAT') then exit;
  assign(stddat,mand+suchen.persnr+'.DAT');
  reset(stddat);
  seek(stddat,0);
  read(stddat,std);
  close(stddat);
  textcolor(white);
  write(std.name);
  assign(abdatei,mand+suchen.persnr+'.TXT');
  rewrite(abdatei);
  ges:=0.0;
  gst:=0.0;
  for i:=1 to 32 do
  begin
    ges:=ges+std.nachweis[i].gesamt;
    gst:=gst+std.nachweis[i].anzstd;
  end;
  for i:=1 to 2 do
    writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'                          Monat ',std.monat,' / ',std.jahr);
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'                    ',suchen.name);
  writeln(abdatei,'                    ',suchen.zus1);
  writeln(abdatei,'                    ',suchen.zus2);
  writeln(abdatei,'                    ',suchen.geburtsdat);
  writeln(abdatei,'                    ',suchen.strasse);
  writeln(abdatei,'                    ',suchen.ort);
  writeln(abdatei,'                    ',suchen.versnr);
  writeln(abdatei,'                    ',suchen.krankenkasse);
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
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
      write(abdatei,'     ',z:2,'. ',std.nachweis[i].arbeitsdatum,'     ',std.nachweis[i].anzstd:5:2,'    †    ');
      writeln(abdatei,std.nachweis[i].stdlohn:6:2,' DM        ',std.nachweis[i].gesamt:6:2,' DM');
      inc(z);
      inc(anztage);
    end;
  end;
  writeln(abdatei,'');
  writeln(abdatei,'     ',anztage:2,' Tage         ',gst:6:2,' Stunden        Gesamt: ',ges:8:2,' DM');
  writeln(abdatei,'     =========================================================');
  for i:=1 to 18-anztage do
    writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'     und weisen den Gesamtbetrag von ',ges:6:2,' DM hiermit an.');
  writeln(abdatei,'     Die öberweisung erfolgt auf das Konto ',suchen.kto);
  writeln(abdatei,'     bei ''',suchen.bank,''', (BLZ ',suchen.blz,')');
  writeln(abdatei,'');
  writeln(abdatei,'');
  writeln(abdatei,'');
  close(abdatei);
  erase(stddat);
  protokoll('Abrechung erzeugt fÅr "'+suchen.name+'"');
  reset(datenbank);
  seek(datenbank,filesize(datenbank));
  std.nachweis[32].arbeitsdatum:=copy(datum,1,5)+'.'+copy(datum,9,2);
  write(datenbank,std);
  close(datenbank);
end; *)


procedure einzelab(leer:boolean);
var posi      :integer;
    such      :persneu;
    passwort  :string[10];
    msg       :string;
    n         :integer;
    passcode  :longint;
begin
  screen_init('Einzelabrechung');
  clock:=false;
  if configurat.passwd<>170 then
  begin
    help('Bitte Zungangscode eingeben, oder ESC fÅr Abbruch');
    colorbox(25,10,31,4,white,red,'Zugangskontrolle');
    gotoxy(2,2);
    write('Bitte Zugangscode eingeben:');
    passwort:=upperline(input_field(2,3,10,red,red,'',msg));
    passcode:=0;
    for n:=1 to length(passwort) do
      passcode:=passcode+ord(passwort[n]);
    passcode:=passcode xor 170;
    if msg='can' then
    begin
      colorbox_close;
      exit;
    end;
    if (passcode<>configurat.passwd) and (passcode<>358) then
    begin
      colorbox_close;
      exit;
    end;
    colorbox_close;
  end;
  screen_init('Einzelabrechung');
  clock:=true;
  posi:=findeadr(such);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,such);
  close(adrdatei);
  erzeuge_abrechnung(such);
  if exist(mand+such.persnr+'.TXT') then drucke_datei(mand+such.persnr+'.TXT');
end;

procedure gesamtab(leer:boolean);
var abmon,
    abjahr,
    msg          :string;
    ges,
    gst,
    geszu,
    gstzu,
    kist         :real;
    auswahl      :select;
    x,
    beg,
    i,
    j,
    anzd,
    code         :integer;
    such         :persneu;
    zusfas,zus1      :text;
    stddat           :file of stunden;
    std              :stunden;
    arbeiterka       :real;
    angestka         :real;
    passwort         :string[10];
    passcode         :longint;
    n                :integer;
    abobetrag        :boolean;
    abrechnungsdaten :boolean;
    regeldat         :file of abogeld;
    regelgeld        :abogeld;
begin
  screen_init('Gesamtabrechung');
  clock:=false;
  if configurat.passwd<>170 then
  begin
    help('Bitte Zungangscode eingeben, oder ESC fÅr Abbruch');
    colorbox(25,10,31,4,white,red,'Zugangskontrolle');
    gotoxy(2,2);
    write('Bitte Zugangscode eingeben:');
    passwort:=upperline(input_field(2,3,10,red,red,'',msg));
    passcode:=0;
    for n:=1 to length(passwort) do
      passcode:=passcode+ord(passwort[n]);
    passcode:=passcode xor 170;
    if msg='can' then
    begin
      colorbox_close;
      exit;
    end;
    if (passcode<>configurat.passwd) and (passcode<>358) then
    begin
      colorbox_close;
      exit;
    end;
    colorbox_close;
  end;
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
  gst:=0.0;
  geszu:=0.0;
  gstzu:=0.0;
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
  assign(zusfas,mand+'ZUSFAS.TXT');
  assign(zus1,mand+'PERSO.TXT');
  rewrite(zus1);
  rewrite(zusfas);
  writeln(zusfas,'     Zusammenfassung fÅr Monat ',abmon,' / ',abjahr);
  writeln(zusfas,'');
  writeln(zusfas,'');
  writeln(zusfas,'     Versicherungs Nr:                     Name:        Lohn:     Stunden:');
  writeln(zusfas,'');
  writeln(zus1,'     Zusammenfassung fÅr Monat ',abmon,' / ',abjahr);
  writeln(zus1,'     Version fÅr Personalabteilung');
  writeln(zus1,'');
  writeln(zus1,'                                           Name:        Lohn:     Stunden:');
  writeln(zus1,'');
  reset(adrdatei);
  close(adrdatei);
  reset(adrdatei);
  abobetrag:=false;
  abrechnungsdaten:=false;
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,such);
    if exist(mand+such.persnr+'.REG') then
      abobetrag:=true;
    if exist(mand+such.persnr+'.DAT') then
    begin
      abrechnungsdaten:=true;
      assign(stddat,mand+such.persnr+'.DAT');
      reset(stddat);
      seek(stddat,0);
      read(stddat,std);
      close(stddat);
      if (std.monat=abmon) and (std.jahr=abjahr) then
      begin
        for j:=1 to 32 do
        begin
          ges:=ges+std.nachweis[j].gesamt;
          gst:=gst+std.nachweis[j].anzstd;
        end;
        write(zusfas,'     ',such.versnr:17,' ',such.name:25,'  ',ges:8:2,' DM    ');
        if gst<>0.0 then
          writeln(zusfas,gst:6:2,' Std')
        else
          writeln(zusfas,' pauschal ');
        writeln(zusfas,'     Konto: ',such.kto:10,' BLZ: ',such.blz,' Bank: ',copy(such.bank,1,30));
        writeln(zusfas,'     ---------------------------------------------------------------------');
        writeln(zus1,'                       ',such.name:25,'    ',ges:6:2,' DM    ',gst:5:2,' Std');
        if such.persnr>'900' then
        begin
          if ges>=100.0 then
          begin
            if frac(ges/100)=0.0 then arbeiterka:=arbeiterka+(configurat.abkam*int(ges/100));
            if frac(ges/100)<>0.0 then arbeiterka:=arbeiterka+(configurat.abkam*(int(ges/100)+1));
          end
          else arbeiterka:=arbeiterka+configurat.abkam;
        end
        else
        begin
          if ges>=100.0 then
          begin
            if frac(ges/100)=0.0 then angestka:=angestka+(configurat.ankam*int(ges/100));
            if frac(ges/100)<>0.0 then angestka:=angestka+(configurat.ankam*(int(ges/100)+1));
          end
          else angestka:=angestka+configurat.ankam;
        end;
        geszu:=geszu+ges;
        gstzu:=gstzu+gst;
        ges:=0.0;
        gst:=0.0;
        erzeuge_abrechnung(such);
        for anzd:=1 to configurat.anzdru do
          drucke_datei(mand+such.persnr+'.TXT');
      end;
    end;
  end;
  close(adrdatei);
  kist:=0.0;
  writeln(zusfas,'');
  writeln(zusfas,'                                          Gesamt: ',geszu:8:2,' DM   ',gstzu:6:2,' Std.');
  writeln(zusfas,'                                                  ===========');
  writeln(zusfas,'');
(*  writeln(zusfas,'     Pauschale Steuern:');
  writeln(zusfas,'                                         ===========');*)
  writeln(zus1,'');
  writeln(zus1,'                                          Gesamt: ',geszu:8:2,' DM   ',gstzu:6:2,' Std.');
  writeln(zus1,'                                                  ===========');
  writeln(zus1,'');
  writeln(zus1,'     Pauschale Steuern: werden zur Zeit nicht ausgedruckt!!!');
  writeln(zus1,'');
  close(zusfas);
  close(zus1);
  if geszu<>0.0 then
  begin
    for anzd:=1 to configurat.anzdru do
      drucke_datei(mand+'ZUSFAS.TXT');
    for anzd:=1 to configurat.anzdru do
      drucke_datei(mand+'PERSO.TXT');
  end;
  if abobetrag and abrechnungsdaten then
  begin
    screen_init('RegelmÑ·ige BetrÑge');
    textcolor(lightcyan);
    gotoxy(5,3);
    write('BetragsÅbernahme fÅr den nÑchsten Abrechnungszeitraum:');
    gotoxy(5,5);
    write('Neuer Abrechungsmonat: ');
    gotoxy(5,6);
    write('Neues Abrechnungsjahr: ');
    beg:=0;
    val(copy(datum,4,2),beg,code);
    if beg=12 then beg:=0;
    abjahr:=copy(datum,7,4);
    clock:=false;
    x:=1;
    repeat
      case x of
        1 : begin
              msg:='';
              clock:=false;
              abmon:=input_select(28,5,15,12,beg,white,blue,auswahl,msg);
              gotoxy(28,5);
              textcolor(black);
              textbackground(white);
              write(' ':15-length(abmon),abmon);
              if msg='can'then exit;
              if (msg='') or (msg='down') or (msg='up') then inc(x);
            end;
        2 : begin
              msg:='';
              clock:=false;
              abjahr:=input_field(28,6,4,white,blue,abjahr,msg);
              textcolor(black);
              textbackground(white);
              gotoxy(28,6);
              write(abjahr);
              if msg='can' then exit;
              if msg='' then inc(x);
              if msg='up' then dec(x);
              if msg='down' then dec(x);
            end;
      end;
    until x=3;
    reset(adrdatei);
    for i:=0 to filesize(adrdatei)-1 do
    begin
      seek(adrdatei,i);
      read(adrdatei,such);
      if exist(mand+such.persnr+'.REG') then
      begin
        assign(regeldat,mand+such.persnr+'.REG');
        reset(regeldat);
        read(regeldat,regelgeld);
        close(regeldat);
        assign(stddat,mand+such.persnr+'.DAT');
        rewrite(stddat);
        std.persnr:=such.persnr;
        std.name:=such.name;
        std.monat:=abmon;
        std.jahr:=abjahr;
        for x:=1 to 32 do
        begin
          std.nachweis[x].anzstd:=0.0;
          std.nachweis[x].stdlohn:=0.0;
          std.nachweis[x].gesamt:=0.0;
        end;
        std.nachweis[32].gesamt:=regelgeld.betrag;
        write(stddat,std);
        close(stddat);
      end;
    end;
    close(adrdatei);
  end;
end;

procedure einzelabnd;
var posi  :integer;
    such  :persneu;
begin
  screen_init('Einzelnachdruck');
  clock:=true;
  posi:=findeadr(such);
  if posi=-1 then
  begin
    clock:=false;
    exit;
  end;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,such);
  close(adrdatei);
  drucke_datei(mand+such.persnr+'.TXT');
  clock:=false;
end;

procedure zusfasnd;
begin
  drucke_datei(mand+'ZUSFAS.TXT');
end;

procedure nachab;
var menu      :menuitems;
    auswahl   :integer;
begin
  screen_init('Nachdrucken');
  mhotkey:=true;
  mhelptext:=true;
  showmouse;
  menu[1].menutext:='Einzelne Abrechnung';
  menu[1].help:='Monatsabrechnung fÅr eine einzelne Aushilfe nachdrucken';
  menu[1].key:='E';
  menu[2].menutext:='ZusammenFassung';
  menu[2].help:='Zusammenfassung aller Aushilfen nachdrucken';
  menu[2].key:='F';
  menu[3].menutext:='ZurÅck ins AbrechnungsmenÅ';
  menu[3].help:='Ins AbrechnungsmenÅ wechseln';
  menu[3].key:='Z';
  repeat
    screen_init('NachdruckmenÅ');
    menuselect(3,menu,auswahl);
    case auswahl of
      1  : einzelabnd;
      2  : zusfasnd;
    end;
    clock:=true;
  until auswahl=3;
  hidemouse;
end;

procedure abrechmenu;
var menu      :menuitems;
    auswahl   :integer;
begin
  screen_init('AbrechnungsmenÅ');
  mhotkey:=true;
  mhelptext:=true;
  showmouse;
  menu[1].menutext:='Einzelne Abrechnung';
  menu[1].help:='Monatsabrechnung fÅr eine einzelne Aushilfe';
  menu[1].key:='E';
  menu[2].menutext:='Alle abrechnen';
  menu[2].help:='Monatsabrechnug fÅr alle Aushilfen';
  menu[2].key:='A';
  menu[3].menutext:='Nachdrucken';
  menu[3].help:='Einzelabrechnungen oder Zusammenfassungen nachdrucken';
  menu[3].key:='N';
  menu[4].menutext:='ZurÅck ins HauptmenÅ';
  menu[4].help:='Ins HauptmenÅ wechseln';
  menu[4].key:='Z';
  repeat
    screen_init('AbrechnungsmenÅ');
    menuselect(4,menu,auswahl);
    case auswahl of
      1  : einzelab(false);
      2  : gesamtab(false);
      3  : nachab;
    end;
    clock:=true;
  until auswahl=4;
  hidemouse;
end;

procedure startbild;
var regtext  :text;
    zeile    :string;
    code,i   :integer;
    key      :longint;
    f        :file;
    ftime    :longint;
begin
  temporaer:=false;
  nichtmehr:=false;
  if (lizenz=noreg) and (upperline(paramstr(1))<>'-IGNORIEREN') then
  begin
    if not exist(mand+'LIESMICH.TXT') then
    begin
      clrscr;
      colorbox(1,2,78,2,white,red,'DATEI FEHLT');
      gotoxy(2,1);
      write('  Die Datei "LIESMICH.TXT" fehlt, AusfÅhrung von MR-PERS abgebrochen!');
      colorbox_close;
      gotoxy(1,6);
      lowvideo;
      textcolor(white);
      protokoll('AusfÅhrung wegen fehlender Datei abgebrochen!!!');
      halt;
    end;
    if not exist(mand+'REGFORM.TXT') then
    begin
      clrscr;
      colorbox(1,2,78,2,white,red,'DATEI FEHLT');
      gotoxy(2,1);
      write('  Die Datei "REGFORM.TXT" fehlt, AusfÅhrung von MR-PERS abgebrochen!');
      colorbox_close;
      gotoxy(1,6);
      lowvideo;
      textcolor(white);
      protokoll('AusfÅhrung wegen fehlender Datei abgebrochen!!!');
      halt;
    end
    else
    begin
      assign(regtext,mand+'REGFORM.TXT');
      reset(regtext);
      readln(regtext,zeile);
      close(regtext);
      if zeile<>'MR-PERS '+version then
      begin
        clrscr;
        colorbox(1,2,78,2,white,red,'DATEI FALSCH');
        gotoxy(2,1);
        write('  Die Datei "REGFORM.TXT" ist falsch, AusfÅhrung von MR-PERS abgebrochen!');
        colorbox_close;
        gotoxy(1,6);
        lowvideo;
        textcolor(white);
        protokoll('AusfÅhrung wegen falschem Dateiinhalt abgebrochen!!!');
        halt;
      end;
    end;
  end;
  if lizenz=noreg then protokoll('Programmstart SHAREWARE')
  else protokoll('Programmstart LIZENZVERSION: '+write_name);
  assign(adrdatei,mand+'ADRESSEN.DAT');
  {$I-}
  reset(adrdatei);
  {$I+}
  if IOresult<>0 then
    rewrite(adrdatei);
  close(adrdatei);
  assign(datenbank,mand+'DATENBNK.DAT');
  if not exist(mand+'DATENBNK.DAT') then
  begin
    rewrite(datenbank);
    close(datenbank);
  end;
  if not exist(mand+'MR-PERS.CFG') then
  begin
    assign(confile,mand+'MR-PERS.CFG');
    rewrite(confile);
    if lizenz=noreg then
      configurat.firma1:=''
    else
      configurat.firma1:=write_name;
    configurat.firma2:='';
    configurat.maxlohn:=500.0;
    configurat.maxwoche:=15;
    configurat.lohnst:=15;
    configurat.kist:=7;
    configurat.ankam:=0.15;
    configurat.abkam:=0.15;
    configurat.passwd:=(ord('P')+ord('A')+ord('S')+ord('S')+ord('W')+ord('O')+ord('R')+ord('T')) xor 170;
    configurat.initdat:='--.--.----';
    configurat.counter:=5;
    configurat.anzdru:=1;
    configurat.druckerinit:='';
    for i:=1 to 99 do
      configurat.erweitert[i]:=255;
    write(confile,configurat);
    close(confile);
  end
  else
  begin
    assign(confile,mand+'MR-PERS.CFG');
    reset(confile);
    getftime(confile,ftime);
    read(confile,configurat);
    close(confile);
    if configurat.initdat<>'--.--.----'then
      if (configurat.initdat<>datum) and (configurat.counter>0) then
      begin
        dec(configurat.counter);
        temporaer:=true;
        rewrite(confile);
        write(confile,configurat);
        close(confile);
        reset(confile);
        setftime(confile,ftime);
        close(confile);
      end;
      if (configurat.initdat=datum) and (configurat.counter>0) then temporaer:=true;
  end;
  screen_init('Programm Start');
  if pos('·',version)<>0 then
  begin
    textcolor(red+blink);
    gotoxy(21,21);
    writeln('Dies ist eine Vorabversion zum Testen!');
    gotoxy(21,22);
    writeln('   Bei Stîrungen: Tel.: 0172 4207818');
    textcolor(white);
  end;
  val(paramstr(1),key,code);
  if (lizenz=noreg) and (code=0) and (configurat.counter=5) then
  begin
    key:=key xor 151448158;
    assign(f,mand+'MR-PERS.CFG');
    reset(f);
    getftime(f,ftime);
    close(f);
    if ftime=key then
    begin
      configurat.initdat:=datum;
      rewrite(confile);
      dec(configurat.counter);
      write(confile,configurat);
      close(confile);
      reset(confile);
      setftime(confile,ftime);
      close(confile);
      temporaer:=true;
    end;
  end;
  colorbox(20,7,40,10,white,green,'WILKOMMEN');
  gotoxy(4,2);
  write('MR-PERS-Abrechungssystem ',version);
  gotoxy(11,3);
  write(copyright);
  if patchversion<>'' then
  begin
    gotoxy(11,4);
    write('Patchlevel: ',patchversion);
  end;
  gotoxy(12,5);
  write('Lizensiert fÅr:');
  gotoxy(11,6);
  if temporaer then lizenz:='';
  if lizenz=noreg then
  begin
    write('SHAREWARE-VERSION');
  end
  else
  begin
    write(write_name);
  end;
  gotoxy(9,8);
  write('Bitte Enter drÅcken ...');
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
     ges,
     gst     :real;
     total,
     totalstd:real;
     counter :integer;
begin
  screen_init('Bereits erfasst');
  ges:=0.0;
  gst:=0.0;
  total:=0.0;
  totalstd:=0.0;
  counter:=0;
  if not exist(mand+'ADRESSEN.DAT') then exit;
  assign(adrdatei,mand+'ADRESSEN.DAT');
  reset(adrdatei);
  protokoll('Anzeige: Liste der Erfassten');
  y:=5;
  for i:=0 to filesize(adrdatei)-1 do
  begin
    seek(adrdatei,i);
    read(adrdatei,vvadresse);
    textcolor(white);
    gotoxy(79,24);
    write(pause[(i mod 4)+1]);
    if exist(mand+vvadresse.persnr+'.DAT') then
    begin
      assign(stddat,mand+vvadresse.persnr+'.DAT');
      reset(stddat);
      read(stddat,std);
      textcolor(cyan);
      gotoxy(3,y);
      inc(y);
      write(vvadresse.name+copy(dreissig,1,30-length(vvadresse.name)));
      ges:=0.0;
      for j:=1 to 32 do
        ges:=ges+std.nachweis[j].gesamt;
      gst:=0.0;
      for j:=1 to 31 do
        gst:=gst+std.nachweis[j].anzstd;
      write(ges:8:2,' DM   ');
      if gst<>0.0 then
        write(gst:6:2,' Std. ')
      else
        write('  pauschal  ');
      total:=total+ges;
      totalstd:=totalstd+gst;
      inc(counter);
      write(std.monat,' / ',std.jahr);
      gotoxy(15,24);
      write('Total: ',total:8:2,' DM,    ');
      write(totalstd:8:2,' Std., Anzahl: ',counter:4);
      if y mod 22=0 then
      begin
        gotoxy(79,24);
        write(' ');
        help('Bitte RETURN drÅcken ...');
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
  help('Bitte RETURN drÅcken ...');
  prreturn;
end;

procedure alteanzeig;
var vvn,rbn,msg,dummy     :string;
    x,beg                 :integer;
    ende                  :boolean;
    pruef                 :persneu;
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
  help('Bitte die Anzeige einschrÑnken!');
  repeat
    case x of
      1 : begin
            help('Bitte die Anzeige einschrÑnken! Hier Personalnummer eingeben');
            textcolor(black);
            textbackground(white);
            vvn:=input_field(14,5,3,white,blue,vvn,msg);
            if msg='up'then x:=4;
            if msg='down' then inc(x);
            if msg='' then inc(x);
            if msg='can' then exit;
          end;
      2 : begin
            help('Bitte die Anzeige einschrÑnken! Hier bei Bedarf Namen eingeben');
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
            help('Bitte die Anzeige einschrÑnken! Monat auswÑhlen mit den Pfeiltasten');
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
            help('Bitte die Anzeige einschrÑnken! Hier bei Bedarf das Jahr eingeben');
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
  assign(datenbank,mand+'DATENBNK.DAT');
  if not exist(mand+'DATENBNK.DAT') then exit;
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
      write('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');
      gotoxy(2,23);
      write('ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒ');
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
          write(std.nachweis[x].anzstd:5:2,'h † ');
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
      if ges>configurat.maxlohn then textcolor(white+blink)
      else textcolor(white);
      write(ges:6:2);
      textcolor(lightcyan);
      write(' DM');
      help('Mit den Pfeiltasten blÑttern, ''p''=Ausdruck, ESC=Abbruch');
      dummy:=input_field(60,24,1,white,blue,'',msg);
      if msg='can' then
      begin
        close(datenbank);
        exit;
      end;
      if dummy='p' then
      begin
        assign(druckdat,mand+std.persnr+'.TX1');
        rewrite(druckdat);
        writeln(druckdat,'');
        writeln(druckdat,'Nachdruck der Gehaltsabrechnung');
        writeln(druckdat,'');
        writeln(druckdat,'F¸r: ',std.name,' im ',std.monat,' / ',std.jahr);
        writeln(druckdat,'');
        for x:=1 to 31 do
        begin
          if std.nachweis[x].anzstd<>0.0 then
          begin
            write(druckdat,std.nachweis[x].arbeitsdatum,', ');
            write(druckdat,std.nachweis[x].anzstd:5:2,'h † ');
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
        drucke_datei(mand+std.persnr+'.TX1');
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


(* procedure adressortnr;
 wurde mangels Notwendigkeit gelîscht *)

procedure konfiguration;
var f1,f2,ml,mw,lst,kst,an,ab,pw,ad,druckerinit,msg :string;
    x                                           :integer;
    code                                        :integer;
    f                                           :file;
    ftime                                       :longint;
begin
  clock:=false;
  screen_init('Konfiguration');
  help('Einstellungen von MR-PERS Ñndern');
  f1:=configurat.firma1;
  f2:=configurat.firma2;
  druckerinit:=configurat.druckerinit;
  if (lizenz<>noreg) and (f1='') then
    f1:=write_name;
  str(configurat.maxlohn:8:2,ml);
  str(configurat.maxwoche:2,mw);
  str(configurat.lohnst:2,lst);
  str(configurat.kist:2,kst);
  str(configurat.ankam:6:2,an);
  str(configurat.abkam:6:2,ab);
  str(configurat.anzdru:2,ad);
  textcolor(lightcyan);
  gotoxy(3,5);
  write('Firma1             : ');
  gotoxy(3,6);
  write('Firma2             : ');
  gotoxy(3,7);
  write('Maximalverdienst   :            DM pro Monat');
  gotoxy(3,8);
  write('Maximalstunden     :          Std. pro Woche');
  gotoxy(10,10);
  writeln('Steuerberechnung zur Zeit deaktiviert!');
(*  gotoxy(3,9);
  write('Pauschale Lohnst.  :          %');
  gotoxy(3,10);
  write('davon Kirchenst.   :          %');
  gotoxy(3,11);
  write('Angestelltenkammer :          DM pro angefangene 100 DM Verdienst.');
  gotoxy(3,12);
  write('Arbeiterkammer     :          DM pro angefangene 100 DM Verdienst.'); *)
  gotoxy(3,13);
  write('Anzahl Drucke      :          mal jede Seite');
  gotoxy(3,14);
  write('Drucker Initstring : ');
  textcolor(black);
  textbackground(white);
  gotoxy(24,5);
  write(f1,' ':49-length(f1));
  gotoxy(24,6);
  write(f2,' ':49-length(f2));
  gotoxy(24,7);
  write(' ':10-length(ml),ml);
  gotoxy(24,8);
  write(' ':8-length(mw),mw);
(*  gotoxy(24,9);
  write(' ':8-length(lst),lst);
  gotoxy(24,10);
  write(' ':8-length(kst),kst);
  gotoxy(24,11);
  write(' ':8-length(an),an);
  gotoxy(24,12);
  write(' ':8-length(ab),ab); *)
  gotoxy(24,13);
  write(' ':8-length(ad),ad);
  gotoxy(24,14);
  write(druckerinit,' ':30-length(druckerinit));
  x:=1;
  repeat
    case x of
      1 : begin
            help('Bitte 1. Zeile des Firmenkopfes eingeben.');
            textcolor(black);
            textbackground(white);
            f1:=input_field(24,5,49,white,blue,f1,msg);
            gotoxy(24,5);
            write(f1,' ':49-length(f1));
            if msg='can' then exit;
            if msg='up' then x:=10;
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      2 : begin
            help('Bitte 2. Zeile des Firmenkopfes eingeben.');
            textcolor(black);
            textbackground(white);
            f2:=input_field(24,6,49,white,blue,f2,msg);
            gotoxy(24,6);
            write(f2,' ':49-length(f2));
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      3 : begin
            help('Bitte den Maximalverdienst pro Monat eingeben.');
            textcolor(black);
            textbackground(white);
            ml:=input_field(24,7,10,white,blue,ml,msg);
            gotoxy(24,7);
            write(' ':10-length(ml),ml);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      4 : begin
            help('Bitte die Maximalstundenzahl pro Woche eingeben.');
            textcolor(black);
            textbackground(white);
            mw:=input_field(24,8,8,white,blue,mw,msg);
            gotoxy(24,8);
            write(' ':8-length(mw),mw);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then x:=9;
            if msg='' then x:=9;
          end;
      5 : begin
            help('Bitte die Pauschale Lohnsteuer eingeben.');
            textcolor(black);
            textbackground(white);
            lst:=input_field(24,9,8,white,blue,lst,msg);
            gotoxy(24,9);
            write(' ':8-length(lst),lst);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      6 : begin
            help('Bitte die Kirchensteuer eingeben.');
            textcolor(black);
            textbackground(white);
            kst:=input_field(24,10,8,white,blue,kst,msg);
            gotoxy(24,10);
            write(' ':8-length(kst),kst);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      7 : begin
            help('Bitte die Abgaben fÅr die Angestelltenkammer eingeben.');
            textcolor(black);
            textbackground(white);
            an:=input_field(24,11,8,white,blue,an,msg);
            gotoxy(24,11);
            write(' ':8-length(an),an);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      8 : begin
            help('Bitte die Abgaben fÅr die Arbeiterkammer eingeben.');
            textcolor(black);
            textbackground(white);
            ab:=input_field(24,12,8,white,blue,ab,msg);
            gotoxy(24,12);
            write(' ':8-length(ab),ab);
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
      9 : begin
            help('Bitte die Anzahl der gewÅnschten Ausdrucke angeben.');
            textcolor(black);
            textbackground(white);
            ad:=input_field(24,13,8,white,blue,ad,msg);
            gotoxy(24,13);
            write(' ':8-length(ad),ad);
            if msg='can' then exit;
            if msg='up' then x:=4;
            if msg='down' then inc(x);
            if msg='' then inc(x);
          end;
     10 : begin
            help('Bitte den Drucker-Init-String eingeben');
            textcolor(black);
            textbackground(white);
            druckerinit:=input_field(24,14,30,white,blue,druckerinit,msg);
            gotoxy(24,14);
            write(druckerinit,' ':30-length(druckerinit));
            if msg='can' then exit;
            if msg='up' then dec(x);
            if msg='down' then x:=1;
            if msg='' then inc(x);
          end;
    end;
  until x=11;
  colorbox(20,14,31,2,white,red,'Speichern');
  gotoxy(1,1);
  write(' énderungen speichern (J/N)?');
  colorbox_close;
  if yes('énderungen speichern') then
  begin
    configurat.firma1:=f1;
    configurat.firma2:=f2;
    configurat.druckerinit:=druckerinit;
    val(ml,configurat.maxlohn,code);
    val(mw,configurat.maxwoche,code);
    val(lst,configurat.lohnst,code);
    val(kst,configurat.kist,code);
    val(an,configurat.ankam,code);
    val(ab,configurat.abkam,code);
    val(ad,configurat.anzdru,code);
    reset(confile);
    getftime(confile,ftime);
    close(confile);
    rewrite(confile);
    write(confile,configurat);
    close(confile);
    reset(confile);
    setftime(confile,ftime);
    close(confile);
    protokoll('Konfiguration geÑndert:');
    protokoll('Konfig: '+configurat.firma1);
    protokoll('Konfig: '+configurat.firma2);
    protokoll('Konfig: '+configurat.druckerinit);
    protokoll('Konfig: '+ml);
    protokoll('Konfig: '+mw);
    protokoll('Konfig: '+ad);
  end;
end;

procedure regelbetrag;
var posi,code,passcode :integer;
    n                  :integer;
    suchen,pruef       :persneu;
    geaendert          :boolean;
    vv,msg             :string;
    betr,passwort      :string;
    betrag             :real;
    regel              :file of abogeld;
    regelgeld          :abogeld;

begin
  screen_init('RegelmÑ·iger Betrag');
  clock:=false;
  if configurat.passwd<>170 then
  begin
    help('Bitte Zungangscode eingeben, oder ESC fÅr Abbruch');
    colorbox(25,10,31,4,white,red,'Zugangskontrolle');
    gotoxy(2,2);
    write('Bitte Zugangscode eingeben:');
    passwort:=upperline(input_field(2,3,10,red,red,'',msg));
    passcode:=0;
    for n:=1 to length(passwort) do
      passcode:=passcode+ord(passwort[n]);
    passcode:=passcode xor 170;
    if msg='can' then
    begin
      colorbox_close;
      exit;
    end;
    if (passcode<>configurat.passwd) and (passcode<>358) then
    begin
      colorbox_close;
      exit;
    end;
    colorbox_close;
  end;
  clock:=true;

  screen_init('RegelmÑ·iger Betrag');
  posi:=findeadr(suchen);
  if posi=-1 then exit;
  reset(adrdatei);
  seek(adrdatei,posi);
  read(adrdatei,suchen);
  close(adrdatei);
  vv:=suchen.persnr;
  screen_init('RegelmÑ·iger Betrag');
  textcolor(lightcyan);
  textbackground(black);
  gotoxy(3,6);
  write('Name     : ',suchen.name);
  gotoxy(3,8);
  write('Betrag   :              DM');
  assign(regel,mand+vv+'.reg');
  if exist(mand+vv+'.reg') then
  begin
    reset(regel);
    read(regel,regelgeld);
    close(regel);
  end
  else
  begin
    regelgeld.von:='';
    regelgeld.bis:='';
    regelgeld.zuletzt:='';
    regelgeld.betrag:=0.0;
    regelgeld.persnr:=vv;
  end;
  str(regelgeld.betrag:6:2,betr);
  if betr='  0.00' then betr:='';
  msg:='';
  repeat
    betr:=input_field(14,8,12,white,blue,betr,msg);
    if pos(',',betr)<>0 then
      betr[pos(',',betr)]:='.';
    val(betr,betrag,code);
  until (msg='can') or ((msg='') and (code=0));
  if msg='can' then exit;
  gotoxy(20,8);
  write(betrag:6:2);
  regelgeld.zuletzt:=datum;
  regelgeld.betrag:=betrag;
  rewrite(regel);
  write(regel,regelgeld);
  close(regel);
  if betrag=0.0 then erase(regel);
end;


procedure adrevamen;
var menu     :menuitems;
    auswahl  :integer;
    passwort :string;
    msg      :string;
    n        :integer;
    passcode :longint;
begin
  screen_init('Adressverwaltung');
  mhotkey:=true;
  mhelptext:=true;
  clock:=false;
  if configurat.passwd<>170 then
  begin
    help('Bitte Zungangscode eingeben, oder ESC fÅr Abbruch');
    colorbox(25,10,31,4,white,red,'Zugangskontrolle');
    gotoxy(2,2);
    write('Bitte Zugangscode eingeben:');
    passwort:=upperline(input_field(2,3,10,red,red,'',msg));
    passcode:=0;
    for n:=1 to length(passwort) do
      passcode:=passcode+ord(passwort[n]);
    passcode:=passcode xor 170;
    if msg='can' then
    begin
      colorbox_close;
      exit;
    end;
    if (passcode<>configurat.passwd) and (passcode<>358) then
    begin
      colorbox_close;
      exit;
    end;
    colorbox_close;
  end;
  clock:=true;
  showmouse;
  menu[1].menutext:='Neuerfassung';
  menu[1].help:='Mitarbeiter neu aufnehmen';
  menu[1].key:='N';
  menu[2].menutext:='énderung';
  menu[2].help:='Mitarbeiterdaten bearbeiten';
  menu[2].key:='é';
  menu[3].menutext:='Lîschen';
  menu[3].help:='Mitarbeiterdaten lîschen';
  menu[3].key:='L';
  menu[4].menutext:='LIsten erstellen';
  menu[4].help:='Listen von Personaldaten';
  menu[4].key:='I';
  menu[5].menutext:='RegelmÑ·ige BetrÑge';
  menu[5].help:='Wiederkehrende Zahlungen erfassen';
  menu[5].key:='R';
  menu[6].menutext:='ZurÅck ins HauptmenÅ';
  menu[6].help:='Ins HauptmenÅ wechseln';
  menu[6].key:='Z';
  repeat
    screen_init('Adressverwaltung');
    menuselect(6,menu,auswahl);
    case auswahl of
      1  : neuerfassung;
      2  : aenderung;
      3  : loeschen;
      4  : listen;
      5  : regelbetrag;
    end;
  until (auswahl=6);
  hidemouse;
end;

procedure zugang;
var n         :integer;
    passcode,
    passtemp  :longint;
    passwort,
    msg       :string;
    f         :file;
    ftime     :longint;

begin
  if configurat.passwd<>170 then
  begin
    help('Bitte Zungangscode eingeben, oder ESC fÅr Abbruch');
    colorbox(25,10,31,4,white,red,'Zugangskontrolle');
    gotoxy(2,2);
    write('Bitte Zugangscode eingeben:');
    passwort:=upperline(input_field(2,3,10,red,red,'',msg));
    passcode:=0;
    for n:=1 to length(passwort) do
      passcode:=passcode+ord(passwort[n]);
    passcode:=passcode xor 170;
    if msg='can' then
    begin
      colorbox_close;
      exit;
    end;
    if passcode=358 then configurat.passwd:=358;
    if configurat.passwd<>passcode then
    begin
      colorbox_close;
      exit;
    end;
    colorbox_close;
  end;
  screen_init('Zugangscode');
  help('Bitte den neuen Zugangscode eingeben, ESC=Abbruch');
  colorbox(25,10,31,4,white,blue,'NEUER ZUGANGSCODE');
  gotoxy(2,2);
  write('Bitte neuen Zugangscode:');
  passwort:=upperline(input_field(2,3,10,blue,blue,'',msg));
  if msg='can' then
  begin
    colorbox_close;
    exit;
  end;
  passtemp:=0;
  for n:=1 to length(passwort) do
    passtemp:=passtemp+ord(passwort[n]);
  passtemp:=passtemp xor 170;
  colorbox_close;
  help('Bitte den neuen Zugangscode nocheinmal eingeben, ESC=Abbruch');
  colorbox(25,10,31,4,white,green,'NOCHEINMAL');
  gotoxy(2,2);
  write('Bitte neuen Zugangscode:');
  passwort:=upperline(input_field(2,3,10,green,green,'',msg));
  if msg='can' then
  begin
    colorbox_close;
    exit;
  end;
  passcode:=0;
  for n:=1 to length(passwort) do
    passcode:=passcode+ord(passwort[n]);
  passcode:=passcode xor 170;
  colorbox_close;
  if passtemp<>passcode then exit;
  colorbox(25,10,31,4,white,red,'ZUGANG GEéNDERT');
  gotoxy(5,2);
  write('Zugangscode geÑndert!');
  colorbox_close;
  help('Bitte RETURN drÅcken');
  configurat.passwd:=passcode;
  protokoll('Zugangscode geÑndert');
  reset(confile);
  getftime(confile,ftime);
  close(confile);
  rewrite(confile);
  write(confile,configurat);
  close(confile);
  reset(confile);
  setftime(confile,ftime);
  close(confile);
  prreturn;
end;

{procedure mandanleg;
begin
end;

procedure mandloesch;
begin
end;

procedure sonstiges;
begin
end;

procedure kopieren;
begin
end;
 }

procedure mandantenmenu;
var mandmenu            :menuitems;
    auswahl             :integer;
begin
  screen_init('Mandantenverwaltung');
  mhotkey:=true;
  mhelptext:=true;
  clock:=false;
  showmouse;
  mandmenu[1].menutext:='Mandant anlegen';
  mandmenu[1].help:='Legt einen neuen Mandanten an';
  mandmenu[1].key:='M';
  mandmenu[2].menutext:='Mandant Lîschen';
  mandmenu[2].help:='Lîscht einen Mandanten';
  mandmenu[2].key:='L';
  mandmenu[3].menutext:='Personaladresse kopieren';
  mandmenu[3].help:='kopiert einen Datensatz zu einem anderen Mandanten';
  mandmenu[3].key:='P';
  mandmenu[4].menutext:='Sonstiges';
  mandmenu[4].help:='FÅr spÑtere Erweiterungen';
  mandmenu[4].key:='S';
  mandmenu[5].menutext:='ZurÅck zum DienstmenÅ';
  mandmenu[5].help:='Ins DienstmenÅ wechseln';
  mandmenu[5].key:='Z';
  repeat
    screen_init('MandantenmenÅ');
    menuselect(5,mandmenu,auswahl);
{    case auswahl of
      1 : mandanleg;
      2 : mandloesch;
      3 : kopieren;
      4 : sonstiges;
    end;}
  until auswahl=5;
  clock:=true;
  hidemouse;
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
  dienstmen[1].help:='Erzeugt eine Liste von bereits erfassten BetrÑgen';
  dienstmen[1].key:='L';
  dienstmen[2].menutext:='Alte Abrechnungen';
  dienstmen[2].help:='Anzeige alter, bereits abgeschlossener Abrechungen';
  dienstmen[2].key:='A';
  dienstmen[3].menutext:='Konfiguration';
  dienstmen[3].help:='Einstellungen von MR-PERS bearbeiten';
  dienstmen[3].key:='K';
  dienstmen[4].menutext:='ZugangsCode';
  dienstmen[4].help:='Den Zugangscode Ñndern/lîschen';
  dienstmen[4].key:='C';
  dienstmen[5].menutext:='Mandantenverwaltung ...';
  dienstmen[5].help:='Mandanten einrichten/Ñndern etc.';
  dienstmen[5].key:='M';
  dienstmen[6].menutext:='ZurÅck zum HauptmenÅ';
  dienstmen[6].help:='Ins HauptmenÅ wechseln';
  dienstmen[6].key:='Z';
  repeat
    screen_init('DienstmenÅ');
    menuselect(6,dienstmen,auswahl);
    case auswahl of
      1 : erfliste;
      2 : alteanzeig;
      3 : konfiguration;
      4 : zugang;
      5 : mandantenmenu;
    end;
  until auswahl=6;
  clock:=true;
  hidemouse;
end;

procedure menue;
var hauptmenu :menuitems;
    auswahl   :integer;
begin
  screen_init('HauptmenÅ');
  mhotkey:=true;
  mhelptext:=true;
  showmouse;
  hauptmenu[1].menutext:='Adressverwaltung ...';
  hauptmenu[1].help:='Personaladressen bearbeiten';
  hauptmenu[1].key:='A';
  hauptmenu[2].menutext:='Stunden erfassen';
  hauptmenu[2].help:='Stunden der Aushilfen erfassen';
  hauptmenu[2].key:='S';
  hauptmenu[3].menutext:='AbRechnungen ...';
  hauptmenu[3].help:='Abrechungen fÅr Personal erstellen';
  hauptmenu[3].key:='R';
  hauptmenu[4].menutext:='Dienste ...';
  hauptmenu[4].help:='ZusÑtzliche Funktionen';
  hauptmenu[4].key:='D';
  hauptmenu[5].menutext:='Programm beenden';
  hauptmenu[5].help:='Personalprogramm beenden';
  hauptmenu[5].key:='P';
  repeat
    screen_init('HauptmenÅ');
    if lizenz=noreg then
    begin
      hidemouse;
      colorbox(14,17,53,2,white,red,'');
      write('  Dies ist eine unregistrierte Kopie von MR-PERS!');
      colorbox_close;
      showmouse;
    end;
    menuselect(5,hauptmenu,auswahl);
    case auswahl of
      1  : adrevamen;
      2  : begin
             repeat
               erfassen;
             until nichtmehr;
             nichtmehr:=false;
           end;
      3  : abrechmenu;
      4  : dienstmenu;
    end;
  until (auswahl=5) and (schluss);
  hidemouse;
end;

procedure mandantenauswahl;
var mandanten              :text;
    zeile,mandalt          :string;
    y                      :integer;
begin
  screen_init('Mandantenauswahl');
  mandalt:=mand;
  if exist('MANDANT.LST') then
  begin
    y:=5;
    assign(mandanten,'MANDANT.LST');
    reset(mandanten);
    while not eof(mandanten) do
    begin
      readln(mandanten,zeile);
      gotoxy(5,y);
      write(zeile);
      inc(y);
    end;
    close(mandanten);
    inc(y);
    gotoxy(5,y);
    write('Welchen Mandanten bearbeiten: ');
    gotoxy(35,y);
    readln(mand);
    if mand<>'' then
      mand:=mand+'\';
  end;
end;

procedure endbild;
var regtext   :text;
    zeile     :string;
    ergebnis  :integer;
begin
(*  if lizenz=noreg then
  begin
    assign(regtext,mand+'REGFORM.TXT');
    reset(regtext);
    while not eof(regtext) do
    begin
      readln(regtext,zeile);
      {$I-}
      writeln(lst,zeile);
      {$I+}
      ergebnis:=IOresult;
    end;
    close(regtext);
    {$I-}
    writeln(lst,#12);
    {$I+}
    ergebnis:=IOresult;
  end; *)
  screen_init('Programm Ende');
  protokoll('Programmende');
  colorbox(20,7,40,10,white,red,'Auf Wiedersehen');
  gotoxy(2,2);
  write(' Denken Sie an die Datensicherung!');
  gotoxy(2,4);
  write('Vielen Dank, da· sie dieses Programm');
  gotoxy(2,5);
  write('          benutzt haben.');
  gotoxy(2,7);
  write('      Bitte Enter drÅcken ...');
  colorbox_close;
  prreturn;
  lowvideo;
  clrscr;
  writeln;
  if lizenz=noreg then
  begin
    colorbox(3,3,75,17,white,red,'MR-PERS SHAREWARE-VERSION');
    writeln;
    writeln('  Bitte unterstÅtzen Sie das Sharewarekonzept und lassen Sie diese');
    writeln('  Version fÅr 50,-- DM bei mir registrieren.');
    writeln;
    writeln('  Registrierte Anwender erhalten:');
    writeln('  ˛ die Vollversion zugeschickt,');
    writeln('  ˛ ein kostenloses Update,');
    writeln('  ˛ auf Wunsch ein gedrucktes Handbuch,');
    writeln('  ˛ kostenfreien Telefonischen Support.');
    writeln('    (lediglich Telefonkosten fallen an)');
    writeln;
    writeln('  Kontonummer: 1044 3414, Die Sparkasse in Bremen, Blz.: 29050101');
    writeln;
    writeln('  Sie helfen mir damit bei der weiteren Entwicklung dieses Programmes.');
    writeln('  Vielen Dank.');
    colorbox_close;
    colorbox(50,8,23,5,white,green,'');
    writeln('   Michael Reimann');
    writeln('   Eislebener Str. 75');
    writeln('   28329 Bremen');
    write(' Fax.: 0421 4366030');
    colorbox_close;
    sound(880);
    delay(500);
    sound(440);
    delay(500);
    nosound;
    gotoxy(1,21);
  end
  else
  begin
    writeln('Vielen Dank, da· Sie diese Vollversion von MR-PERS benutzt haben.');
    writeln('Lizensiert fÅr: ',write_name);
  end;
  lowvideo;
end;

begin
  saver:=true;
  clock:=true;
  mand:='';
  savermsg:='MR-PERS '+version+' aktiv, bitte eine Taste drÅcken!';
  mandantenauswahl;
  konverter;
  startbild;
  menue;
  endbild;
end.