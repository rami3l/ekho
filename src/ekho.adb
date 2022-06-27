with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Exception_Traces;
with GNAT.Sockets; use GNAT.Sockets;
with Libekho.Listener;
with Libekho;      use Libekho;
with Ada.Streams;  use Ada.Streams;

procedure Ekho is
   Ping_Addr : constant Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 55_660, others => <>);
   Pong_Addr : constant Sock_Addr_Type :=
     (Addr => Inet_Addr ("127.0.0.1"), Port => 55_661, others => <>);

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
      Buffer  : Stream_Element_Array (1 .. 256);
      Last    : Stream_Element_Offset;
   begin
      accept Start;
      Put_Line ("Ping launched!");
      Put_Line ("Ping: Creating socket...");
      Create_Socket (Channel, Mode => Socket_Datagram);
      Set_Socket_Option
        (Channel, Level => Socket_Level, Option => (Reuse_Address, True));
      Bind_Socket (Channel, Ping_Addr);
      loop
         Put ("ping> ");
         declare
            Got : constant String := Get_Line;
         begin
            Send_Socket
              (Channel, Write (To_Message (Got)), Last, To => Pong_Addr);
            exit when Got = "";
         end;
         Receive_Socket (Channel, Buffer, Last);
         declare
            Got : constant Message := Read (Buffer, Last);
         begin
            Put_Line ("Ping Received: " & Got.Str);
         end;
      end loop;
      accept Stop;
      Put_Line ("Ping: Closing socket...");
      Close_Socket (Channel);
   end Ping;

   task body Pong is
      Listener  : Libekho.Listener.Listener;
      Buffer    : Stream_Element_Array (1 .. 256);
      Last      : Stream_Element_Offset;
      Peer_Addr : Sock_Addr_Type;
   begin
      Libekho.Listener.Bind (Pong_Addr, Listener);
      accept Start;

      loop
         Receive_Socket (Listener.Channel, Buffer, Last, From => Peer_Addr);
         declare
            Got : constant Message := Read (Buffer, Last);
         begin
            Put_Line ("Pong Received: " & Got.Str);
            Send_Socket (Listener.Channel, Write (Got), Last, To => Peer_Addr);
            exit when Got.Str = "";
         end;
      end loop;
      accept Stop;
      Put_Line ("Pong: Closing peer socket...");
   end Pong;

begin
   GNAT.Exception_Traces.Trace_On (GNAT.Exception_Traces.Every_Raise);
   Pong.Start;
   Ping.Start;
   Ping.Stop;
   Pong.Stop;
end Ekho;
