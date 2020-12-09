
{                                                                      }
{      MX library                                (C) MAXsoft 1993      }
{                                                                      }

unit MXtime;

{$A-,B-,F-,I-,O+,P+,T-,V-,X+}
{$G-}
{$E-,N-}
{$Q-,R-,S-}
{$D-,L-,Y-}

interface

uses
     MXroot, MXchar;

type
     pTime = ^Time; Time = object
      constructor Init;
      constructor InitBin( lt: long );
      constructor InitValue( h, m, s, t: int );
      function    Valid  : bool;
      function    GetBin : long;
      procedure   PutBin( lt: long );
      function    GetHMS( var h, m, s, t: int ): bool;
      function    PutHMS( h, m, s, t: int ): bool;
      function    GetHour: int;
      function    GetMin : int;
      function    GetSec : int;
      function    GetHSec: int;
      function    GetText: string;
     private _value: long;
     end;

const
     TimeMaxValue  = 8640000; { real time value must be LessThan }
     TimeSeparator = ':';

const
     _NHour = 360000;
     _NMin  =   6000;
     _NSec  =    100;

type
     pDate = ^Date; Date = object
      constructor Init;
      constructor InitBin( ld: long );
      constructor InitValue( d, m, y: int );
      function    Valid    : bool;
      function    GetBin   : long;
      procedure   PutBin( l: long );
      function    GetDMY( var d, m, y: int ): bool;
      function    PutDMY( d, m, y: int ): bool;
      function    GetDay   : int;
      function    GetMonth : int;
      function    GetYear  : int;
      function    GetText  : string;
      function    WeekDay  : int;
     private _value: long;
     end;

const
     DateMinValue  =   36160;
     DateMaxValue  = 3652059;
     DateMinYear   =     100;
     DateMaxYear   =    9999;
     DateSeparator = '.';

type
     pDateTime = ^DateTime; DateTime = object
      constructor Init;
      constructor InitBin( dt, tm: long );
      function    Valid: bool;
      procedure   GetBin ( var dt, tm: long );
      procedure   PutBin ( dt, tm: long );
      procedure   GetDate( var dt: Date );
      procedure   GetTime( var tm: Time );
      procedure   PutDate( var dt: Date );
      procedure   PutTime( var tm: Time );
      procedure   Change ( da, hr, mn, sc, hs: long );
      function    Compare( var dt: DateTime ): int; { LT, EQ, GT }
      function    GetText: string;
     private _tm: Time; _dt: Date;
     end;

implementation

constructor Time.Init;
begin {!} {call inherited} _value := 0;
end{ Time.Init };

constructor Time.InitBin( lt: long );
begin {!} {call inherited} PutBin( lt );
end{ Time.InitBin };

constructor Time.InitValue( h, m, s, t: int );
begin {!} {call inherited} PutHMS( h, m, s, t );
end{ Time.InitValue };

function Time.Valid: bool;
begin Valid := (_value >= 0) and (_value < TimeMaxValue);
end{ Time.Valid };

function Time.GetBin: long;
begin GetBin := _value;
end{ Time.GetBin };

procedure Time.PutBin( lt: long );
begin _value := lt; if not Valid then _value := 0;
end{ Time.PutBin };

function Time.GetHMS( var h, m, s, t: int ): bool; var l: long;
begin
 if Valid then begin GetHMS := True; l := _value;
  h := l div _NHour; l := l mod _NHour;
  m := l div _NMin ; l := l mod _NMin ;
  s := l div _NSec ; l := l mod _NSec ; t := l; end
 else GetHMS := False;
end{ Time.Get };

function Time.PutHMS( h, m, s, t: int ): bool;
begin
 if (h >= 0) and (h <= 23) and (m >= 0) and (m <= 59) and
    (s >= 0) and (s <= 59) and (t >= 0) and (t <= 99) then begin
  _value := long(h)*_NHour+long(m)*_NMin+s*_NSec+t; PutHMS := True; end
 else PutHMS := False;
end{ Time.Put };

function Time.GetHour: int;
begin GetHour := _value div _NHour;
end{ Time.GetHour };

function Time.GetMin: int;
begin
 GetMin := (_value mod _NHour) div _NMin;
end{ Time.GetMin };

function Time.GetSec: int;
begin GetSec := (_value mod _NMin) div _NSec;
end{ Time.GetSec };

function Time.GetHSec: int;
begin GetHSec := _value mod _NSec;
end{ Time.GetHSec };

function Time.GetText: string; var h, m, s, t: int;
begin h := 0; m := 0; s := 0; t := 0; GetHMS( h, m, s, t );
 GetText := PadLeft( Int2Str( h ), '0', 2 ) +TimeSeparator+
            PadLeft( Int2Str( m ), '0', 2 ) +TimeSeparator+
            PadLeft( Int2Str( s ), '0', 2 ) +'.'+
            PadLeft( Int2Str( t ), '0', 2 );
 { check environment for time format } {*}
end{ Time.GetText };


const
     _DayNum1   = 365;
     _DayNum4   = 366+365+365+365;
     _DayNum100 = _DayNum4*25 - 1;
     _DayNum400 = _DayNum100*4+ 1;

const
     _MonthLen: array [1..12] of byte =
      ( 31, 28, 31,  30, 31, 30,  31, 31, 30,  31, 30, 31 );
     _MonthSum: array [1..12] of int  =
      ( 0, 31, 31+28, 31+28+31, 31+28+31+30, 31+28+31+30+31,
        31+28+31+30+31+30, 31+28+31+30+31+30+31, 31+28+31+30+31+30+31+31,
        31+28+31+30+31+30+31+31+30, 31+28+31+30+31+30+31+31+30+31,
        31+28+31+30+31+30+31+31+30+31+30 );

function isLeap( y: word ): bool;
begin isLeap := False;
 if (y and 3) <> 0 then begin isLeap := False; exit; end
 else isLeap := ((y mod 100) <> 0) or ((y mod 400) = 0);
end{ isLeap };

constructor Date.Init;
begin {!} {call inherited} _value := 0;
end{ Date.Init };

constructor Date.InitBin( ld: long );
begin {!} {call inherited} PutBin( ld );
end{ Date.InitBin };

constructor Date.InitValue( d, m, y: int );
begin {!} {call inherited} PutDMY( d, m, y );
end{ Date.InitValue };

function Date.Valid: bool;
begin Valid := (_value >= DateMinValue) and (_value <= DateMaxValue);
end{ Date.Valid };

function Date.GetBin: long;
begin GetBin := _value;
end{ Date.GetLong };

procedure Date.PutBin( l: long );
begin _value := l; if not Valid then _value := 0;
end{ Date.PutBin };

function Date.GetDMY( var d, m, y: int ): bool;
var i, j, k, l: int; lv: long; ms: array [1..12] of int;
begin
 if not Valid then GetDMY := False
 else begin GetDMY := True; lv := _value; l := 0;
  i :=    (lv div _DayNum400) * 400  ; lv := lv mod _DayNum400;
  if lv = 0 then l := 1
  else begin
   Inc( i, (lv div _DayNum100) * 100 ); lv := lv mod _DayNum100;
   if lv = 0 then l := 0
   else begin
    Inc( i, (lv div _DayNum4  ) * 4   ); lv := lv mod _DayNum4  ;
    l := 1;
   end;
  end;
  if lv = 0 then lv := _DayNum1 + l
  else begin Inc( i );
   if lv > _DayNum1 then begin
    Inc( i ); Dec( lv, _DayNum1 );
    if lv > _DayNum1 then begin
     Inc( i ); Dec( lv, _DayNum1 );
     if lv > _DayNum1 then begin
      Inc( i ); Dec( lv, _DayNum1 );
     end;
    end;
   end;
  end;
  y := i;
  for j := 1 to 12 do ms[j] := _MonthLen[j];
  if isLeap( i ) then Inc( ms[2] );
  i := word( lv );
  j := 1;
  while j <= 12 do begin
   if i <= ms[j] then break; Dec( i, ms[j] ); Inc( j ); end;
  d := i; m := j;
 end;
end{ Date.GetDMY };

function Date.PutDMY( d, m, y: int ): bool; var ml, _2m: int; ly: long;
begin _value := 0; PutDMY := False;
 if (y >= 0) and (y < 100) then Inc( y, 1900 );
 if (y < DateMinYear) or (y > DateMaxYear) or (m < 1) or (m > 12) then exit;
 ml := _MonthLen[m]; _2m := 0;
 if isLeap( y ) then begin
  if m = 2 then Inc( ml ); if m > 2 then _2m := 1; end;
 if (d < 1) or (d > ml) then exit; ly := y-1;
 Inc( _value, (ly div 400) * _DayNum400 ); ly := ly mod 400;
 Inc( _value, (ly div 100) * _DayNum100 ); ly := ly mod 100;
 Inc( _value, (ly div 4  ) * _DayNum4   ); ly := ly mod 4;
 Inc( _value,  ly          * _DayNum1   );
 Inc( _value, _MonthSum[m] + d + _2m ); PutDMY := True;
end{ Date.PutDMY };

function Date.GetDay: int; var d, m, y: int;
begin d := 0; GetDMY( d, m, y ); GetDay := d;
end{ Date.GetDay };

function Date.GetMonth: int; var d, m, y: int;
begin m := 0; GetDMY( d, m, y ); GetMonth := m;
end{ Date.GetMonth };

function Date.GetYear: int; var d, m, y: int;
begin y := 0; GetDMY( d, m, y ); GetYear := y;
end{ Date.GetYear };

function Date.GetText: string; var d, m, y: int;
begin d := 0; m := 0; y := 0; GetDMY( d, m, y );
 GetText := PadLeft( Int2Str( d ), '0', 2 ) +DateSeparator+
            PadLeft( Int2Str( m ), '0', 2 ) +DateSeparator+
            PadLeft( Int2Str( y ), '0', 4 );
 { check environment for date format } {*}
end{ Date.GetText };

function Date.WeekDay: int;
begin WeekDay := _value mod 7;
end{ Date.WeekDay };

constructor DateTime.Init;
begin {*}{ inherited Init } _dt.Init; _tm.Init;
end{ DateTime.Init };

constructor DateTime.InitBin( dt, tm: long );
begin {*}{ inherited Init } _dt.InitBin( dt ); _tm.InitBin( tm );
end{ DateTime.InitBin };

function DateTime.Valid: bool;
begin Valid := _dt.Valid and _tm.Valid;
end{ DateTime.Valid };

procedure DateTime.GetBin( var dt, tm: long );
begin dt := _dt.GetBin; tm := _tm.GetBin;
end{ DateTime.GetBin };

procedure DateTime.PutBin( dt, tm: long );
begin _dt.PutBin( dt ); _tm.PutBin( tm );
end{ DateTime.PutBin };

procedure DateTime.GetDate( var dt: Date );
begin dt := _dt;
end{ DateTime.GetDate };

procedure DateTime.GetTime( var tm: Time );
begin tm := _tm;
end{ DateTime.GetTime };

procedure DateTime.PutDate( var dt: Date );
begin _dt := dt;
end{ DateTime.PutDate };

procedure DateTime.PutTime( var tm: Time );
begin _tm := tm;
end{ DateTime.PutTime };

procedure DateTime.Change( da, hr, mn, sc, hs: long ); var l: long;
begin
 l := ((((hr * 60) + mn) * 60) + sc) * 100 + hs;
 _dt.PutBin( _dt.GetBin + da + (l div TimeMaxValue) );
 _tm.PutBin( _tm.GetBin + (l mod TimeMaxValue) );
end{ DateTime.Change };

function DateTime.Compare( var dt: DateTime ): int;
begin
 if      _dt.GetBin > dt._dt.GetBin then Compare :=  1
 else if _dt.GetBin < dt._dt.GetBin then Compare := -1
 else if _tm.GetBin > dt._tm.GetBin then Compare :=  1
 else if _tm.GetBin < dt._tm.GetBin then Compare := -1
 else                                    Compare :=  0;
end{ DateTime.Compare };

function DateTime.GetText: string;
begin GetText := _tm.GetText + #32 + _dt.GetText;
end{ DateTime.GetText };


end{ MXtime }.
