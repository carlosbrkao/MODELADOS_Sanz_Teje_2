

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;



entity voltimetro_tb is

end voltimetro_tb;

architecture sim of voltimetro_tb is
    component voltimetro
       port (
       CLK    : in  std_logic;
       RST    : in  std_logic;
       SDATA  : in  std_logic;
       CS     : out std_logic;
       SCLK   : out std_logic;
       AND_30 : out std_logic_vector(3 downto 0);
       DP     : out std_logic;
       SEG_AG : out std_logic_vector(6 downto 0));
    end component;
    
    
    component AD7476A
        port (
          VIN   : in  real range 0.0 to 3.5;
          CS    : in  std_logic;
          SCLK  : in  std_logic;
          SDATA : out std_logic);
      end component;
    
   signal CLK_aux         : std_logic :='0';
   signal RST_aux         : std_logic :='1';
    
   signal SDATA_aux       : std_logic;
   signal CS_aux          : std_logic;
   signal SCLK_aux        : std_logic;
   signal AND_30_aux      : std_logic_vector(3 downto 0);
   signal DP_aux          : std_logic;
   signal SEG_AG_aux      : std_logic_vector(6 downto 0);
   
   signal VOLTAJE         : real range 0.0 to 3.5; 
   
   
   signal D_Display_Aux : std_logic_vector(3 downto 0);
          
   signal BCD_U : std_logic_vector(3 downto 0);
   signal BCD_D : std_logic_vector(3 downto 0);
   signal BCD_C : std_logic_vector(3 downto 0);
   signal BCD_M : std_logic_vector(3 downto 0);
           
   signal D_Display : std_logic_vector(15 downto 0);
begin

   DUT : AD7476A
    port map (
      VIN     => VOLTAJE,
      CS       => CS_aux,
      SCLK  => SCLK_aux,
      SDATA => SDATA_aux);
      
    
   DAT : voltimetro
       port map (
         CLK     => CLK_aux,
         RST       => RST_aux,
         SCLK  => SCLK_aux,
         SDATA => SDATA_aux,
         CS=> CS_aux,
         AND_30 => AND_30_aux,
         DP => DP_aux,
         SEG_AG => SEG_AG_aux);    


 RST_AUX   <= '0' after 123 ns;
  CLK_aux <= not CLK_aux after 5 ns;

  process
  begin  -- process
  
    wait for 200ns;
    VOLTAJE <= 3.500;
    wait for 20 ms;
    
    
    
    
    report "fin controlado d ela simulación" severity failure;
  end process;
  
  --SEGMENTOS A BIN-------------------------------------------------------------
      process(SEG_AG_aux,AND_30_aux)
          Variable Display_Bin : std_logic_vector(3 downto 0);
      begin
          case SEG_AG_aux is
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
              when "0111111"=>
                  Display_Bin := "1111";--central
              when others =>    
          end case;
          --Escribimos el valor a mostrar del display                
          D_Display_Aux<=Display_bin;              
      end process;
  
      process (D_Display_Aux,AND_30_aux)
      begin
          case AND_30_aux is
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
              when "0111" =>
                  BCD_M <= D_Display_Aux;
              when others =>
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
