{$A+,B-,D-,E-,F-,I-,L-,N-,O-,R-,S-,V-}
{$M 2048,0,6000}

UNIT selfkabu;

INTERFACE

uses crt,dos,turbo3,deskunit;

IMPLEMENTATION

TYPE  tbuf = ARRAY [1..4096] OF BYTE;
VAR   crc: WORD;
      buf: ^tbuf;
      f:   file;

{$F+}
PROCEDURE makecrc (xx: WORD); EXTERNAL;
  {$L crc.obj}
{$F-}

procedure warnung;
begin
  clrscr;
  colorbox(5,7,69,5,white,red,'MR-PERS MODIFIZIERT');
  writeln;
  writeln('MR-PERS wurde absichtlich modifiziert. Da dies eine unzulÑssige');
  writeln('Aktion ist, wird das Programm abgebrochen. Verwenden Sie eine');
  writeln('nicht modifizierte Version, oder lassen Sie das Programm regis-');
  write('trieren.                       (c)1993 M.Reimann, EDV-Beratung');
  colorbox_close;
  writeln;
end;

PROCEDURE patchtest;
  VAR s, s1:        ARRAY [1..5] OF CHAR;
      x, comp:      STRING [7];
      soll, ist, n: WORD;
      patchadr:     LONGINT;

  PROCEDURE error (n: BYTE);
    BEGIN
      CASE n OF
        1: WRITE ('Programm Read-Only !, ');
        2: WRITE ('Da stimmt was nicht !.......', #8#8#8#8#8#8#8,', ');
        3: warnung;
        4: WRITE ('nanu, patch not found ???, ');
        5: WRITE ('Selbstkonfiguration abgeschlossen, ')
        ELSE WRITE ('Unbekannter Fehler, nanu ???, ')
      END;
      WRITELN ('AusfÅhrung abgebrochen.');
      CLOSE (f);
      HALT (128)
    END;

  FUNCTION checksum: WORD;
    VAR n: WORD;
    BEGIN
      NEW (buf); SEEK (f, 0); crc:= 8;
      REPEAT BLOCKREAD (f, buf^, 4096, n); makecrc (n) UNTIL (n <> 4096);
      checksum:= crc
    END;

  PROCEDURE configure;
    VAR  r:    INTEGER;
         s1:   ARRAY [1..7] OF CHAR;
         s2:   ARRAY [1..11] OF CHAR;
         n, m: LONGINT;
         x:    STRING;
    BEGIN
      n:= 0; REPEAT INC (n); SEEK (f, n); BLOCKREAD (f, s1, 7, r)
      UNTIL ((s1 = comp) OR (n > FILESIZE (f) - 7));
      IF (n > FILESIZE (f) - 7) THEN error (4);
      m:= 0; REPEAT INC (m); SEEK (f, m); BLOCKREAD (f, s2, 11, r)
      UNTIL ((s2 = 'was nicht !') OR (m > FILESIZE (f) - 11));
      IF (m > FILESIZE (f) - 11) THEN error (4);
      m:= m + 11; STR (m:7, x); FOR r:= 1 TO 7 DO s1 [r]:= x [r];
      SEEK (f, n); BLOCKWRITE (f, s1, 7, r);
      ist:= checksum; STR (ist:5, x); FOR r:= 1 TO 5 DO s1 [r]:= x [r];
      SEEK (f, m); BLOCKWRITE (f, s1, 5, r);
      error (5)
    END;

  BEGIN
    RESET (f, 1); IF (IORESULT <> 0) THEN error (1);
    comp:= UPCASE ('c') + 'defgah'; x:= 'Cdefgah';
    IF (x = comp) THEN configure;
    VAL (x, patchadr, n); IF (n <> 0) THEN error (2);
    SEEK (f, patchadr); BLOCKREAD (f, s, 5, n);
    s1:= '.....';
    SEEK (f, patchadr); BLOCKWRITE (f, s1, 5, n);
    ist:= CHECKSUM;
    SEEK (f, patchadr); BLOCKWRITE (f, s, 5, n);
    VAL (s, soll, n); IF (n <> 0) THEN error (2);
    If (soll <> ist) THEN error (3);
    CLOSE (f)
  END;

BEGIN ASSIGN (f, paramstr (0)); patchtest END.
