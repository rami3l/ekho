with Ada.Unchecked_Deallocation;
with RFLX.Ekho.Packet;
with RFLX.Ekho; use RFLX.Ekho;
with RFLX.RFLX_Types;

package body Libekho is
    package Types renames RFLX.RFLX_Types;
    package Packet renames RFLX.Ekho.Packet;

    function To_Message (Str : in String) return Message is
       (Size => Str'Length, Str => Str);

    procedure Write
       (Stream :    not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : in Message)
    is
        Buffer : Types.Bytes_Ptr :=
           new Types.Bytes (Types.Index'First .. Types.Index (255));
        Context : Packet.Context;
        procedure Free is new Ada.Unchecked_Deallocation(Types.Bytes, Types.Bytes_Ptr);
    begin
        Packet.Initialize (Context, Buffer);
        Packet.Set_Size (Context, Str_Size(Item.Size));
        if Item.Size /= 0 then
            Packet.Set_Str
               (Context, [for C of Item.Str => Character'Pos (C)]);
        end if;
        Packet.Take_Buffer (Context, Buffer);
        -- Ada.Text_IO.Put_Line ("TRUNCATED BUFFER: "  &  Buffer.all(1..Types.Index(1 + Item.Size))'Image);
        Types.Bytes'Write (Stream, Buffer.all(1..Types.Index(1 + Item.Size)));
        Free (Buffer);
    end Write;
    -- https://stackoverflow.com/a/22770989

    function Read
       (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
        return Message
    is
        Size : Str_Size;
    begin
        Str_Size'Read (Stream, Size);
        declare
            Str : String (1 .. Integer(Size));
        begin
            String'Read (Stream, Str);
            return (Size => Message_Size_Type(Size), Str => Str);
            -- NOTE: Returning to the Secondary Stack.
            -- https://docs.adacore.com/gnat_ugx-docs/html/gnat_ugx/gnat_ugx/the_stacks.html
        end;
    end Read;
end Libekho;
