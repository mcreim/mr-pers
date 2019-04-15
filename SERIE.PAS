program insert_snumber;

uses dos,crt,turbo3;

var name       :string;
    nummer     :array[1..20] of char;
    i,j,erg,z,k:integer;
    fi,fo      :file;
    log        :text;
    nr,nw      :word;
    buf        :array[1..4096] of char;
    zeile,num  :string;


begin
  assign(log,'serie.log');
  {$I-}
  append(log);
  {$I+}
  if Ioresult<>0 then rewrite(log);
  num:='';
  clrscr;
  writeln('Seriennummer in MR-PERS.EXE einfÅgen, (c)1991-93 by M.Reimann');
  writeln('Nur fÅr internen Gebrauch!');
  writeln;
  write('Bitte des Namen des Inhabers eingeben (max. 20 Stellen): ____________________');
  gotoxy(58,4);
  readln(name);
  writeln(log,'Benutzername: ',name);
  name:=copy(name+'!"$%&/()=?#!"$%&/()=?#',1,20);
  for i:=1 to 20 do
    nummer[i]:=chr(ord(name[i]) xor 127);
  erg:=0;
  write('Persînliche Seriennummer: ');
  for i:=1 to 10 do
    erg:=erg+ord(nummer[i]);
  write(erg);
  str(erg,zeile);
  erg:=0;
  for i:=20 downto 11 do
    erg:=erg+ord(nummer[i]);
  writeln(erg);
  str(erg,num);
  num:=zeile+num;
  writeln(log,'Serienummer : ',num);
  writeln(log,'---------------------------------');
  close(log);
  assign(fi,'MR-PERS.EX_');
  reset(fi,1);
  assign(fo,'MR-PERS.$$$');
  rewrite(fo,1);
  writeln('FÅge nun die Seriennummer ein.');
  repeat
    blockread(fi,buf,sizeof(buf),nr);
    write('.');
    for i:=1 to nr-20 do
    begin
      zeile:='';
      for j:=i to i+4 do
        zeile:=zeile+buf[j];
      if zeile='ÄÅÇÉÑ' then
      begin
        write(' Dummy gefunden, fÅge nun ein. ');
        zeile:='';
        inc(j,2);
        z:=1;
        for k:=j to j+19 do
        begin
          buf[k]:=nummer[z];
          inc(z);
        end;
      end;
    end;
    blockwrite(fo,buf,nr,nw);
  until (nr=0) or (nw<>nr);
  writeln;
  writeln('Seriennummer eingefÅgt');
  close(fi);
  close(fo);
end.