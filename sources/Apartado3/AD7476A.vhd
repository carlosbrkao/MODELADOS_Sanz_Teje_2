library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity AD7476A is

  port (
    VIN   : in  real range 0.0 to 3.5;
    CS    : in  std_logic;
    SCLK  : in  std_logic;
    SDATA : out std_logic);
end AD7476A;
architecture rtl of AD7476A is

  signal   dato   : std_logic_vector(15 downto 0) := (others => '0');
  signal   cuenta : natural;
 
  constant t3     : time                          := 20 ns;
  constant t4     : time                          := 40 ns;
  constant t7     : time                          := 7 ns;
  constant t8     : time                          := 25 ns;

begin

-- Modelado de funcionamiento.
  process ( CS)
    variable aux : std_logic_vector(11 downto 0):= (others => '0');
  begin
    if CS'event and CS = '0' then
      if VIN > 3.3 then
        aux := (others => '1');
      elsif VIN < 0.0 then
        aux := (others => '0');
      else
        aux := std_logic_vector(to_unsigned(integer((4095.0*VIN)/3.3), 12));
      end if;
       dato <= "0000"&aux;
    end if;
   
  end process;


  process (SCLK, CS)
  begin
    if CS = '1' then
      cuenta <= 0;
    elsif SCLK'event and SCLK = '0' then
      cuenta <= cuenta+1;
    end if;
  end process;

  process (cuenta, CS)
  begin
    if CS = '0' then
      if cuenta = 0 then
        SDATA <= '0' after t3;
      elsif cuenta < 16 then
        SDATA <= '-' after t7, dato(15-cuenta)after t4 ;
      else
        SDATA <= 'Z'after t8;
      end if;
    else
      SDATA   <= 'Z';
    end if;
  end process;


end rtl;
