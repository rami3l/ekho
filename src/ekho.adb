with Libekho.Client;
with Libekho.Server;
with GNAT.Sockets; use GNAT.Sockets;

procedure Ekho is
   task Ping is
      entry Start;
      entry Stop;
   end Ping;

   task Pong is
      entry Start;
      entry Stop;
   end Pong;

   task body Ping is
   begin
      accept Start;
      Libekho.Client.Launch;
      accept Stop;
   end Ping;

   task body Pong is
   begin
      accept Start;
      Libekho.Server.Launch;
      accept Stop;
   end Pong;
begin
   Pong.Start;
   Ping.Start;
   Ping.Stop;
   Pong.Stop;
end Ekho;
