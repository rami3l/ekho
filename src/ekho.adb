with Libekho.Client;
with Libekho.Server;
with GNAT.Sockets; use GNAT.Sockets;

procedure Ekho is
   task Ping is
      entry Start;
      entry Stop;
   end Ping;

   task body Ping is
   begin
      accept Start;
      Libekho.Client.Launch;
      accept Stop;
   end Ping;

   task Pong is
      entry Start;
      entry Stop;
   end Pong;

   task body Pong is
   begin
      accept Start;
      Ping.Start;
      Libekho.Server.Launch;
      Ping.Stop;
      accept Stop;
   end Pong;
begin
   Pong.Start;
   Pong.Stop;
end Ekho;
