library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity dffOneBit is
port(d : in std_logic;
		  q : out std_logic;
		  clk : in std_logic;
		  en : in std_logic);
end dffOneBit;

architecture Behavioral of dffOneBit is

begin

p1 : process(d, clk, en)
begin
		if (en = '1') then
			if (rising_edge(clk)) then
				q <= d;
			end if;
		else
				q <= '0';
		end if;
end process;

end Behavioral;

