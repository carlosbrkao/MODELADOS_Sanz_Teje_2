library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
entity bin2bcd is
  port( clk     : in  std_logic;
        rst     : in  std_logic;
        DATA_OK : in  std_logic;
        DATA    : in  std_logic_vector( 11 downto 0);
        BCD_OK  : out std_logic;
        BCD     : out std_logic_vector( 15 downto 0));
end bin2bcd;
architecture rtl of bin2bcd is
--SEÑALES CONTADOR BINARIO
signal cnt_bin_out : unsigned(11 downto 0);
--SEÑALES CONTADOR BCD
signal BCD_U : unsigned(3 downto 0);
signal BCD_D : unsigned(3 downto 0);
signal BCD_C : unsigned(3 downto 0);
signal BCD_M : unsigned(3 downto 0);
--SEÑALES GENERADOR BCD_OK
signal Q : std_logic;
signal aux : std_logic;
------------------------------------------------------------------------CODIGO---------------------------------------
begin
    --CONTADOR BINARIO DE 12bits DESCENDENTE CON CARGA PROGRAMABLE
    process (clk, rst, DATA_OK, DATA)
    begin
        if (rst = '1') then
            cnt_bin_out <= (others => '0');
        elsif (clk'event and clk = '1')then
            if DATA_OK = '1' then
                cnt_bin_out <= unsigned(DATA);
            elsif  NOT (cnt_bin_out = 0) then
                cnt_bin_out <= cnt_bin_out - 1;
            end if;
        end if;
    end process;
    --CONTADOR BCD DE 4 DIGITOS ASCENDENTE
    process (clk, rst, DATA_OK,cnt_bin_out)
    begin
        if rst = '1' then
            BCD_U <= (others => '0');
            BCD_D <= (others => '0');
            BCD_C <= (others => '0');
            BCD_M <= (others => '0');
        elsif clk'event and clk = '1' then
            if DATA_OK = '1' then
                BCD_U <= (others => '0');
                BCD_D <= (others => '0');
                BCD_C <= (others => '0');
                BCD_M <= (others => '0');
            elsif NOT (cnt_bin_out = 0) then
                if BCD_U = 9 then
                    BCD_U <= (others => '0');
                    if BCD_D = 9 then
                        BCD_D <= (others => '0');
                        if BCD_C = 9 then
                            BCD_C <= (others => '0');
                            BCD_M <= BCD_M + 1;
                        else
                            BCD_C <= BCD_C + 1;
                        end if;
                    else
                        BCD_D <= BCD_D + 1;
                    end if;
                else
                    BCD_U <= BCD_U + 1;
                end if;
            end if;
        end if;
    end process;
    --REGISTRO DE 16bits
    process(clk,rst,cnt_bin_out,BCD_U,BCD_D,BCD_C,BCD_M)
    begin
        --Si la se�al de reset esta activa se pone todo a 0
        if rst = '1' then
          BCD <= (others => '0');
        elsif clk'event and clk = '1' then
          --Si la se�al cnt_bin_out es igual a 0 se combina las cifras en el BCD
          if(cnt_bin_out = 0)then
            --Troceamos BCD
            BCD(3 downto 0) <= std_logic_vector(BCD_U(3 downto 0));
            BCD(7 downto 4) <= std_logic_vector(BCD_D(3 downto 0));
            BCD(11 downto 8) <= std_logic_vector(BCD_C(3 downto 0));
            BCD(15 downto 12) <= std_logic_vector(BCD_M(3 downto 0));
          end if;
        end if;
     end process;
     --GENERADOR DE BCD_OK
     process(clk,rst,cnt_bin_out,DATA_OK)
     begin
        if rst = '1' then
            BCD_OK <= '0';
        elsif clk'event and clk = '1' then
            if DATA_OK = '1' then
                Q <= '0';
            elsif cnt_bin_out = 0 then
                Q <= '1';
            end if;
            aux <= Q;
            BCD_OK <= (NOT aux) AND Q;
        end if;
     end process;
end rtl;

