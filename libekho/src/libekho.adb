with Ada.Unchecked_Deallocation;
with Libekho.Compat; use Libekho.Compat;
with RFLX.Ekho.Packet;
with RFLX.Ekho; use RFLX.Ekho;
with RFLX.RFLX_Types;
with RFLX.RFLX_Builtin_Types; use RFLX.RFLX_Builtin_Types;

package body Libekho is
   package Types renames RFLX.RFLX_Types;
   package Packet renames RFLX.Ekho.Packet;

   function To_Message (Str : in String) return Message is
     (Size => Str'Length, Str => Str);

   function Write (Item : in Message) return Stream_Element_Array
   is
      Buffer : Types.Bytes_Ptr :=
        new Types.Bytes (1 .. Types.Index (1 + 255));
      Context : Packet.Context;
      Res : Stream_Element_Array(1..256);
      procedure Free is new Ada.Unchecked_Deallocation
        (Types.Bytes, Types.Bytes_Ptr);
   begin
      Packet.Initialize (Context, Buffer);
      Packet.Set_Size (Context, Str_Size (Item.Size));
      if Item.Size /= 0 then
         Packet.Set_Str (Context, [for C of Item.Str => Character'Pos (C)]);
      end if;
      Packet.Take_Buffer (Context, Buffer);
      Res := To_Ada_Stream(Buffer.all);
      Free (Buffer);
      return Res;
   end Write;
   -- https://stackoverflow.com/a/22770989

   function Read
     (Buffer : in Stream_Element_Array; Last : in Stream_Element_Offset )
      return Message
   is
      Context : Packet.Context;

      procedure Free is new Ada.Unchecked_Deallocation
        (Types.Bytes, Types.Bytes_Ptr);
   begin
      declare
         Bytes_Buffer : Types.Bytes_Ptr := new Types.Bytes'(To_RFLX_Bytes(Buffer(1..Last)));
         Size : constant Byte :=  Bytes_Buffer.all(1);
      begin
      if Size = 0 then
         return (Size => 0, Str => "");
      end if;
         -- Ada.Text_IO.Put_Line("BYTES_BUFFER: " & Bytes_Buffer.all'Image);
         Packet.Initialize (Context, Bytes_Buffer, Written_Last => 8 + Bit_Length(8 * Size));
         Packet.Verify_Message (Context);
         -- Ada.Text_IO.Put_Line("PACKET: " & Context'Image);
         pragma Assert (Packet.Structural_Valid_Message (Context));
         declare
            Size1 : constant Message_Size_Type := Message_Size_Type(Size);
            Str_Bytes : Types.Bytes (1.. Types.Index(Size1));
         begin
            Packet.Get_Str (Context, Str_Bytes);
            Free (Bytes_Buffer);
            -- Ada.Text_IO.Put_Line("STR_BYTES: " & Str_Bytes'Image);
            return (Size => Size1, Str => [for C of Str_Bytes => Character'Val (C)]);
            -- NOTE: Returning to the Secondary Stack.
            -- https://docs.adacore.com/gnat_ugx-docs/html/gnat_ugx/gnat_ugx/the_stacks.html
         end;
     end;
   end Read;
end Libekho;
