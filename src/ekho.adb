with Libekho.Client;
with Libekho.Server;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;
with GNAT.Exception_Traces;

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
      Listener    : Libekho.Server.Server;
      Peer_Socket : Socket_Type;
      Peer_Addr   : Sock_Addr_Type;
   begin
      Libekho.Server.Bind (Addr, Listener);
      accept Start;
      Put_Line ("Server: Accepting peer socket...");
      Listener.Accept_Incoming (Peer_Socket, Peer_Addr);
      Put_Line ("Server: Peer socket accepted.");
      declare
         Received : String := String'Input (Stream (Peer_Socket));
      begin
         Put_Line ("Server Received: " & Received);
         Put_Line ("Server: Closing peer socket...");
         Close_Socket (Peer_Socket);
      end;
      accept Stop;
   end Pong;

begin
   GNAT.Exception_Traces.Trace_On (GNAT.Exception_Traces.Every_Raise);
   Pong.Start;
   Pong.Stop;
end Ekho;
