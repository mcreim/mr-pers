unit adressv;

interface

uses deskunit,crt,dos,turbo3,drivers,printer;

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


procedure konverter;

implementation

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

begin
end.
