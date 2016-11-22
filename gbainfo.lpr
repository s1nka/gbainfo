program gbainfo;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, CustApp, md5;

const VERSION = '0.0.1';
      AUTHOR  = 's1nka';

const Companies : Array [0..91,0..1] of string = (
('3031','Nintendo (1)'),
('3038','Capcom'),
('3041','Jaleco'),
('3041','Coconuts'),
('3048','Star Fish'),
('3138','Hudson Soft'),
('3230','Destination Software'),
('3238','Kemco (Japan)'),
('324C','TAM'),
('324D','Gu / Gajin'),
('3333','Nintendo (2)'),
('3431','UBI Soft'),
('3436','70'),
('3437','Spectrum Holobyte'),
('345A','Crave Entertainment'),
('3530','Absolute Entertainment'),
('3531','Acclaim'),
('3532','Activision'),
('3532','American Sammy'),
('3534','Take-Two Interactive'),
('3535','Park Place'),
('3536','LJN'),
('3541','Bitmap Brothers / Mindscape'),
('3544','Midway'),
('3547','Majesco Sales'),
('355A','Conspiracy Entertainment'),
('3548','3DO'),
('354D','Telegames'),
('3551','LEGO Software'),
('3630','Titus'),
('3631','Virgin'),
('3637','Ocean'),
('3646','ElectroBrain'),
('364C','BAM!'),
('3657','SEGA (US)'),
('3730','Infogrames'),
('3732','Broderbund (1)'),
('3738','THQ'),
('3739','Accolade'),
('3741','Triffix Entertainment'),
('3744','Universal Interactive Studios'),
('3746','Kemco (US)'),
('3747','Denki'),
('3833','Lozc'),
('3843','Bullet-Proof Software'),
('3843','Vic Tokai'),
('3850','SEGA (Japan)'),
('3933','Tsuburava'),
('3939','ARC'),
('3943','Imagineer'),
('394E','Marvelous Entertainment'),
('4134','Konami (1)'),
('4136','Kawada'),
('4137','Takara'),
('4139','Technos Japan'),
('4141','Broderbund (2)'),
('4142','Namco (1)'),
('4146','Namco (2)'),
('4147','Media Rings'),
('4231','ASCII / Nexoft'),
('4234','Enix'),
('4236','HAL'),
('4242','Sunsoft'),
('4244','Imagesoft'),
('4246','Sammy'),
('424C','MTO'),
('4250','Global A'),
('4330','Taito'),
('4332','Kemco (?)'),
('4333','SquareSoft'),
('4335','Data East'),
('4336','Tonkin House'),
('4338','KOEI'),
('4341','Palcom / Ultra'),
('4342','VAP'),
('4345','FCI / Pony Canyon'),
('4431','Sofel'),
('4432','Quest'),
('4439','Banpresto'),
('4441','Tomy'),
('4444','NCS'),
('4446','Altron'),
('4531','Towachiki'),
('4535','Epoch'),
('4537','Athena'),
('4538','Asmik (1)'),
('4541','King Records'),
('4542','Atlus'),
('4545','IGS'),
('454C','Spike'),
('454D','Konami (2)'),
('4558','Asmik (2)'));

procedure PrintVer;
begin
  WriteLn('gbainfo ver ['+VERSION+'] by ['+AUTHOR+']');
end;

procedure PrintHelp;
begin
  WriteLn('usage:');
  WriteLn(' gbainfo <rom file>');
end;

function BinToStr(const bin: array of byte) : string;
const HexSymbols = '0123456789ABCDEF';
var i: integer;
begin
  SetLength(Result, 2*Length(bin));
  for i :=  0 to Length(bin)-1 do begin
    Result[1 + 2*i + 0] := HexSymbols[1 + bin[i] shr 4];
    Result[1 + 2*i + 1] := HexSymbols[1 + bin[i] and $0F];
  end;
end;

function GetCompanyNameByID(const ID:string): string;
var i : Integer;
begin
  Result := 'Unknown company';
  for i := 0 to 91 do
    if Companies[i,0]=ID then Result := Companies[i,1];
end;

function CheckBIOSFile(const Str : String) : Boolean;
begin
  Result :=  MD5Print(MD5String(Str))='8f12a4c24d5e55f72f522bbcdf418e93';
end;

procedure PrintHeader(FileName : string);
var Data          : Array [0..$BF] of Byte;
    ROMFile       : File;
    i             : Integer;
    foo           : String;
begin
  AssignFile(ROMFile,FileName);
  Reset(ROMFile,1);
  Data[0] := 0; //hide hint message
  FillByte(Data,SizeOf(Data),0);
  try
    BlockRead(ROMFile,Data,SizeOf(Data));
  finally
    CloseFile(ROMFile);
  end;

  // 0x00 - 0x03	Start Code
  WriteLn('start code:       '+BinToStr(Data[$0..$3]));

  // 0x04 - 0x9F	Nintendo Logo Data
  if CheckBIOSFile(BinToStr(Data[$4..$9f])) Then
    WriteLn('logo:             correct')
  else
    WriteLn('logo:             not correct');
  // 0xA0 - 0xAB	Game Title
  foo := '';
  for i := $A0 to $AB do
  begin
    foo := foo + Char(Data[i]);
  end;
  //WriteLn('title: '+BinToStr(Data[$A0..$AB]));
  WriteLn('title:            '+foo);
  // 0xAC - 0xAF	Game Code
  foo := '';
  for i := $AC to $AF do
  begin
    foo := foo + Char(Data[i]);
  end;
  //WriteLn('game code: '+BinToStr(Data[$AC..$AF]));
  WriteLn('game code:        '+foo);
  // 0xB0 - 0xB1	Company ID
  foo := '';
  for i := $B0 to $B1 do
  begin
    foo := foo + Char(Data[i]);
  end;
  WriteLn('company:          '+BinToStr(Data[$B0..$B1])+' ['+GetCompanyNameByID(BinToStr(Data[$B0..$B1]))+']');
  // 0xB2 - 0xB2	0x96 Fixed
  // 0xB3 - 0xB3	Main Unit Code
  WriteLn('main unit code:   '+BinToStr(Data[$B3..$B3]));
  // 0xB4 - 0xB4	Device Type
  WriteLn('device type:      '+BinToStr(Data[$B4..$B4]));
  // 0xB5 - 0xBB	Reserved Area
  // 0xBC - 0xBC	Mask ROM Version
  WriteLn('mask rom version: '+BinToStr(Data[$BC..$BC]));
  // 0xBD - 0xBD	Compliment Check
  WriteLn('compliment check: '+BinToStr(Data[$BD..$BD]));
  // 0xBE - 0xBF	Checksum
  WriteLn('checksum:         '+BinToStr(Data[$BE..$BF]));
end;

begin
  PrintVer;
  if Paramcount < 1 then
  begin
    PrintHelp;
    Exit;
  end;
  if not FileExists(ParamStr(1)) then
  begin
    WriteLn('File [' + ParamStr(1) + '] not found');
    Exit;
  end;
  WriteLn('Processed file [' + ExtractFileName(ParamStr(1)) + ']');
  PrintHeader(ParamStr(1));
end.
