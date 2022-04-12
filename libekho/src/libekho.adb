with Ada.Streams; use Ada.Streams;
with Ada.Unchecked_Deallocation;
with RFLX.Ekho.Packet;
with RFLX.Ekho; use RFLX.Ekho;
with RFLX.RFLX_Builtin_Types;
with RFLX.RFLX_Types;
with Libekho.Compat; use Libekho.Compat;

with Ada.Text_IO;

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
        new Types.Bytes (1 .. Types.Index (1 + 255));
      Context : Packet.Context;
      procedure Free is new Ada.Unchecked_Deallocation
        (Types.Bytes, Types.Bytes_Ptr);
   begin
      Packet.Initialize (Context, Buffer);
      Packet.Set_Size (Context, Str_Size (Item.Size));
      if Item.Size /= 0 then
         Packet.Set_Str (Context, [for C of Item.Str => Character'Pos (C)]);
      end if;
      Packet.Take_Buffer (Context, Buffer);
      -- Ada.Text_IO.Put_Line ("TRUNCATED BUFFER: "  &  Buffer.all(1..Types.Index(1 + Item.Size))'Image);
      Types.Bytes'Write
        (Stream, Buffer.all (1 .. Types.Index (1 + Item.Size)));
      Free (Buffer);
   end Write;
   -- https://stackoverflow.com/a/22770989

   function Read
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Message
   is
      Size : Stream_Element_Array (1 .. 1);
      Size_Offset: Stream_Element_Offset;
      Buffer : Stream_Element_Array (1 .. (1+255));
      Last : Stream_Element_Offset;
      Context : Packet.Context;

      procedure Free is new Ada.Unchecked_Deallocation
        (Types.Bytes, Types.Bytes_Ptr);
   begin
      Read (Stream.all, Size, Last);
      Buffer(1) := Size(1);
      Size_Offset := Stream_Element_Offset(Size(1));
      Ada.Text_IO.Put_Line("SIZE: " & Size'Image);
      Read (Stream.all, Buffer(2..(1+Size_Offset)), Last);
      Ada.Text_IO.Put_Line("BUFFER: " & Buffer(1..(1+ Size_Offset))'Image);
      declare
         Bytes_Buffer : Types.Bytes_Ptr := new Types.Bytes'(To_RFLX_Bytes(Buffer(1..(1+Size_Offset))));
      begin
         Ada.Text_IO.Put_Line("BYTES_BUFFER: " & Bytes_Buffer.all'Image);
         Packet.Initialize (Context, Bytes_Buffer);
         Packet.Verify_Message (Context);
         declare
            Size : constant Message_Size_Type := Message_Size_Type(Size_Offset);
            Str_Bytes : Types.Bytes (1.. Types.Index(Size));
         begin
            Packet.Get_Str (Context, Str_Bytes);
            Free (Bytes_Buffer);
            return (Size => Size, Str => [for C of Str_Bytes => Character'Val (C)]);
            -- NOTE: Returning to the Secondary Stack.
            -- https://docs.adacore.com/gnat_ugx-docs/html/gnat_ugx/gnat_ugx/the_stacks.html
         end;
     end;
   end Read;
end Libekho;
