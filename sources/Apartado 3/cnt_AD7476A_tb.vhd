-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity cnt_AD7476A_tb is

end cnt_AD7476A_tb;

-------------------------------------------------------------------------------

architecture sim of cnt_AD7476A_tb is

  component AD7476A
    port (
      VIN   : in  real range 0.0 to 3.5;
      CS    : in  std_logic;
      SCLK  : in  std_logic;
      SDATA : out std_logic);
  end component;


  component cnt_AD7476A
    port (
    CLK     : in  std_logic;
    RST     : in  std_logic;
    SDATA   : in  std_logic;
    CS      : out std_logic;
    SCLK    : out std_logic;
    DATA    : out std_logic_vector(11 downto 0);
    DATA_OK : out std_logic);
  end component;

  signal VOLTAJE     : real range 0.0 to 3.5;
  signal DATA_aux       : std_logic_vector(11 downto 0);
  signal DATA_OK_aux    : std_logic;
  signal CLK_aux         : std_logic :='0';
  signal RST_aux         : std_logic :='1';
  
  signal SDATA_aux   : std_logic;
  signal CS_aux      : std_logic;
  signal SCLK_aux    : std_logic; 
  

begin  -- sim

  DUT : AD7476A
    port map (
      VIN     => VOLTAJE,
      CS       => CS_aux,
      SCLK  => SCLK_aux,
      SDATA => SDATA_aux);

  DAT : cnt_AD7476A
    port map(
        CLK=> CLK_aux,
        RST=> RST_aux,
        SDATA=> SDATA_aux,
        CS=> CS_aux,
        SCLK=> SCLK_aux,
        DATA=> DATA_aux,
        DATA_OK=> DATA_OK_aux);
    
  
  
  
  RST_AUX   <= '0' after 123 ns;
  CLK_aux <= not CLK_aux after 5 ns;

  process
  begin  -- process

    VOLTAJE <= 3.500;
    wait for 10 ms;
    report "fin controlado d ela simulación" severity failure;
  end process;


end sim;
