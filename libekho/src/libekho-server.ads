with Ada.Finalization;
with GNAT.Sockets; use GNAT.Sockets;

package Libekho.Server is
    type Server is new Ada.Finalization.Controlled with record
        Addr    : Sock_Addr_Type;
        Channel : Socket_Type;
    end record;
    -- https://doc.rust-lang.org/std/net/struct.TcpListener.html

    procedure Bind (Addr : Sock_Addr_Type; Res : out Server);

    procedure Accept_Incoming
       (Self      : in     Server; Peer_Socket : out Socket_Type;
        Peer_Addr :    out Sock_Addr_Type);

    overriding procedure Finalize (Self : in out Server);
end Libekho.Server;
