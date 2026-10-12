pragma SPARK_Mode (On);

package PJay_Latin_Lexer is

   type Byte is mod 256;

   Max_Vocab : constant := 67_108_864;

   subtype Index_Type is Positive range 1 .. Max_Vocab;
   subtype Length_Type is Natural  range 0 .. Max_Vocab;

   type Byte_Array is array (Index_Type range <>) of Byte;

   --  Latinská sémantika PJay (IV. Fénixův řád)
   type Vox_Latina is
     (VOX_NIHIL,        --  Nulový stav (prázdno)
      VOX_IMPERIUM,     --  Příkaz / Instrukce
      VOX_AURUM,        --  Hodnota / Zástava / Mincovna
      VOX_SIGILLUM,     --  Pečeť / Trezor / Podpis
      VOX_CUSTOS,       --  Strážce / SPARKdog
      VOX_CREMATIO,     --  Spálení / Ash Sweeper (04:23)
      VOX_VACUUM,       --  Izolované prostředí
      VOX_VERITAS,      --  Pravda (True)
      VOX_FALSUM,       --  Lež (False)
      VOX_NUMERUS,      --  Číslo / Množství
      VOX_ERROR);       --  Odchylka / Chyba

   type Verbum is record
      Signum : Vox_Latina;
      Initio : Index_Type;
      Finis  : Length_Type;
   end record;

   procedure Interpretari_Verbum
     (Arena  : Byte_Array;
      Cursor : in out Index_Type;
      Dictum : out Verbum)
   with
     Pre  => Arena'First = 1
             and then Arena'Length > 0
             and then Cursor <= Arena'Last,
     Post => (if Dictum.Signum /= VOX_NIHIL and Dictum.Signum /= VOX_ERROR then
                Dictum.Initio >= Arena'First and Dictum.Finis <= Arena'Last and Dictum.Initio <= Dictum.Finis)
             and Cursor >= Cursor'Old;

end PJay_Latin_Lexer;
