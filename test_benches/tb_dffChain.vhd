LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

use std.textio.all;
use ieee.std_logic_textio.all;
 
ENTITY tb_dffChain IS
END tb_dffChain;
 
ARCHITECTURE behavior OF tb_dffChain IS 
 
    -- Component Declaration for the Unit Under Test (UUT) 
	 -- UUT = CACHE MEMORY
    COMPONENT DffChain
    PORT(
         d : IN  std_logic_vector(7 downto 0);
         en : IN  std_logic;
         clk : IN  std_logic;
         q : OUT  std_logic_vector(7 downto 0);
			
		-- ports for observing fifos
		pfull_f1 : out std_logic;
		pfull_f2 : out std_logic;
		-- port for observing how many pixels have been read
		pixcounter : out std_logic_vector(13 downto 0);
		-- common reset 
		rst : in std_logic;
		-- common write enable 
		wr_en_f1 : in std_logic;
		wr_en_f2 : in std_logic;
		-- read enables
		rd_en_f1 : in std_logic;
		rd_en_f2 : in std_logic;
		-- common prog. full threshold
		prog_full_thresh : in std_logic_vector(9 downto 0)
     );
    END COMPONENT;
    

   --TEST BENCH : Inputs
   signal d : std_logic_vector(7 downto 0) := (others => '0');
	
   signal en : std_logic := '0';
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	
	signal wr_en_f1 : std_logic := '0';
	signal wr_en_f2 : std_logic := '0';
	
	signal rd_en_f1 : std_logic := '0';
	signal rd_en_f2 : std_logic := '0';
	
	signal prog_full_thresh : std_logic_vector(9 downto 0) := "0000000000";

 	--TEST BENCH : Outputs
   signal q : std_logic_vector(7 downto 0) := "00000000";
	signal pfull_f1 : std_logic := '0';
	signal pfull_f2 : std_logic := '0';
	signal pixcounter : std_logic_vector(13 downto 0) := "00000000000000";

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
 	shared variable pixel : std_logic_vector(7 downto 0) := "00000000";

BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
	-- UUT = CACHE MEMORY
   uut: DffChain PORT MAP (
          -- input
			 d => d,
			 
			 -- control signals
			 en => en,
          clk => clk,
 			 rst => rst,

			rd_en_f1 => rd_en_f1,
			rd_en_f2 => rd_en_f2,
			
			wr_en_f1 => wr_en_f1, 
			wr_en_f2 => wr_en_f2, 
			prog_full_thresh => prog_full_thresh,
			 
			 -- observables
          q => q,
			 pixcounter => pixcounter,
			 pfull_f1 => pfull_f1,
			 pfull_f2 => pfull_f2 
        );

   -- Clock process definitions
--   clk_process :process
--   begin
--		clk <= '0';
--		wait for clk_period/2;
--		clk <= '1';
--		wait for clk_period/2;
--   end process;
 

   -- Stimulus process, read data from a file and feed it into the pipeline
   stim_proc: process
		-- variables for the stimulus process
	 
	 -- READ:
	  FILE data : text;
	  variable sample : line;
	  -- WRITE:
	  file dataout : text;
	  variable sampleout : line;
	 
	  
   begin		
		rst <='1';
		en <= '0';
		
		rd_en_f1 <= '0';
		rd_en_f2 <= '0';
		
		prog_full_thresh <= "0001111101"; -- 128-3=125
      
		-- hold reset state for 100 ns.
     wait for 100 ns;	
		en <= '1';
		rst <= '0';
		wr_en_f1 <= '1';
		wr_en_f2 <= '0';
		
		wait for 20 ns;
		
		 file_open (data,"Lena128x128g_8bits.dat", read_mode);
		 file_open (dataout,"Lena128x128g_8bits_out.dat", write_mode);

		 while not endfile(data) loop
			readline (data,sample);
			read (sample, pixel);
			d <= pixel;
			
			
			-- toggle the clock
			-- input on din is read on rising_edge(clk)
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
			-- end of clock toggle
	
			-- if 128 pixels have been read, read enable fifo1
			if (pfull_f1 = '1' and pixcounter >= "00000010000000") then
					rd_en_f1 <= '1';
					wr_en_f2 <= '1';
			end if;
			
			-- if 128x2 = 256 pixels have been read, read enable fifo2
			if (pfull_f2 = '1' and pixcounter >= "00000100000011") then
					rd_en_f2 <= '1';
					write(sampleout, q);
					writeline(dataout, sampleout);
			end if;
			
			
		 end loop;
		 
		 file_close (data);
		 file_close(dataout);
		 wait;
		end process;

END;




