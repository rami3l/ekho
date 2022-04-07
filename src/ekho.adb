with Libekho.Client;
with Libekho.Server;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

procedure Ekho is
   Addr : Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 55_660, others => <>);

   -- task Ping is
   --    entry Start;
   --    entry Stop;
   -- end Ping;

   task Pong is
      entry Start;
      entry Stop;
   end Pong;

   -- task body Ping is
   -- begin
   --    accept Start;
   --    Libekho.Client.Launch;
   --    accept Stop;
   -- end Ping;

   task body Pong is
      Listener : Libekho.Server.Server := Libekho.Server.Bind (Addr);
   begin
      accept Start;
      Put_Line ("Server: got it here socket...");
      declare
         Peer_Socket : Socket_Type;
         Peer_Addr   : Sock_Addr_Type;
         Received    : String := "";
      begin
         Put_Line ("Server: Accepting peer socket...");
         Listener.Accept_Incoming (Peer_Socket, Peer_Addr);
         Put_Line ("Server: Peer socket accepted.");
         Received := String'Input (Stream (Peer_Socket));
         Put_Line ("Server Received: " & Received);
         Put_Line ("Server: Closing peer socket...");
         Close_Socket (Peer_Socket);
      end;
      accept Stop;
   end Pong;

begin
   Pong.Start;
   Pong.Stop;
end Ekho;
