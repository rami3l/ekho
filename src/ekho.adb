with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Exception_Traces;
with GNAT.Sockets; use GNAT.Sockets;
with Libekho.Listener;
with Libekho;      use Libekho;

procedure Ekho is
   Addr : constant Sock_Addr_Type :=
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
      -- Put_Line ("Ping: Connecting socket " & Channel'Image);
      Put_Line ("Ping: Connecting socket...");
      Connect_Socket (Socket => Channel, Server => Addr);
      loop
         Put ("ping> ");
         declare
            Got : constant String := Get_Line;
         begin
            Message'Write (Stream (Channel), To_Message (Got));
            exit when Got = "";
         end;
         declare
            Received : constant Message := Read (Stream (Channel));
         begin
            Put_Line ("Ping Received: " & Received.Str);
         end;
      end loop;
      accept Stop;
      Put_Line ("Ping: Closing socket...");
      Close_Socket (Channel);
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
      loop
         declare
            Received : constant Message := Read (Stream (Peer_Socket));
         begin
            Put_Line ("Pong Received: " & Received.Str);
            Message'Write (Stream (Peer_Socket), Received);
            exit when Received.Str = "";
         end;
      end loop;
      accept Stop;
      Put_Line ("Pong: Closing peer socket...");
      Close_Socket (Peer_Socket);
   end Pong;

begin
   GNAT.Exception_Traces.Trace_On (GNAT.Exception_Traces.Every_Raise);
   Pong.Start;
   Ping.Start;
   Ping.Stop;
   Pong.Stop;
end Ekho;
