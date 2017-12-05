library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity writecontrolstatemachine is
	port(
		clk : in std_logic;
		en : in std_logic;
		
		write2file : out std_logic
	);

end writecontrolstatemachine;

architecture writectrl_arch of writecontrolstatemachine is
	signal colcounter : std_logic_vector(6 downto 0) := "0000000";
	signal rowcounter : std_logic_vector(6 downto 0) := "0000000";
begin

writecontrolprocess : process(clk, en)
begin

   --if rising clock and enabled
	if (rising_edge(clk) and en = '1') then

		if (rowcounter < "1111111") then 
			-- increment the col counter
			colcounter <= std_logic_vector(unsigned(colcounter) + 1) ; 

			-- if colcounter <= N-(D-1), can write to file
			if (colcounter <= "1111110" ) then
					write2file <= '1';
			else
					write2file <= '0';
			end if;
		
			-- after counting N-(D-1), increment col counter
			if (colcounter >= "1111110") then
				rowcounter <= std_logic_vector(unsigned(rowcounter) + 1) ; 
			end if;

			-- write2file for N-(D-1) rows
			if(rowcounter > "1111110") then 
				write2file <= '0';				
			end if;
			
			if (colcounter = "1111111") then
				colcounter <= "0000000";
			end if;
			
		end if;
	end if;
	
end process;
end writectrl_arch;

