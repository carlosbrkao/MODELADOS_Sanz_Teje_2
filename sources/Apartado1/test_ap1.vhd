library ieee;
use ieee.std_logic_1164.all;


entity test_ap1 is
  port (
    CLK    : in  std_logic;
    RST    : in  std_logic;
    SW_OK  : in  std_logic;
    SW     : in  std_logic_vector(15 downto 0);
    AND_30 : out std_logic_vector(3 downto 0);
    DP     : out std_logic;
    SEG_AG : out std_logic_vector(6 downto 0));
end test_ap1;

architecture RTL of test_ap1 is
  signal Q      : std_logic;
  signal BCD_OK : std_logic;
 
begin  -- RTL

  process (CLK, RST)
  begin
    if RST = '1' then
      Q      <= '0';
      BCD_OK <= '0';
    elsif CLK'event and CLK = '1' then
      Q      <= SW_OK;
      BCD_OK <= (not Q) and SW_OK;
    end if;
  end process;


  U_cnt_display : entity work.cnt_display
    port map (
      CLK    => CLK,
      RST    => RST,
      BCD_OK => BCD_OK,
      BCD    => SW,
      AND_30 => AND_30,
      DP     => DP,
      SEG_AG => SEG_AG);
end RTL;
