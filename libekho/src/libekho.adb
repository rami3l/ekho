with Ada.Streams;

package body Libekho is
    procedure Write
       (Stream :    not null access Ada.Streams.Root_Stream_Type'Class;
        Item   : in Message)
    is
    begin
        Message_Size_Type'Write (Stream, Item.Size);
        if Item.Size /= 0 then
            declare
                Data :
                   Data_T (1 .. Item.Size) renames Item.Str (1 .. Item.Size);
            begin
                Data_T'Write (Stream, Data);
            end;
        end if;
    end Write;
-- https://stackoverflow.com/a/22770989
end Libekho;
