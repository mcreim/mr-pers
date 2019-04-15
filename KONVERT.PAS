program kassierer_abrechnung_konverter;

uses crt,dos,turbo3,dbase,drivers,deskunit,printer{,selfkabu};

const copyright='(c)1993-97 M.Reimann';
      version='~V1.21á~';
      patchversion='';
      noreg = '€½‘ ‚ƒ©œˆ(× œŸ  ~€';
      dummy  : string[5] = ('€‚ƒ„');
      lizenz : string[20] = ('€½‘ ‚ƒ©œˆ(× œŸ  ~€');
      dreissig='                              ';
      pause   : string[4] = ('|/-\');
      monatek : array [1..12] of string[3] = ('JAN','FEB','MR','APR','MAI',
                                              'JUN','JUL','AUG','SEP','OKT',
                                              'NOV','DEZ');
      monatel : array [1..12] of string[10] = ('Januar','Februar','M„rz',
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


var adrdatei_alt:file of persadr;
    adrdatei_neu:file of persneu;
    datenbank   :file of stunden;
    confile     :file of config;
    configurat  :config;
    db          :stunden;
    vvadresse   :persadr;
    vvadresseneu:persneu;
    i,j         :integer;
    zeile       :string;
    kopftext    :string;
    printererr  :boolean;
    temporaer   :boolean;
    nichtmehr   :boolean;
    umlaute     :string;
    mand        :string; (* Der Mandant auf dem gearbeitet wird *)


begin
  assign(adrdatei_alt,'ADRESS.DAT');
  assign(adrdatei_neu,'ADRESSEN.DAT');
  reset(adrdatei_alt);
  rewrite(adrdatei_neu);
  clrscr;
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
    writeln(vvadresseneu.name);
  end;
  close(adrdatei_alt);
  close(adrdatei_neu);
end.