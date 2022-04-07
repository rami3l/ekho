with Ada.Streams;

package Libekho is
    subtype Message_Size_Type is Integer range 0 .. 255;

    type Message (Size : Message_Size_Type) is record
        case Size is
            when 0 =>
                null;
            when others =>
                Str : String (1 .. Size);
        end case;
    end record with
        Write => Write;

    procedure Write
       (Stream :    not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : in Message);
end Libekho;
