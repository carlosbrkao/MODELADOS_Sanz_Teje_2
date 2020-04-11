
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity cnt_display_tb is
end cnt_display_tb;


architecture sim of cnt_display_tb is
    --COMPONENTES
    component cnt_display
        port (
            CLK : in std_logic;
            RST : in std_logic;
            BCD    : in  std_logic_vector(15 downto 0);
            BCD_OK : in  std_logic;
            AND_30 : out std_logic_vector(3 downto 0);
            DP     : out std_logic;
            SEG_AG : out std_logic_vector(6 downto 0));
    end component;
    --SEÑALES
    signal RELOJ : std_logic := '0';
    signal RESET : std_logic := '1';
    signal BCD_NUMERO : std_logic_vector(15 downto 0);
    signal BCD_OK_NUMERO :  std_logic := '0';
    signal AND_30_SALIDA_DISPLAY :  std_logic_vector(3 downto 0);
    signal DP_PUNTO     :  std_logic;
    signal SEG_AG_DISPLAY_SELEC :  std_logic_vector(6 downto 0);
    
    signal D_Display_Aux : std_logic_vector(3 downto 0);
   
    signal BCD_U : std_logic_vector(3 downto 0);
    signal BCD_D : std_logic_vector(3 downto 0);
    signal BCD_C : std_logic_vector(3 downto 0);
    signal BCD_M : std_logic_vector(3 downto 0);
    
    signal D_Display : std_logic_vector(15 downto 0);
    
begin

    DUT: cnt_display
        port map(
            CLK => RELOJ,
            RST => RESET,
            BCD => BCD_NUMERO,
            BCD_OK => BCD_OK_NUMERO,
            AND_30 => AND_30_SALIDA_DISPLAY,
            DP => DP_PUNTO,
            SEG_AG => SEG_AG_DISPLAY_SELEC);
    --Se pone la señal de reset (rst) a bajo nivel a los 123ns       
    RESET <= '0' after 123 ns;
    --Se aplica una señal de reloj de 10ns de período
    RELOJ <= NOT RELOJ after 5 ns;
    
    --NUEVOS DATOS BCD
    process
    begin
        --Esperamos 200ns
        wait for 200ns;
        --Cargamos un nuevo valor "1999"
        BCD_NUMERO <= "0001100110011001";
        --Esperamos al flanco de bajada
        wait until RELOJ = '0';
        --Cargamos que hay nuevo valor (se pulsa boton)
        BCD_OK_NUMERO <= '1';
        --Esperamos al flanco de bajada
        wait until RELOJ = '0';
        --Desactivamos que hay nuevo valor (no se pulsa boton)
        BCD_OK_NUMERO <= '0';
        --Esperamos 6 ms
        wait for 6 ms;
        --Cargamos un nuevo valor "0000"
        BCD_NUMERO <= "0000000000000000";
        --Esperamos al flanco de bajada
        wait until RELOJ = '0';
        --Cargamos que hay nuevo valor (se pulsa boton)
        BCD_OK_NUMERO <= '1';
        --Esperamos al flanco de bajada
        wait until RELOJ = '0';
        --Desactivamos que hay nuevo valor (no se pulsa boton)
        BCD_OK_NUMERO <= '0';
        --Esperamos 6 ms
        wait for 6 ms;
        report "fin controlado d ela simulación" severity failure;
    end process;
    
    --SEGMENTOS A BIN-------------------------------------------------------------
    process(SEG_AG_DISPLAY_SELEC,AND_30_SALIDA_DISPLAY)
        Variable Display_Bin : std_logic_vector(3 downto 0);
    begin
        case SEG_AG_DISPLAY_SELEC is
            when  "1000000" => 
                Display_Bin := "0000";--0
            when "1111001" =>
                Display_Bin := "0001";--1
            when "0100100" =>
                Display_Bin := "0010";--2
            when "0110000" =>
                Display_Bin := "0011";--3
            when "0011001" =>
                Display_Bin := "0100";--4
            when "0010010" =>
                Display_Bin := "0101";--5
            when "0000010" =>
                Display_Bin := "0110";--6
            when "1111000" =>
                Display_Bin := "0111";--7
            when "0000000" =>
                Display_Bin := "1000";--8
            when "0011000" =>
                Display_Bin := "1001";--9
            when others =>
                Display_Bin := "1111";--central
        end case;
        --Escribimos el valor a mostrar del display                
        D_Display_Aux<=Display_bin;              
    end process;

    process (D_Display_Aux,AND_30_SALIDA_DISPLAY)
    begin
        case AND_30_SALIDA_DISPLAY is
            --unidades
            when "1110" =>
                BCD_U <= D_Display_Aux;
            --decenas
            when "1101" =>
                BCD_D <= D_Display_Aux;
            --centenas
            when "1011" =>
                BCD_C <= D_Display_Aux;
            --millares
            when others =>
                BCD_M <= D_Display_Aux;
        end case;
    end process;
        
    process (BCD_U,BCD_D,BCD_C,BCD_M)
    begin
        D_Display(3 downto 0) <= BCD_U(3 downto 0);
        D_Display(7 downto 4) <= BCD_D(3 downto 0);
        D_Display(11 downto 8) <= BCD_C(3 downto 0);
        D_Display(15 downto 12) <= BCD_M(3 downto 0);
    end process;
end sim;
