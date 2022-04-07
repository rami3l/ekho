with Ada.Streams;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

package body Libekho.Server is
    procedure Launch is
        Addr    : Sock_Addr_Type;
        Port    : Port_Type := 55_660;
        Channel : Socket_Type;
        Socket  : Socket_Type;
    begin
        Addr.Addr := Inet_Addr ("127.0.0.1");
        Addr.Port := Port;
        Put_Line ("Server launched!");
        Put_Line ("Server: Creating socket and setting up...");
        Create_Socket (Channel);
        Set_Socket_Option (Channel, Socket_Level, (Reuse_Address, True));
        Put_Line
           ("Server: Binding socket " & Channel'Image & " to " & Addr'Image);
        Bind_Socket (Channel, Addr);
        Put_Line ("Server: Listening socket...");
        Listen_Socket (Channel);
        Put_Line ("Server: Accepting socket...");
        Accept_Socket (Channel, Socket, Addr);
        Put_Line ("Server: Socket accepted.");
        declare
            Socket_Stream : Stream_Access := Stream (Socket);
            Received      : String        := String'Input (Socket_Stream);
        begin
            Put_Line ("Server Received: " & Received);
            -- String'Write (Socket_Stream, Received);
        end;
        Put_Line ("Server: Closing socket...");
        Close_Socket (Socket);
        Close_Socket (Channel);
    end Launch;
end Libekho.Server;
