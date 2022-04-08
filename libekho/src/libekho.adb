with Ada.Streams;

package body Libekho is
    function To_Message (Str : in String) return Message is
        Len : Message_Size_Type := Str'Length;
    begin
        return (Size => Len, Str => Str);
    end To_Message;

    procedure Write
       (Stream :    not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : in Message)
    is
    begin
        Message_Size_Type'Write (Stream, Item.Size);
        if Item.Size /= 0 then
            String'Write (Stream, Item.Str);
        end if;
    end Write;
    -- https://stackoverflow.com/a/22770989

    procedure Read
       (Stream :     not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : out Message)
    is
        Size : Message_Size_Type;
    begin
        Message_Size_Type'Read (Stream, Size);
        if Size /= 0 then
            declare
                Str : String (1 .. Size);
            begin
                String'Read (Stream, Str);
                Item.Str := Str;
            end;
        end if;
    end Read;

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
        end;
    end Read;
end Libekho;
