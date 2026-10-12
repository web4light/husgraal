pragma SPARK_Mode (On);

package body ECMA_404_Lexer is

   procedure Scan_Next_Token
     (Buffer : Byte_Array;
      Cursor : in out Buffer_Index;
      Tok    : out Token)
   is
      Start_Pos : constant Buffer_Index := Cursor;
      B         : Byte;
   begin
      Tok := Token'(Kind => Token_None, Start => Cursor, Stop => 0);

      while Cursor < Buffer'Last and then Is_Whitespace (Buffer (Cursor)) loop
         Cursor := Cursor + 1;
         pragma Loop_Invariant (Cursor in Buffer'Range);
         pragma Loop_Invariant (Cursor >= Start_Pos);
      end loop;

      if Is_Whitespace (Buffer (Cursor)) then
         pragma Assert (Cursor >= Start_Pos);
         return;
      end if;

      Tok.Start := Cursor;
      B         := Buffer (Cursor);

      case B is
         when 16#7B# =>
            Tok.Kind := Token_Object_Start;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#7D# =>
            Tok.Kind := Token_Object_End;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#5B# =>
            Tok.Kind := Token_Array_Start;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#5D# =>
            Tok.Kind := Token_Array_End;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#3A# =>
            Tok.Kind := Token_Colon;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#2C# =>
            Tok.Kind := Token_Comma;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#22# =>
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
               while Cursor <= Buffer'Last loop
                  pragma Loop_Invariant (Cursor > Tok.Start);
                  pragma Loop_Invariant (Cursor >= Start_Pos);
                  if Buffer (Cursor) = 16#22# and then Buffer (Cursor - 1) /= 16#5C# then
                     Tok.Kind := Token_String;
                     Tok.Stop := Cursor;
                     if Cursor < Buffer'Last then
                        Cursor := Cursor + 1;
                     end if;
                     return;
                  end if;
                  if Cursor < Buffer'Last then
                     Cursor := Cursor + 1;
                  else
                     exit;
                  end if;
               end loop;
            end if;
            Tok.Kind := Token_Error;
            Tok.Stop := Buffer'Last;

         when others =>
            Tok.Kind := Token_Number;
            Tok.Stop := Cursor;
            if Cursor < Buffer'Last then
               Cursor := Cursor + 1;
            end if;
      end case;

      pragma Assert (Cursor >= Start_Pos);
   end Scan_Next_Token;

end ECMA_404_Lexer;
