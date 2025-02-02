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
constant CLKDIV      : integer := 13334;
signal   counter_reg : integer range 0 to CLKDIV-1;
signal   CE_SCLK     : std_logic;
--cosas emisor
signal   SCLK_aux    : std_logic;
--cosas conversor
signal   DATA_aux    : std_logic_vector( 11 downto 0);
signal   contadorI   : unsigned(3 downto 0);
signal   contadorJ   : unsigned(2 downto 0);

---Se�ales prueba 300 mil millones
signal fBajada : std_logic;
constant desp : integer := 400020;
signal desp_counter : integer range 0 to 400020;
signal DATA_OK_aux :std_logic;
---CS
constant CS_L : integer := 440022;
signal CS_L_counter : integer range 0 to CS_L;
signal CS_aux : std_logic;
constant CS_H : integer :=1;
signal CS_H_counter : integer range 0 to CS_H;

----GENERADOR DATA OK
signal Q : std_logic;

begin  -- RTL
    -------------------------------------------------------------------------------------------------RELOJ SCLK
   --PREESCALER DIV_CLK---------------------------------------------------
   process (CLK, RST)
   begin 
    --Si la se�al de reset esta activa se reinicia la creaci�n de pulsos de 1ms
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
   CE_SCLK <= '1' when counter_reg = CLKDIV-1 else '0';
   --EMISOR SLCK (CONTADOR 1bit)
   process (CLK, RST, CE_SCLK)
   begin
       --Si la se�al de reset esta activa se reinicia el contador a 0
       if (RST = '1') then
         SCLK <= '0';
         SCLK_aux <='0';
       elsif (CLK'event and CLK = '1')then
         --Si hemos recibido un nuevo pulso se cambia el estado de la se�al
         if (CE_SCLK = '1') then
             SCLK_aux <= NOT SCLK_aux;
             SCLK <= SCLK_aux;
         end if;
       end if;
   end process;
   -----------------------------------------------------------------------------------------------FIN SCLK
   ----------------------Contador CS y respectiva se�al
   process(CLK,RST)
   begin
        if(RST = '1') then
            CS<='1';
            CS_aux<='1';
        elsif(CLK'event and CLK ='1') then
            if(CS_aux = '1') then
                if(CS_H_counter = CS_H) then
                    CS_H_counter <= 0;
                    CS_aux<='0';
                    CS <='0';
                else
                    CS_H_counter <= CS_H_counter +1;
                end if;
             elsif(CS_aux='0') then
                if(CS_L_counter = CS_L) then
                    CS_L_counter <=0;
                    CS_aux<='1';
                    CS<='1';
                else
                    CS_L_counter <= CS_L_counter + 1;
                end if;             
             end if;             
        end if;
   
   end process;
   
   
   
   
   --CONVERSOR A BINARIO-------------------------------------------------
   process (CLK,RST,SDATA,SCLK_aux)
   begin
     if (RST = '1') then
            desp_counter <= 0;
            DATA_OK_AUX <='0';
            fBajada <='0';
     elsif (CLK'event and CLK = '1')then     
        if(CS_aux = '0') then        
            if(desp_counter < desp) then
                if((desp_counter mod 26668)=0) then
                    DATA_aux <= DATA_aux(10 downto 0) & '0';
                end if;
                DATA_aux(0)<= SDATA;
                desp_counter <= desp_counter + 1;
            elsif(desp_counter = desp) then
               DATA <= DATA_aux;
               DATA_OK_AUX <='1'; 
            end if; 
        elsif(CS_aux = '1') then
            desp_counter <= 0;
            DATA_OK_AUX <='0';           
        end if;
     end if;
   end process;
   
   --Genrador DATA OK------------------------------------------------------
   
   process(CLK,RST,DATA_OK_AUX)
        begin
           if RST = '1' then
               DATA_OK <= '0';
           elsif CLK'event and CLK = '1' then
              Q<=DATA_OK_AUX;
              DATA_OK<=((NOT Q) AND DATA_OK_AUX);
           end if;
        end process;
   
end RTL;
