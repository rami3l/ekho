with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Text_IO;           use Ada.Text_IO;
with GNAT.Exception_Traces;
with GNAT.Sockets;          use GNAT.Sockets;
with Libekho.Listener;

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
      Put_Line ("Sender launched!");
      Put_Line ("Sender: Creating socket...");
      Create_Socket (Channel);
      Put_Line ("Sender: Connecting socket " & Channel'Image);
      Connect_Socket (Socket => Channel, Server => Addr);
      Put_Line ("Sender: Sending message...");
      Unbounded_String'Write
        (Stream (Channel), To_Unbounded_String ("HeLlo the S0ck3t w0r1d!"));
      Put_Line ("Sender: Closing socket...");
      Close_Socket (Channel);
      accept Stop;
   end Ping;

   task body Pong is
      Listener    : Libekho.Listener.Listener;
      Peer_Socket : Socket_Type;
      Peer_Addr   : Sock_Addr_Type;
   begin
      Libekho.Listener.Bind (Addr, Listener);
      accept Start;
      Put_Line ("Listener: Accepting peer socket...");
      Listener.Accept_Incoming (Peer_Socket, Peer_Addr);
      Put_Line ("Listener: Peer socket accepted.");
      declare
         Received : String := String'Input (Stream (Peer_Socket));
      begin
         Put_Line ("Listener Received: " & Received);
         Put_Line ("Listener: Closing peer socket...");
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
