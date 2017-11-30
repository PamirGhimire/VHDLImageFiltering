-- libraries 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity dGenFlipFlop is
generic (busWidth : integer := 8);
	port(d : in std_logic_vector(busWidth-1 downto 0);
		  q : out std_logic_vector(busWidth-1 downto 0);
		  clk : in std_logic;
		  en : in std_logic
	);
end dGenFlipFlop;

architecture arch of dGenFlipFlop is
begin
p1 : process(d, clk, en)
begin
if (en = '1') then
	if (rising_edge(clk)) then
		q <= d;
		end if;
		
else
	q <= (others => '0');
end if;
	
end process;



end arch;

