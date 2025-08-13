unit Projeto.Controller.RegisterLog;

interface

uses
   System.SyncObjs,
   System.UITypes,
   System.Generics.Collections,
   System.Generics.Defaults;

type
   TRecNameDate = record
      Name: string;
      Date: TDateTime;
   end;

   TRegisterLog = class
   private
      class var
         FCriticalFile: TCriticalSection;
      class var
         FFileName: string;
      class var
         FPathLogFiles: string;
      class var
         FQuantMaxLogs: integer;
      class var
         _myinstance: TRegisterLog;
      constructor Create;
      class function BuildFileLogName: string; overload; static;
      class function BuildFileLogName(pFileName: string): string; overload; static;
      class procedure ClearLogs; overload;
      class procedure ClearLogs(pPrefixoLog: string); overload;
      class function FileName(const Nome: string): string;
      class function LoadDirectorySorted(pDir: string; pMask: string = '*.*'): TList<TRecNameDate>;
      class procedure LogFile(pMessage: string); overload;
      class procedure LogFile(pFileName: string; pMessage: string); overload;
   public
      destructor Destroy; override;
      class function  i: TRegisterLog;
      class procedure Log(pFileName: string; pMessage: string; pDanger: boolean = false); overload;
      class procedure Log(pMessage: string; pColor: TColor = TColorRec.Black); overload;
      class procedure myFree;
      class procedure SetProperties(pPathLogFiles: string; pQuantMaxLogs: integer = 30); overload;
      class procedure SetProperties(pPathLogFiles: string; pFileName: string; pQuantMaxLogs: integer = 30); overload;
   end;

implementation

uses
   System.SysUtils,
   System.Classes,
   Projeto.Controller.FuncoesReadParams,
   System.IOUtils;

constructor TRegisterLog.Create;
begin
  // use "GetInstance"
end;

destructor TRegisterLog.Destroy;
begin
  FreeAndNil(FCriticalFile);
  if Assigned(_myinstance) then FreeAndNil(_myinstance);

  inherited;
end;

class function TRegisterLog.BuildFileLogName: string;
begin
   Result := '';
   FPathLogFiles := TPath.Combine(FPathLogFiles, TPath.Combine(ExtractFilePath(ParamStr(0)), 'Log'));
   if not DirectoryExists(FPathLogFiles) then
   begin
      if not ForceDirectories(FPathLogFiles) then
      begin
         exit;
      end;
   end;
   if FFileName.IsEmpty then
   begin
      FFileName := FileName(ParamStr(0));
   end;
   result := FFileName + '_' + FormatDateTime('yyyymmdd', now) + '.log';
   result := TPath.Combine(FPathLogFiles, result);
end;

class function TRegisterLog.BuildFileLogName(pFileName: string): string;
//var
   //xTemp: string;
begin
   Result := '';
   FFileName := pFileName;
   FPathLogFiles := TPath.Combine(FPathLogFiles, TPath.Combine(ExtractFilePath(ParamStr(0)), 'Log'));
   if not DirectoryExists(FPathLogFiles) then
   begin
      if not ForceDirectories(FPathLogFiles) then
      begin
         exit;
      end;
   end;
   if FFileName.IsEmpty then
   begin
      FFileName := FileName(ParamStr(0));
   end;
   result := FFileName + '_' + FormatDateTime('yyyymmdd', now) + '.log';
   result := TPath.Combine(FPathLogFiles, result);
end;

class procedure TRegisterLog.ClearLogs;
var
   xList: TList<TRecNameDate>;
   idx: integer;
//  xElem: TRecNameDate;
   xTotalRemover: integer;
begin
   if not DirectoryExists(FPathLogFiles) then
      exit;

   xList := nil;

   try
      // esta lista já vem ORDENADA pela Data do Arquivo
      xList := LoadDirectorySorted(FPathLogFiles, FFileName + '*.log');
      xTotalRemover := xList.Count - FQuantMaxLogs;

      if xTotalRemover <= 0 then
         exit;

      for idx := 0 to xTotalRemover - 1 do
      begin
         DeleteFile(xList[idx].Name)
      end;
   finally
      xList.Free;
   end;
end;

class procedure TRegisterLog.ClearLogs(pPrefixoLog: string);
var
   xList: TList<TRecNameDate>;
   idx: integer;
   //xElem: TRecNameDate;
   xTotalRemover: integer;
begin
   if not DirectoryExists(FPathLogFiles) then
      exit;

   try
      // esta lista já vem ORDENADA pela Data do Arquivo
      xList := LoadDirectorySorted(FPathLogFiles, pPrefixoLog + '*.log');
      xTotalRemover := xList.Count - FQuantMaxLogs;

      if xTotalRemover <= 0 then
         exit;

      for idx := 0 to xTotalRemover - 1 do
      begin
         DeleteFile(xList[idx].Name)
      end;
   finally
      //xList.Free;
   end;
end;

class function TRegisterLog.i: TRegisterLog;
begin
   if not assigned(_myinstance) then
   begin
      _myinstance := TRegisterLog.Create;
      FCriticalFile := TCriticalSection.Create;
   end;

   Result := _myinstance;
end;

class function TRegisterLog.LoadDirectorySorted(pDir: string; pMask: string = '*.*'): TList<TRecNameDate>;
var
   SRec: TSearchRec;
   Done: Integer;
   xRec: TRecNameDate;
begin
    // o 'chamador' tem que dar free!
   Result := TList<TRecNameDate>.create;
   pDir := IncludeTrailingPathDelimiter(pDir);
   try
      Done := FindFirst(pDir + pMask, faAnyFile, SRec);
      while Done = 0 do
      begin
         if (SRec.Attr = faDirectory) and ((SRec.Name = '.') or (SRec.Name = '..')) then
         begin
            Done := FindNext(SRec);
            continue;
         end;

         if SRec.Attr <> faDirectory then
         begin
            xRec.Name := TPath.Combine(pDir, SRec.Name);
            xRec.Date := SRec.TimeStamp;
            Result.Add(xRec);
         end;

         Done := FindNext(SRec);
      end;

      Result.Sort(TComparer<TRecNameDate>.Construct(  // uses System.Generics.Defaults,
         function(const Left, Right: TRecNameDate): integer
         begin
            if Left.Date = Right.Date then
               Result := 0
            else if Left.Date < Right.Date then
               Result := -1
            else
               Result := 1;
         end))

   finally
      FindClose(SRec);
   end;
end;

class procedure TRegisterLog.Log(pFileName: string; pMessage: string; pDanger: boolean = false);
const
   C_RED = $005B5BFF;
   C_BLACK = $00000000;
var
   pMsg1, pMsg2: string;
begin
   pMsg1 := FormatDateTime('dd/mm HH:nn:ss', now) + '  ' + pMessage;
   pMsg2 := FormatDateTime('dd/mm HH:nn:ss', now) + '  [' + pFileName + '] ' + pMessage;

   LogFile(pFileName, pMsg1);
end;

class procedure TRegisterLog.Log(pMessage: string; pColor: TColor = TColorRec.Black);
const
   C_RED = $005B5BFF;
   C_BLACK = $00000000;
begin
   pMessage := FormatDateTime('dd/mm HH:nn:ss', now) + '  ' + pMessage;
   LogFile(pMessage);
end;

class procedure TRegisterLog.LogFile(pMessage: string);
var
   xFile: TextFile;
   xFullFileName: string;
begin
   xFullFileName := BuildFileLogName;
   if xFullFileName.IsEmpty then
   begin
      exit;
   end;

   FCriticalFile.Acquire;
   try
      AssignFile(xFile, xFullFileName);
      if FileExists(xFullFileName) then
         Append(xFile)
      else
      begin
         ClearLogs;
         Rewrite(xFile);
      end;

      Writeln(xFile, pMessage);
      CloseFile(xFile);
   finally
      FCriticalFile.Release;
   end;
end;

class procedure TRegisterLog.LogFile(pFileName: string; pMessage: string);
var
   xFile: TextFile;
   xFullFileName: string;
begin
   xFullFileName := BuildFileLogName(pFileName);
   if xFullFileName.IsEmpty then
   begin
      exit;
   end;

   FCriticalFile.Acquire;
   try
      AssignFile(xFile, xFullFileName);
      if FileExists(xFullFileName) then
         Append(xFile)
      else
      begin
         ClearLogs(pFileName);
         Rewrite(xFile);
      end;

      Writeln(xFile, pMessage);
      CloseFile(xFile);
   finally
      FCriticalFile.Release;
   end;
end;

class procedure TRegisterLog.MyFree;
begin
   if assigned(_myinstance) then
   begin
      FreeAndNil(_myinstance);
   end;
end;

class procedure TRegisterLog.SetProperties(pPathLogFiles: string; pQuantMaxLogs: integer = 30);
begin
   FPathLogFiles := pPathLogFiles;
   FQuantMaxLogs := pQuantMaxLogs;
end;

class procedure TRegisterLog.SetProperties(pPathLogFiles: string; pFileName: string; pQuantMaxLogs: integer = 30);
begin
   FPathLogFiles := pPathLogFiles;
   FFileName := pFileName;
   FQuantMaxLogs := pQuantMaxLogs;
end;

class function TRegisterLog.FileName(const Nome: string): string;
begin
   Result := ExtractFileName(Nome);
   Result := ChangeFileExt(Result, '');
end;

end.

