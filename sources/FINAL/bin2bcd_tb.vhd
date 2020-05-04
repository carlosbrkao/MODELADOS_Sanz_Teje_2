
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity bin2bcd_tb is
end bin2bcd_tb;

architecture sim of bin2bcd_tb is
    --COMPONENTES
    component bin2bcd
        port (
            CLK : in std_logic;
            RST : in std_logic;
            DATA_OK : in  std_logic;
            DATA : in std_logic_vector(11 downto 0);
            BCD_OK     : out std_logic;
            BCD : out std_logic_vector(15 downto 0));
    end component;
    
     signal RELOJ : std_logic := '0';
     signal RESET : std_logic := '1';
     signal DATA_BUENO : std_logic_vector(11 downto 0);
     signal DATA_OK_BUENO :  std_logic := '0';
     signal BCD_OK_BUENO     :  std_logic;
     signal BCD_BUENO :  std_logic_vector(15 downto 0);

begin
    DUT: bin2bcd
        port map(
            CLK => RELOJ,
            RST => RESET,
            DATA_OK => DATA_OK_BUENO,
            DATA => DATA_BUENO,            
            BCD_OK => BCD_OK_BUENO,
            BCD => BCD_BUENO);
    --Se pone la señal de reset (rst) a bajo nivel a los 123ns       
    RESET <= '0' after 123 ns;
    --Se aplica una señal de reloj de 10ns de período
    RELOJ <= NOT RELOJ after 5 ns;
    
     --NUEVOS DATOS
       process
       begin
           --Esperamos 200ns
           wait for 200ns;
           --Cargamos un nuevo valor "1999"
           DATA_BUENO <= "011111001111";
           --Esperamos al flanco de bajada
           wait until RELOJ = '0';
           --Cargamos que hay nuevo valor (se pulsa boton)
           DATA_OK_BUENO <= '1';
           --Esperamos al flanco de bajada
           wait until RELOJ = '0';
           --Desactivamos que hay nuevo valor (no se pulsa boton)
           DATA_OK_BUENO <= '0';
           --Esperamos 10 ms
           wait for 10 ms;
           --Cargamos un nuevo valor "0"
           DATA_BUENO <= "000000000000";
           --Esperamos al flanco de bajada
           wait until RELOJ = '0';
           --Cargamos que hay nuevo valor (se pulsa boton)
           DATA_OK_BUENO <= '1';
           --Esperamos al flanco de bajada
           wait until RELOJ = '0';
           --Desactivamos que hay nuevo valor (no se pulsa boton)
           DATA_OK_BUENO <= '0';
           --Esperamos 10 ms
           wait for 10 ms;
           report "fin controlado d ela simulación" severity failure;
       end process;
    
    

end sim;
