with Ada.Streams;
with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types;
with RFLX.Ekho.Packet;
with Ada.Unchecked_Conversion;
with Ada.Text_IO; use Ada.Text_IO;

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
           new Types.Bytes (Types.Index'First .. Types.Index'Last);
        -- TODO: What about dealloc?
        Context : Packet.Context;
    begin
        -- Put_Line("BUFFER: " & Buffer.all'Image);
        Packet.Initialize (Context, Buffer);
        Put_Line("BUFFER: " & Buffer.all'Image);
        Packet.Set_Size (Context, RFLX.Ekho.Message_Size_Type (Item.Size));
        if Item.Size /= 0 then
            Packet.Set_Str
               (Context, (for C of Item.Str => Character'Pos (C)));
        end if;
        Put_Line("BUFFER: " & Buffer.all'Image);
        Types.Bytes'Write(Stream, Buffer.all(1..Types.Index(Item.Size)));
    end Write;
    -- https://stackoverflow.com/a/22770989

    function Read
       (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
        return Message
    is
        Size : Message_Size_Type;
    begin
        Message_Size_Type'Read (Stream, Size);
        declare
            Str : String (1 .. Size);
        begin
            String'Read (Stream, Str);
            return (Size => Size, Str => Str);
            -- NOTE: Returning to the Secondary Stack.
            -- https://docs.adacore.com/gnat_ugx-docs/html/gnat_ugx/gnat_ugx/the_stacks.html
        end;
    end Read;
end Libekho;
