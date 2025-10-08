unit SharedFunctions;

interface

uses windows, SysUtils, Classes, Forms, DateUtils, Math, System.RegularExpressions,
     inifiles, StrUtils, cxGridDBTableView, MemDS;

const
CKEY1 = 53761;
CKEY2 = 32618;

procedure SetCustomFormatSettings;

function IsFormOpen(const FormName : string): Boolean;
function IsMDIChildOpen(const AFormName: TForm; const AMDIChildName : string): Boolean;

function FindFile2(FileName :string) : boolean;
function DeleteLocalFile(NamaFile : string) : boolean;
function ReportFileTimes(const FileName: string; atribut : integer): string;

function DeleteSpasi(Str: string): string;
function GantiKutip(Str: string): string;
function AddSpasi(Str: string; awal, jml : integer): string;
function CariCharInStr(Str, cari : string): boolean;

function BersihkanString(const Input: string): string;
function FormatTanggalIndonesia(myDate: TDate): string;

function myReplaceChar(tulisan : string; asli,ganti : char) : string;
function myReplaceDoubleQuote(tulisan : string) : string;
function myReplaceChar_String(Dest, Str: string; SubStr : char): string;

function FileSizeByName(const FileName: string): Int64;
function IsFileEksis(namaFolder, namaFile : string) : boolean;

// mengganti karakter en dash (–) dengan tanda hubung (-):
function ReplaceEnDashWithHyphen(InputString : string) : string;

function HapusEnter(sumber: string): string;
function KapitalAwalKata(isi : string) : string;
function KapitalAwalKalimat(isi: string): string;

function SplitKata(isi : string) : string;
function RightStr(InValue: string; Len: integer): String;
function LeftStr(InValue: string; Len: integer): String;
function NamaLengkap(Gelar1, Nama, Gelar2: string): String;

function Terbilang(teks: string): string;
function TglToDateFormat(tgl : string) : string;
function myPeriode(TglMulai, TglSelesai : TDate) : string;
function IsBulat(angka: Double): Boolean;

function TglINA(tgl : TDate) : string;
function TglYearMonthDate(tgl : TDate) : string;
function JamINA(waktu : string) : string;
function TampilBulan(nBulan : byte) : string;
function IsNumeric(const S: string): Boolean;

function TimeToInt(xTime : TTime): Integer;
function DateToInt(xDate : TDate): Integer;
function SecondToTime(Seconds: longint): Double;

function myStringToDate(tgl : string) : TDate;

function TampilHari : string; overload;
function TampilHari(tglDate : TDate) : string; overload;

function PesanYaTidak(isiPesan : string) : integer;
function PesanOK(isiPesan : string) : integer; overload;
function PesanOK(Judul : PWideChar; isiPesan : string) : integer; overload;

function SelectedRow(View : TcxGridDBTableView; CheckBoxColName, getColName : TcxGridDBColumn; sql1, sql2 : string) : string; overload;
function SelectedRow(View : TcxGridDBTableView; CheckBoxColName, getColName : TcxGridDBColumn) : string; overload;
function SelectedRow(View : TcxGridDBTableView; CheckBoxColName, getColName : TcxGridDBColumn; var jmlRec : integer) : string; overload;
function IsSelectedRow(View : TcxGridDBTableView; CheckBoxColName : TcxGridDBColumn) : boolean;
procedure SelectAll(View : TcxGridDBTableView; CheckBoxColName : TcxGridDBColumn; nilai: boolean);

implementation


function IsFileEksis(namaFolder, namaFile: string): boolean;
var
  ExePath, FotoFolder, FilePath, FileName: string;
begin
  // Mendapatkan path folder di mana file exe berada
  ExePath := ExtractFilePath(ParamStr(0));

  // Menentukan path folder "NamaFolder" yang sejajar dengan file exe
  FotoFolder := IncludeTrailingPathDelimiter(ExePath) + namaFolder;

  // Nama file yang ingin diperiksa
  FileName := namaFile; // Ganti dengan nama file yang ingin dicek

  // Path lengkap ke file yang ingin diperiksa
  FilePath := IncludeTrailingPathDelimiter(FotoFolder) + FileName;

  // Memeriksa apakah file ada di folder "namaFolder"
  if FileExists(FilePath) then
    result := true
  else
    result := false;
end;


function FileSizeByName(const FileName: string): Int64;
var FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyNone);
  try
    Result := FileStream.Size;
  finally
    FileStream.Free;
  end;
end;

procedure SetCustomFormatSettings;
var Fmt: TFormatSettings;
begin
  Fmt := TFormatSettings.Create;
  Fmt.ThousandSeparator := ',';
  Fmt.DecimalSeparator := '.';
  // Set format default aplikasi
  FormatSettings := Fmt;
end;

function BersihkanString(const Input: string): string;
var tmp : string;
begin
// Hapus karakter kontrol (ASCII 0-31), pertahankan spasi (32)
  tmp := TRegEx.Replace(Input, '[\x00-\x1F]', '');

  // Alternatif: ganti enter dan tab dengan spasi
  Result := TRegEx.Replace(tmp, '[\r\n\t]', ' ');
end;


function IsBulat(angka: Double): Boolean;
var
  bilanganBulat: Int64;
begin
  // Cek apakah angka adalah NaN atau Infinite
  if IsNan(angka) or IsInfinite(angka) then
  begin
    Result := False;
    Exit;
  end;

  if (angka < Low(Int64)) or (angka > High(Int64)) then
    Exit(False);

  bilanganBulat := Trunc(angka);
  Result := Abs(angka - bilanganBulat) < 1.0;
end;

function FormatTanggalIndonesia(myDate: TDate): string;
const
  NamaBulan: array[1..12] of string = (
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  );
var
  Tahun, Bulan, Hari: Word;
begin
  // Dekomposisi tanggal menjadi hari, bulan, tahun
  DecodeDate(myDate, Tahun, Bulan, Hari);

  // Pastikan bulan dalam range yang valid
  if (Bulan < 1) or (Bulan > 12) then
    Bulan := 1; // Default ke Januari jika bulan tidak valid

  // Format output: "1 Januari 2023"
  Result := IntToStr(Hari) + ' ' + NamaBulan[Bulan] + ' ' + IntToStr(Tahun);
end;


function IsFormOpen(const FormName : string): Boolean;
var i: Integer;
begin
  Result := False;
  for i := Screen.FormCount - 1 DownTo 0 do
    if (Screen.Forms[i].Name = FormName) then
    begin
      Result := True;
      Break;
    end;
end;


function IsMDIChildOpen(const AFormName: TForm; const AMDIChildName: string): Boolean;
var i: Integer;
begin
  Result := False;
  for i := Pred(AFormName.MDIChildCount) DownTo 0 do
    if (AFormName.MDIChildren[i].Name = AMDIChildName) then
    begin
      Result := True;
      Break;
    end;
end;


function FindFile2(FileName: string): boolean;
var sr : TSearchRec;
begin
  if FindFirst(FileName,faAnyFile,sr)=0 then
    Result := true
  else
    Result := false;

  FindClose(sr);
end;

function DeleteLocalFile(NamaFile : string) : boolean;
begin
  if FileExists(NamaFile)then
  begin
      if not DeleteFile(NamaFile) then
          result := false
      else result := true;
  end
  else result := false;
end;


function DeleteSpasi(Str: string): string;
var  i: Integer;
begin
  if length(trim(str)) > 0 then
  begin
      i:=0;
      while i<=Length(Str) do
        if Str[i]=' ' then Delete(Str, i, 1)
        else Inc(i);
      Result:=Str;
  end
  else result := '';
end;

function GantiKutip(Str: string): string;
var  i: Integer;
begin
  if length(trim(str)) > 0 then
  begin
      i:=0;
      while i<=Length(Str) do
        if Str[i]='''' then Delete(Str, i, 1)
        else Inc(i);
      Result:=Str;
  end
  else result := '';
end;

function AddSpasi(Str: string; awal, jml: integer): string;
var s_awal, s_akhir, hitung : integer;
  ulang: Integer;
  myStr : string;
begin
    myStr := trim(str);
    hitung := length(myStr);
    if hitung <= (awal + jml - 1) then
    begin
      s_awal := length(myStr);
      s_akhir := awal + jml - 1;

      for ulang := s_awal + 1 to s_akhir do
          myStr := myStr + ' ';
    end;
    AddSpasi := myStr;
end;

function Terbilang(teks: string): string;
const angka : array [0..9] of string = ('', 'satu ', 'dua ', 'tiga ', 'empat ',
              'lima ', 'enam ', 'tujuh ', 'delapan ', 'sembilan ');
      level : array [0..7] of string = ('', 'ribu', 'juta', 'milyar', 'trilyun',
              'kuadriliun', 'hendribiliun', 'intanliun');

var   x, grup3 : byte;
      mySign, hasil, processed, n, n1, n2, n3 : string;

begin
   if  copy(teks,1,1) = '-' then
   begin
       teks := copy(teks,2,Length(teks)-1);
       mySign := '(MINUS)';
   end
   else
    mySign := '';

   hasil := '';
   // Pad text so it fits into chunks of three character
   for x := 1 to 3-(length(teks) mod 3) do insert ('0',teks,1);
   // Grup3 is the number of group of 3 character
   grup3 := length(Teks) div 3;
   for x := grup3-1 downto 0 do begin
      processed := copy(teks, 1, 3);
      teks := copy(teks, 4, length(teks)-3);
      n1 := ''; n2 := ''; n3 := '';

      if processed[1] = '1' then n1 := 'se'
        else n1 := angka[strtoint(processed[1])];
      if length(n1) > 0 then n1 := n1 + 'ratus ';

      n2 := angka[strtoint(processed[2])];
      if length(n2) > 0 then n2 := n2 + 'puluh ';
      n3 := angka[strtoint(processed[3])];

      if processed[2] = '1' then begin
         n2 := '';
         if processed [3] = '0' then n3 := 'sepuluh '
         else if processed [3] = '1' then n3 := 'sebelas '
         else n3 := angka[strtoint(processed[3])] + 'belas ';
      end;
      n := n1+n2+n3;
      // untuk seribu
      if (n = 'satu ') and (grup3 = 2) then n := 'se';
      hasil := hasil + n;
      if n <> '' then hasil := hasil + level[x]+' ';
   end;

   if mySign <> '' then
      terbilang := mySign + ' ' + trim(UpperCase(hasil)) + ' RUPIAH'
   else
      terbilang := UpperCase(trim(hasil)) + ' RUPIAH';
end;

function TglToDateFormat(tgl: string): string;
begin
  result := copy(tgl,7,4) + '-'+ copy(tgl,4,2) + '-' + copy(tgl,1,2);
end;

function myPeriode(TglMulai, TglSelesai: TDate): string;
begin
  if YearOf(tglMulai) =  YearOf(tglSelesai) then
  begin
    if MonthOf(tglMulai) = MonthOf(tglSelesai) then
    begin
      myPeriode := formatFloat('00',DayOf(tglMulai)) + ' s.d. ' + TglINA(tglSelesai);

      if tglMulai = tglSelesai then
        myPeriode := TglINA(tglSelesai);
    end
    else
    begin
      if tglMulai = tglSelesai then
        myPeriode := TglINA(tglSelesai)
      else
        myPeriode := formatFloat('00',DayOf(tglMulai)) + ' ' + TampilBulan(MonthOf(tglMulai)) + ' s.d. ' + TglINA(tglSelesai);
    end;
  end
  else
  begin
    myPeriode := TglINA(tglMulai) + ' s.d. ' + TglINA(tglSelesai);
  end;

end;

function TglINA(tgl: TDate): string;
begin
    result  := formatDateTime('dd ',tgl) + TampilBulan(StrToInt(formatDateTime('MM',tgl))) + formatDateTime(' yyyy',tgl);
end;

function TimeToInt(xTime: TTime): Integer;
var sBuffer : String;
begin
  sBuffer := TimeToStr(xTime);
  sBuffer := StringReplace(sBuffer,':','',[rfReplaceAll]);
  sBuffer := Copy(sBuffer,1,6);
  result := StrToInt(sBuffer);
end;

function DateToInt(xDate: TDate): Integer;
var sBuffer : String;
begin
    sBuffer := DateToStr(xDate);
    sBuffer := StringReplace(sBuffer,'/','',[rfReplaceAll]);
    result := StrToInt(sBuffer);
end;

function SecondToTime(Seconds: longint): double;
const
  SecPerDay = 86400;
  SecPerHour = 3600;
  SecPerMinute = 60;
var ms, ss, mm, hh, dd: Cardinal;
begin
  dd := Seconds div SecPerDay;
  hh := Seconds div SecPerHour;
  mm := ((Seconds mod SecPerDay) mod SecPerHour) div SecPerMinute;
  ss := ((Seconds mod SecPerDay) mod SecPerHour) mod SecPerMinute;
  ms := 0;
  Result := dd + EncodeTime(hh, mm, ss, ms);
end;

function myStringToDate(tgl : string) : TDate;
var
  MyDate: TDateTime;
  FormatSettings: TFormatSettings;
begin
  // Set up the format settings
  FormatSettings := TFormatSettings.Create;
  FormatSettings.DateSeparator := '-';
  FormatSettings.ShortDateFormat := 'yyyy-mm-dd';

  try
    MyDate := StrToDate(tgl, FormatSettings);
  except
    MyDate := Date;
  end;

  result := myDate;
end;

function IsNumeric(const S: string): Boolean;
var
  I: Integer;
begin
  Result := True;
  for I := 1 to Length(S) do
  begin
    if not CharInSet(S[I], ['0'..'9']) then
    begin
      Result := False;
      Exit;
    end;
  end;
end;

function TglYearMonthDate(tgl: TDate): string;
begin
    result  := formatDateTime('yyyy',tgl) + '-' + formatDateTime('mm',tgl) + '-' + formatDateTime('dd',tgl);
end;

function TampilBulan(nBulan: byte): string;
var sBulan : string;
begin
  case nBulan of
    1: sBulan := 'Januari';
    2: sBulan := 'Februari';
    3: sBulan := 'Maret';
    4: sBulan := 'April';
    5: sBulan := 'Mei';
    6: sBulan := 'Juni';
    7: sBulan := 'Juli';
    8: sBulan := 'Agustus';
    9: sBulan := 'September';
    10: sBulan := 'Oktober';
    11: sBulan := 'November';
    12: sBulan := 'Desember';
  end;
  TampilBulan := sBulan;
end;

function TampilHari : string; overload;
var nHari : byte;
    sHari : string;
begin
  nHari := DayOfTheWeek(Date);
  case nHari of
    1: sHari := 'Senin';
    2: sHari := 'Selasa';
    3: sHari := 'Rabu';
    4: sHari := 'Kamis';
    5: sHari := 'Jum''at';
    6: sHari := 'Sabtu';
    7: sHari := 'Minggu';
  end;
  TampilHari := sHari;
end;

function TampilHari(tglDate : TDate) : string; overload;
var nHari : byte;
    sHari : string;
begin
  nHari := DayOfTheWeek(tglDate);
  case nHari of
    1: sHari := 'Senin';
    2: sHari := 'Selasa';
    3: sHari := 'Rabu';
    4: sHari := 'Kamis';
    5: sHari := 'Jum''at';
    6: sHari := 'Sabtu';
    7: sHari := 'Minggu';
  end;
  result := sHari;
end;

function JamINA(waktu: string): string;
var hasil : string;
begin
    hasil  := StringReplace(waktu, '.', ':', [rfReplaceAll, rfIgnoreCase]);
    result := hasil;
end;


function HapusEnter(sumber: string): string;
begin
  if trim(sumber) <> '' then
    result := trim(StringReplace(sumber, sLinebreak, '', [rfReplaceAll]))
  else
    result := '';
end;

function KapitalAwalKata(isi: string): string;
var T, GetString : string;
    i, GetLength : Integer;
begin
    if length(isi) > 0 then GetString:= lowercase(isi);

    GetLength:= Length(GetString) ;
    if GetLength > 0 then
    begin
         for i:= 0 to GetLength do
         begin
            if (GetString[i] = ' ') or (I=0) then
            begin
                if GetString[i+1] in ['a'..'z'] then
                begin
                  T:=GetString[i+1];
                  T:=UpperCase(T) ;
                  GetString[i+1]:=T[1];
                end;
            end;

         end;
         result := getstring;
    end
    else result := '';
end;

function KapitalAwalKalimat(isi: string): string;
var
  GetString: string;
  GetLength: Integer;
begin
  if Length(isi) = 0 then
  begin
    Result := '';
    Exit;
  end;

  GetString := LowerCase(isi);
  GetLength := Length(GetString);

  if GetLength > 0 then
  begin
    // Kapitalkan huruf pertama
    if GetString[1] in ['a'..'z'] then
      GetString[1] := UpCase(GetString[1]);

    Result := GetString;
  end;
end;

function SplitKata(isi: string): string;
var T, GetString, kata, kata2, hasil : string;
    i, j, pos1, pos2, awal, counter, GetLength : Integer;
    ulang : boolean;
begin
    hasil := '';
    GetString := isi;
    GetLength:= Length(GetString);
    pos1 := 1;
    counter := 1;

    if GetLength > 0 then
    begin
         i := 1;
         awal := i;

         While i <= GetLength do
         begin
            if (GetString[i] = ' ') then
            begin
                j := i;
                ulang := true;
                counter := counter + 1;

                if i = GetLength then
                    j := i ;

                kata := Copy(isi,awal,j - awal);
                awal := j + 1;
                //i := j;

                if NOT MatchStr(kata, ['P4TK','PPPPTK', 'BOE', 'LPMP', 'LP2KS', 'LPPKS', 'SD', 'SDN', 'SMPN', 'SMP', 'SMPS','SMA','SMAN', 'SMAS', 'SMK','SMKN', 'SMKS', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII']) then
                begin
                    kata2 := lowercase(kata);
                    if (kata2 <> '') AND (kata2[1] in ['a'..'z']) then
                    begin
                      T:=kata2[1];
                      T:=UpperCase(T) ;
                      kata2[1]:=T[1];
                      hasil := hasil + ' ' + kata2;
                    end;
                end
                else
                begin
                  hasil := hasil + ' ' + kata;
                  pos1 := j+1;
                end;

            end // end of :: if (GetString[i] = ' ')
            else
            begin
                  if i = GetLength then
                  begin
                      j := i + 1;

                      kata := Copy(isi,awal,j - awal);
                      awal := j + 1;

                      if NOT MatchStr(kata, ['P4TK','PPPPTK', 'BOE', 'LPMP', 'LP2KS', 'LPPKS', 'SD', 'SDN', 'SMPN', 'SMP','SMA','SMAN', 'SMK','SMKN', 'I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII', '1', '2', '3', '4', '5', '6', '7', '8', '9', '10', '11', '12', '13', '14', '15', '16', '17', '18', '19', '20', '21','22','23','24','25']) then
                      begin
                          kata2 := lowercase(kata);
                          if kata2[1] in ['a'..'z','0'..'9'] then
                          begin
                            T:=kata2[1];
                            T:=UpperCase(T) ;
                            kata2[1]:=T[1];
                            hasil := hasil + ' ' + kata2;
                          end
                          else hasil := hasil + ' ' + kata2;
                      end
                      else
                      begin
                        hasil := hasil + ' ' + kata;
                        pos1 := j+1;
                      end;
                  end;
            end; //end of else :: if (GetString[i] = ' ')

            i := i + 1;
         end; // end while

         hasil := trim(hasil);
         result := hasil;
    end
    else result := '';
end;

function NamaLengkap(Gelar1, Nama, Gelar2: string): String;
begin
  if trim(Gelar2) <> '' then
    Result := trim(trim(Gelar1) + ' ' + trim(nama) + ', ' + trim(Gelar2))
  else
    Result := trim(trim(Gelar1) + ' ' + trim(nama) + ' ' + trim(Gelar2));

end;


function RightStr(InValue: string; Len: integer): String;
begin
  Result := Copy(InValue, Length(InValue)-(Len - 1), Len);
end;


function LeftStr(InValue: string; Len: integer): String;
begin
  Result := Copy(InValue, 1, Len);
end;

function CariCharInStr(str, cari : string): boolean;
var  i: Integer;
begin
  i := ansipos(cari, str);
  if i = 0 then
    result := false
  else result := true;
end;

function PesanYaTidak(isiPesan: string): integer;
begin
  // yes = 6, no = 7
  result := application.MessageBox(PChar(isiPesan), 'Konfirmasi',+mb_YesNo +mb_ICONWARNING + MB_DEFBUTTON2)
end;

function PesanOK(isiPesan: string): integer; overload;
begin
  result := application.MessageBox(PChar(isiPesan), 'Konfirmasi',+ mb_OK +MB_ICONINFORMATION);
end;


function PesanOK(Judul : PWideChar; isiPesan : string) : integer; overload;
begin
  result := application.MessageBox(PChar(isiPesan), Judul, + mb_OK +MB_ICONINFORMATION);
end;


function SelectedRow(View: TcxGridDBTableView; CheckBoxColName, getColName: TcxGridDBColumn; sql1, sql2: string): string; overload;
var i, akhir : integer;
  cmd  : string;
begin
  cmd := '';

  for i := 0 to View.DataController.RowCount - 1 do
  begin
    if View.DataController.Values[i, CheckBoxColName.Index] = true then
       cmd := cmd + IntToStr(View.DataController.Values[i, getColName.Index]) + ', ';
  end;

  akhir := length(cmd);
  delete(cmd, akhir-1, 1);

  SelectedRow := cmd;
end;

function SelectedRow(View: TcxGridDBTableView; CheckBoxColName, getColName: TcxGridDBColumn): string; overload;
var i, akhir  : integer;
  cmd         : string;
  nilai       : boolean;
begin
  cmd := '';

  for i := 0 to View.DataController.RowCount - 1 do
  begin
    if View.DataController.Values[i, CheckBoxColName.Index] = true then
       cmd := cmd + IntToStr(View.DataController.Values[i, getColName.Index]) + ', ';
  end;

  akhir := length(cmd);
  delete(cmd, akhir-1, 1);

  SelectedRow := cmd;
end;

function SelectedRow(View : TcxGridDBTableView; CheckBoxColName, getColName : TcxGridDBColumn; var jmlRec : integer) : string; overload;
var jml, i, akhir   : integer;
  cmd               : string;
  nilai             : boolean;
begin
  cmd := '';
  jml := 0;
  for i := 0 to View.DataController.RowCount - 1 do
  begin
    if View.DataController.Values[i, CheckBoxColName.Index] = true then
    begin
       cmd := cmd + IntToStr(View.DataController.Values[i, getColName.Index]) + ', ';
       jml := jml + 1;
    end;
  end;

  akhir := length(cmd);
  delete(cmd, akhir-1, 1);

  jmlRec := jml;
  SelectedRow := cmd;
end;


procedure SelectAll(View: TcxGridDBTableView; CheckBoxColName: TcxGridDBColumn; nilai: boolean);
var i : integer;
begin
  for i := 0 to View.DataController.RowCount - 1 do
    View.DataController.Values[i,CheckBoxColName.Index] := nilai;
end;


function IsSelectedRow(View : TcxGridDBTableView; CheckBoxColName : TcxGridDBColumn) : boolean;
var myLoop,myCounter : integer;
    isSelect : boolean;
begin
  isSelect := false;
  myLoop    := View.DataController.RowCount - 1;
  myCounter := 0;

  while (myCounter <= myLoop) AND (NOT isSelect) do
  begin
    if View.DataController.Values[myCounter, CheckBoxColName.Index] = true then
      isSelect := true
    else
      myCounter := myCounter + 1;
  end;
  Result := isSelect;
end;

function ReportFileTimes(const FileName: string; atribut : integer): string;

  function ReportTime(const FileTime: TFileTime) : string;
  var SystemTime, LocalTime: TSystemTime;
  begin
    if not FileTimeToSystemTime(FileTime, SystemTime) then
      RaiseLastOSError;
    if not SystemTimeToTzSpecificLocalTime(nil, SystemTime, LocalTime) then
      RaiseLastOSError;
    result := FormatDateTime('dd-mm-yyyy HH:mm:ss', SystemTimeToDateTime(LocalTime));
    //result := Name + ': ' + DateTimeToStr(SystemTimeToDateTime(LocalTime));

  end;

var
  fad: TWin32FileAttributeData;
  hasil : string;
begin
  hasil := '';
  if not GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @fad) then
    RaiseLastOSError;

  if atribut = 1 then  // file create
    hasil := hasil + ReportTime(fad.ftCreationTime);

  if atribut = 2 then  // last modified
    hasil := hasil + ReportTime(fad.ftLastWriteTime);

  result := hasil;
end;

function myReplaceChar(tulisan : string; asli,ganti : char) : string;
var S: string;
begin
  S := tulisan;
  { Convert asli to ganti }
  while Pos(asli, S) > 0 do
    S[Pos(asli, S)] := ganti;

  Result := S;
end;

function myReplaceChar_String(Dest, Str: string; SubStr : char): string;
// contoh untuk REPLACE " menjadi ""
var i : Integer;
begin
    i := 1;
    while i < Length(Dest) do
    begin
        if Dest[i] = SubStr then
        begin
            Delete(Dest, i, Length(SubStr));
            Insert(Str, Dest, i);
            i := i + Length(Str);
        end
        else
            i:= i + 1;
    end;

  Result := Dest;
end;

function myReplaceDoubleQuote(tulisan: string) : string;
var S: string;
begin
  S := tulisan;
  StringReplace(S, '"', '""',[rfReplaceAll, rfIgnoreCase]);
  Result := S;
end;

function ReplaceEnDashWithHyphen(InputString : string) : string;
begin
  // En dash memiliki kode Unicode #$2013
  // Tanda hubung biasa memiliki kode ASCII #$2D
  Result := StringReplace(InputString, '–', '-', [rfReplaceAll]);
end;


end.
