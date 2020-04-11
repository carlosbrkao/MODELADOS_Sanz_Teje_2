library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_display is
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    BCD    : in  std_logic_vector(15 downto 0);
    BCD_OK : in  std_logic;
    AND_30 : out std_logic_vector(3 downto 0);
    DP     : out std_logic;
    SEG_AG : out std_logic_vector(6 downto 0));
end cnt_display;

architecture rtl of cnt_display is
--cosas registro
signal BCD_U : std_logic_vector(3 downto 0);
signal BCD_D : std_logic_vector(3 downto 0);
signal BCD_C : std_logic_vector(3 downto 0);
signal BCD_M : std_logic_vector(3 downto 0);
--cosas preescaler
constant CLKDIV      : integer := 100000;
signal   counter_reg : integer range 0 to CLKDIV-1;
signal CE_preescaler : std_logic;
--cosas contador
signal S : unsigned(1 downto 0);
--cosas multiplexor
signal S_multiplexor : std_logic_vector(3 downto 0);
--CODIGO----------------------------------------------------------------------
begin  -- rtl
  --PRIMER MÓDULO QUE DIVIDE EL BCD EN 4 
  process(CLK,RST,BCD_OK)
    begin
    if RST = '1' then
      BCD_U <= (others => '0');
      BCD_D <= (others => '0');
      BCD_C <= (others => '0');
      BCD_M <= (others => '0');
    elsif CLK'event and CLK = '1' then

      if(BCD_OK='1')then
        --Troceamos BCD
        BCD_U(3 downto 0) <= BCD(3 downto 0);
        BCD_D(3 downto 0) <= BCD(7 downto 4);
        BCD_C(3 downto 0) <= BCD(11 downto 8);
        BCD_M(3 downto 0) <= BCD(15 downto 12);
      end if;
    end if;
  end process;
  --PREESCALER DIV_CLK---------------------------------------------------
   process (CLK, RST)
   begin 
     if RST = '1' then
       counter_reg   <= 0;
     elsif CLK'event and CLK = '1' then
       if counter_reg = CLKDIV-1 then
         counter_reg <= 0;
       else
         counter_reg <= counter_reg+1;
       end if;
     end if;
   end process;
   CE_preescaler <= '1' when counter_reg = CLKDIV-1 else '0';
  --CONTADOR DE 2BITS-----------------------------------------------------
  process (CLK, RST, CE_preescaler)
  begin
      if (RST = '1') then
        S <= (others => '0');
      elsif (CLK'event and CLK = '1')then
        if (CE_preescaler = '1') then
            S <= S+1;
        end if;
      end if;
  end process;
  --MULTIPLEXOR-----------------------------------------------------------------
  process(S,BCD_U,BCD_D,BCD_C,BCD_M)  
  begin
      case S is
        --unidades
        when "00" =>
            S_multiplexor <= BCD_U;
            AND_30 <= "1110";
            DP <= '1';
        --decenas
        when "01" =>
            S_multiplexor <= BCD_D;
            AND_30 <= "1101";
            DP <= '1';
        --centenas
        when "10" =>
            S_multiplexor <= BCD_C;
            AND_30 <= "1011";
            DP <= '1';
        --millares
        when others =>
            S_multiplexor <= BCD_M;
            AND_30 <= "0111";
            DP <= '0';
       end case;
  end process;
  --BCD A SEGMENTOS-------------------------------------------------------------
  process(S_multiplexor)
  begin
    case S_multiplexor is
        when "0000" =>
            SEG_AG <= "1000000";--0
         when "0001" =>
            SEG_AG <= "1111001";--1
         when "0010" =>
            SEG_AG <= "0100100";--2
         when "0011" =>
            SEG_AG <= "0110000";--3
         when "0100" =>
            SEG_AG <= "0011001";--4
         when "0101" =>
            SEG_AG <= "0010010";--5
         when "0110" =>
            SEG_AG <= "0000010";--6
         when "0111" =>
            SEG_AG <= "1111000";--7
         when "1000" =>
            SEG_AG <= "0000000";--8
         when "1001" =>
            SEG_AG <= "0011000";--9
         when others =>
            SEG_AG <= "0111111";--central
         end case;
  end process;
end rtl;
