with Ada.Streams;

package Libekho is
    subtype Message_Size_Type is Integer range 0 .. 255;

    type Message (Size : Message_Size_Type) is record
        Str : String (1 .. Size);
    end record with
        Write => Write;

    type Message_Access is access Message;

    function To_Message (Str : in String) return Message with
        Pre => Str'Length in Message_Size_Type;

    procedure Write
       (Stream :    not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : in Message);

    function Read
       (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
        return Message;
end Libekho;
