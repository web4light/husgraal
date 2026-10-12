pragma SPARK_Mode (On);

package body PJay_Latin_Lexer is

   function Est_Spatium (B : Byte) return Boolean
     is (B in 16#20# | 16#09# | 16#0A# | 16#0D#);

   procedure Interpretari_Verbum
     (Arena  : Byte_Array;
      Cursor : in out Index_Type;
      Dictum : out Verbum)
   is
      Start_Pos : constant Index_Type := Cursor;
      B         : Byte;
   begin
      Dictum := Verbum'(Signum => VOX_NIHIL, Initio => Cursor, Finis => 0);

      while Cursor < Arena'Last and then Est_Spatium (Arena (Cursor)) loop
         Cursor := Cursor + 1;
         pragma Loop_Invariant (Cursor in Arena'Range);
         pragma Loop_Invariant (Cursor >= Start_Pos);
      end loop;

      if Est_Spatium (Arena (Cursor)) then
         pragma Assert (Cursor >= Start_Pos);
         return;
      end if;

      Dictum.Initio := Cursor;
      B             := Arena (Cursor);

      --  Rozpoznání sémantických latinských kořenů (ASCII znaky)
      case B is
         when 16#49# | 16#69# => -- 'I' / 'i' (Imperium)
            Dictum.Signum := VOX_IMPERIUM;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#41# | 16#61# => -- 'A' / 'a' (Aurum)
            Dictum.Signum := VOX_AURUM;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#53# | 16#73# => -- 'S' / 's' (Sigillum)
            Dictum.Signum := VOX_SIGILLUM;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#43# | 16#63# => -- 'C' / 'c' (Crematio / Custos)
            Dictum.Signum := VOX_CREMATIO;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;

         when 16#56# | 16#76# => -- 'V' / 'v' (Veritas / Vacuum)
            Dictum.Signum := VOX_VERITAS;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;

         when others =>
            Dictum.Signum := VOX_NUMERUS;
            Dictum.Finis  := Cursor;
            if Cursor < Arena'Last then
               Cursor := Cursor + 1;
            end if;
      end case;

      pragma Assert (Cursor >= Start_Pos);
   end Interpretari_Verbum;

end PJay_Latin_Lexer;
