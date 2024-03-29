with Ada.Streams; use Ada.Streams;

package Libekho is
   subtype Message_Size_Type is Integer range 0 .. 255;

   type Message (Size : Message_Size_Type) is record
      Str : String (1 .. Size);
   end record;

   type Message_Access is access Message;

   function To_Message (Str : in String) return Message with
      Pre => Str'Length in Message_Size_Type;

   function Write (Item : in Message) return Stream_Element_Array;

   function Read
     (Buffer : in Stream_Element_Array; Last : in Stream_Element_Offset)
      return Message;
end Libekho;
