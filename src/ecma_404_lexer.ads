pragma SPARK_Mode (On);

package ECMA_404_Lexer is

   type Byte is mod 256;

   Max_Buffer : constant := 67_108_864; -- 64 MiB

   subtype Buffer_Index is Positive range 1 .. Max_Buffer;
   subtype Buffer_Count is Natural  range 0 .. Max_Buffer;

   type Byte_Array is array (Buffer_Index range <>) of Byte;

   type Token_Kind is
     (Token_None,
      Token_Object_Start,
      Token_Object_End,
      Token_Array_Start,
      Token_Array_End,
      Token_Colon,
      Token_Comma,
      Token_String,
      Token_Number,
      Token_Error);

   type Token is record
      Kind  : Token_Kind;
      Start : Buffer_Index;
      Stop  : Buffer_Count;
   end record;

   function Is_Whitespace (B : Byte) return Boolean
     is (B in 16#20# | 16#09# | 16#0A# | 16#0D#);

   procedure Scan_Next_Token
     (Buffer : Byte_Array;
      Cursor : in out Buffer_Index;
      Tok    : out Token)
   with
     Pre  => Buffer'First = 1
             and then Buffer'Length > 0
             and then Cursor <= Buffer'Last,
     Post => (if Tok.Kind /= Token_None and Tok.Kind /= Token_Error then
                Tok.Start >= Buffer'First and Tok.Stop <= Buffer'Last and Tok.Start <= Tok.Stop)
             and Cursor >= Cursor'Old;

end ECMA_404_Lexer;
