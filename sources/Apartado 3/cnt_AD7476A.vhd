library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cnt_AD7476A is
  port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    SDATA   : in  std_logic;
    CS      : out std_logic;
    SCLK    : out std_logic;
    DATA    : out std_logic_vector(11 downto 0);
    DATA_OK : out std_logic);
end cnt_AD7476A;

architecture RTL of cnt_AD7476A is
--cosas preescaler
constant CLKDIV      : integer := 8;
signal   counter_reg : integer range 0 to CLKDIV-1;
signal   CE_SCLK     : std_logic;
--cosas emisor
signal   SCLK_aux    : std_logic;
--cosas conversor
signal   DATA_aux    : std_logic_vector( 11 downto 0);
signal   contadorI   : unsigned(3 downto 0);
signal   contadorJ   : unsigned(2 downto 0);
begin  -- RTL
    -------------------------------------------------------------------------------------------------RELOJ SCLK
   --PREESCALER DIV_CLK---------------------------------------------------
   process (CLK, RST)
   begin 
    --Si la señal de reset esta activa se reinicia la creación de pulsos de 1ms
     if RST = '1' then
       counter_reg   <= 0;
     elsif CLK'event and CLK = '1' then
       --Si se supera el tiempo para el pulso se reinicia para uno nuevo
       if counter_reg = CLKDIV-1 then
         counter_reg <= 0;
       --Si aun no se ha llegado al tiempo para el pulso, se incrementa el contador
       else
         counter_reg <= counter_reg+1;
       end if;
     end if;
   end process;
   --Se emite el pulso cuando se ha contado el paso de 80 nanosegundo
   CE_SCLK <= '1' when counter_reg = CLKDIV-1 else '0'
   --EMISOR SLCK (CONTADOR 1bit)
   process (CLK, RST, CE_SCLK)
   begin
       --Si la señal de reset esta activa se reinicia el contador a 0
       if (RST = '1') then
         SCLK <= '0';
       elsif (CLK'event and CLK = '1')then
         --Si hemos recibido un nuevo pulso se cambia el estado de la señal
         if (CE_SCLK = '1') then
             SCLK_aux <= NOT SCLK_aux;
             SCLK <= SCLK_aux;
         end if;
       end if;
   end process;
   -----------------------------------------------------------------------------------------------FIN SCLK
   --CONVERSOR A BINARIO-------------------------------------------------
   process (CLK,RST,SDATA,SCLK)
   begin
     if (RST = '1') then
            DATA <= (others => '0');
            DATA_OK <= '0';
            CS <= '0';
            contadorI <= (others => '0');
            contadorJ <= (others => '0');
     elsif (CLK'event and CLK = '1')then
        if(contadorI = "0000") then
            DATA_aux(0) <= SDATA;
            contadorI <= contadorI + 1;
        elseif(contadorI = "1111") then
            if(contadorJ = "111") then
                DATA_aux(0) <= SDATA;
                DATA_aux <= DATA_aux(10 downto 0) & '0';
                contadorJ <= contadorJ + 1;
            else
                contadorJ <= contadorJ + 1;
            end if;
        else
            if(contadorJ = "111") then
               DATA_aux(0) <= SDATA;
               DATA_aux <= DATA_aux(10 downto 0) & '0';
               contadorJ <= contadorJ + 1;
            else
               contadorJ <= contadorJ + 1;
            end if;
        end if;
     end if;
   end process;
end RTL;
