with Ada.Streams;
with Ada.Text_IO;  use Ada.Text_IO;
with GNAT.Sockets; use GNAT.Sockets;

package body Libekho.Listener is
    procedure Bind (Addr : Sock_Addr_Type; Res : out Listener) is
    begin
        Res.Addr := Addr;
        Put_Line ("Listener launched!");
        Put_Line ("Listener: Creating socket and setting up...");
        Create_Socket (Res.Channel);
        Set_Socket_Option (Res.Channel, Socket_Level, (Reuse_Address, True));
        Put_Line
           ("Listener: Binding socket " & Res.Channel'Image & " to " &
            Res.Addr'Image);
        Bind_Socket (Res.Channel, Res.Addr);
        Put_Line ("Listener: Listening socket...");
        Listen_Socket (Res.Channel);
    end Bind;

    procedure Accept_Incoming
       (Self      : in     Listener; Peer_Socket : out Socket_Type;
        Peer_Addr :    out Sock_Addr_Type)
    is
    begin
        Accept_Socket (Self.Channel, Peer_Socket, Peer_Addr);
    end Accept_Incoming;

    overriding procedure Finalize (Self : in out Listener) is
    begin
        Close_Socket (Self.Channel);
    end Finalize;
end Libekho.Listener;
