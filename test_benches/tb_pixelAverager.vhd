--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:58:25 11/29/2017
-- Design Name:   
-- Module Name:   /home/pamir/Desktop/vhdl_MSCV_M2/projects/imFilteringUsingVhdl/tb_pixelAverager.vhd
-- Project Name:  fifo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: pixelAverager
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_pixelAverager IS
END tb_pixelAverager;
 
ARCHITECTURE behavior OF tb_pixelAverager IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT pixelAverager
    PORT(
         pa : IN  std_logic_vector(7 downto 0);
         pb : IN  std_logic_vector(7 downto 0);
         pc : OUT  std_logic_vector(7 downto 0);
         clk : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal pa : std_logic_vector(7 downto 0) := (others => '0');
   signal pb : std_logic_vector(7 downto 0) := (others => '0');
   signal clk : std_logic := '0';

 	--Outputs
   signal pc : std_logic_vector(7 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: pixelAverager PORT MAP (
          pa => pa,
          pb => pb,
          pc => pc,
          clk => clk
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for clk_period*10;

      -- insert stimulus here 
		pa <= "00000011";
		pb <= "00000010";
		wait for clk_period*10;
		
		pa <= "11111111";
		pb <= "11111111";
		wait for clk_period*10;

		pa <= "00000011";
		pb <= "00000100";
		wait for clk_period*10;

		pa <= "00000011";
		pb <= "00000101";
		wait for clk_period*10;

		pa <= "00000111";
		pb <= "00000010";
		wait for clk_period*10;
		
      wait;
   end process;

END;
