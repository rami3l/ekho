with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Exception_Traces;
with GNAT.Sockets;          use GNAT.Sockets;
with Libekho.Listener;
with Libekho;               use Libekho;

procedure Ekho is
   Addr : Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 55_660, others => <>);

   task Ping is
      entry Start;
      entry Stop;
   end Ping;

   task Pong is
      entry Start;
      entry Stop;
   end Pong;

   task body Ping is
      Channel : Socket_Type;
   begin
      accept Start;
      Put_Line ("Ping launched!");
      Put_Line ("Ping: Creating socket...");
      Create_Socket (Channel);
      Put_Line ("Ping: Connecting socket " & Channel'Image);
      Connect_Socket (Socket => Channel, Server => Addr);
      Put_Line ("Ping: Sending message...");
      Message'Write (Stream (Channel), To_Message ("HeLlo the S0ck3t w0r1d!"));
      declare
         Received : Message (Size => 23);
      begin
         Message'Read (Stream (Channel), Received);
         Put_Line ("Ping Received: " & Received.Str);
         Put_Line ("Ping: Closing socket...");
         Close_Socket (Channel);
         accept Stop;
      end;
   end Ping;

   task body Pong is
      Listener    : Libekho.Listener.Listener;
      Peer_Socket : Socket_Type;
      Peer_Addr   : Sock_Addr_Type;
   begin
      Libekho.Listener.Bind (Addr, Listener);
      accept Start;
      Put_Line ("Pong: Accepting peer socket...");
      Listener.Accept_Incoming (Peer_Socket, Peer_Addr);
      Put_Line ("Pong: Peer socket accepted.");
      declare
         Received : Message := Read (Stream (Peer_Socket));
      begin
         Put_Line ("Pong Received: " & Received.Str);
         Message'Write (Stream (Peer_Socket), Received);
         Put_Line ("Pong: Closing peer socket...");
         Close_Socket (Peer_Socket);
      end;
      accept Stop;
   end Pong;

begin
   GNAT.Exception_Traces.Trace_On (GNAT.Exception_Traces.Every_Raise);
   Pong.Start;
   Ping.Start;
   Ping.Stop;
   Pong.Stop;
end Ekho;
