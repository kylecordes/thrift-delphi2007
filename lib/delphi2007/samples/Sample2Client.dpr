program Sample2Client;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  classes,
  Thrift,
  uCollections,
  Thrift.Utils,
  Thrift.Stream,
  Thrift.Protocol,
  Thrift.Server,
  Thrift.Transport,
  Sample2 in 'gen-delphi7\Sample2.pas';
const
U_PORT=9090;
{Client App}
type
  TSample2Client = class
  public
    class procedure Main;
  end;

{ TSample1Client }

class procedure TSample2Client.Main;
var transport : ITransport;
    protocol  : IProtocol;
    client    : TSample2.Iface;
    sum, quotient, diff : Integer;
    work      : IWork;
begin
  try
    transport := TSocketImpl.Create( 'localhost', U_PORT);
    protocol  := TBinaryProtocolImpl.Create( transport);
    client    := TSample2.TClient.Create( protocol);

    transport.Open;

    try
      WriteLn('Call ping()..');
      client.ping;
      WriteLn('Call ping()..OK');
    except
      on e: Sysutils.Exception   do   WriteLn('....Error:'+e.Message);
    end;

    try
      WriteLn('Call add(5,9)=14');
      sum := client.add( 5, 9);
      Writeln( Format( 'Call ADD result: 5+9=%d', [sum]));
    except
      on e: Sysutils.Exception   do   WriteLn('....Error:'+e.Message);
    end;


    work := TWorkImpl.Create;

    work.Op   := Sample2.DIVIDE;
    work.Num1 := 1;
    work.Num2 := 0;

    try
      Writeln( 'Call calculator method: 1/0: result is exception');
      quotient := client.calculate(1, work);
      Writeln( Format('1/0=%d',[quotient]));
    except
      on io: TInvalidOperation
      do Writeln( '....Invalid operation: ' + io.Why);
    end;

    work.Op   := Sample2.SUBTRACT;
    work.Num1 := 15;
    work.Num2 := 10;
    try
      diff := client.calculate( 1, work);
      Writeln( Format('15-10=%d', [diff]));
    except
      on io: TInvalidOperation
      do Writeln( 'Invalid operation: ' + io.Why);
    end;



    transport.Close();

  except
    on e : Sysutils.Exception
    do WriteLn( e.ClassName+': '+e.Message);
  end;
end;


begin
  try
    Writeln( 'Thrift Delphi Sample Version '+Thrift.Version);
    Writeln( 'Client Connect to Server ');
    TSample2Client.Main;
    Readln;

  except
    on E:Sysutils.Exception do
      Writeln(E.Classname, ': ', E.Message);
  end;
end.
