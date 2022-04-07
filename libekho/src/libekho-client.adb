with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Sockets;          use GNAT.Sockets;

package body Libekho.Client is
    procedure Launch is
        Addr    : Sock_Addr_Type;
        Port    : Port_Type := 55_660;
        Channel : Socket_Type;
    begin
        Addr.Addr := Inet_Addr ("127.0.0.1");
        Addr.Port := Port;
        Put_Line ("Client launched!");
        Put_Line ("Client: Creating socket...");
        Create_Socket (Channel);
        Put_Line ("Client: Connecting socket " & Channel'Image);
        Connect_Socket (Socket => Channel, Server => Addr);
        Put_Line ("Client: Sending message...");
        Unbounded_String'Write
           (Stream (Channel), To_Unbounded_String ("HeLlo the S0ck3t w0r1d!"));
        Put_Line ("Client: Closing socket...");
        Close_Socket (Channel);
    end Launch;
    -- From https://rosettacode.org/wiki/Sockets#Ada
end Libekho.Client;
