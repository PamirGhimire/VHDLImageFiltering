library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Xilinx primitives:
--library UNISIM;
--use UNISIM.VComponents.all;

entity pixelAverager is
	generic(busWidth : integer := 8);
	port(
		pa : in std_logic_vector(busWidth-1 downto 0);
		pb : in std_logic_vector(busWidth-1 downto 0);
		pc : out std_logic_vector(busWidth-1 downto 0);
		
		clk : in std_logic
	);

end pixelAverager;

architecture Behavioral of pixelAverager is
	signal pa_temp : std_logic_vector(8 downto 0) := (others => '0');
	signal pb_temp : std_logic_vector(8 downto 0) := (others => '0');
	signal pc_temp : std_logic_vector(8 downto 0) := (others => '0');
begin

averagingProcess : process(pa, pb, clk)
begin
	pa_temp(8 downto 8) <= "0";
	pb_temp(8 downto 8) <= "0";

	pa_temp(7 downto 0) <= pa;
	pb_temp(7 downto 0) <= pb;
	
	-- add the two inputs
	pc_temp <= pa_temp + pb_temp;
	
	-- assign to output sum/2
	pc <= pc_temp(8 downto 1);
		
end process;

end Behavioral;

