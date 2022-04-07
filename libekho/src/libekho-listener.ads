with Ada.Finalization;
with GNAT.Sockets; use GNAT.Sockets;

package Libekho.Listener is
    type Listener is new Ada.Finalization.Controlled with record
        Addr    : Sock_Addr_Type;
        Channel : Socket_Type;
    end record;
    -- https://doc.rust-lang.org/std/net/struct.TcpListener.html

    procedure Bind (Addr : Sock_Addr_Type; Res : out Listener);

    procedure Accept_Incoming
       (Self      : in     Listener; Peer_Socket : out Socket_Type;
        Peer_Addr :    out Sock_Addr_Type);

    overriding procedure Finalize (Self : in out Listener);
end Libekho.Listener;