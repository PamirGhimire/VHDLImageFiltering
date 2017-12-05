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
		-- ports for observing control-dff chain
		ctrldffchain : out std_logic_vector(18 downto 0);
		-- write enables 
		wr_en_f1 : out std_logic;
		wr_en_f2 : out std_logic;
		-- read enables
		rd_en_f1 : out std_logic;
		rd_en_f2 : out std_logic;
		-- start processing flag
		enWrCtrlStMachine : out std_logic;
		
		-- port for observing how many pixels have been read
		pixcounter : out std_logic_vector(13 downto 0);
		-- common reset 
		rst : in std_logic;

		-- common prog. full threshold
		prog_full_thresh : in std_logic_vector(9 downto 0)
     );
    END COMPONENT;
    

	-- component declaration of write control state machine
		component writecontrolstatemachine is
			port(
				clk : in std_logic;
				en : in std_logic;
				
				write2file : out std_logic
			);
		end component;
 

   --TEST BENCH : Inputs
   signal d : std_logic_vector(7 downto 0) := (others => '0');
	
   signal en : std_logic := '0';
   signal clk : std_logic := '0';
	signal rst : std_logic := '0';
	
	signal wr_en_f1 : std_logic := '0';
	signal wr_en_f2 : std_logic := '0';
	
	signal rd_en_f1 : std_logic := '0';
	signal rd_en_f2 : std_logic := '0';
	
	signal enWrCtrlStMachine : std_logic := '0';
	
	signal prog_full_thresh : std_logic_vector(9 downto 0) := "0000000000";

 	--TEST BENCH : Outputs
   signal q : std_logic_vector(7 downto 0) := "00000000";
	signal pfull_f1 : std_logic := '0';
	signal pfull_f2 : std_logic := '0';
	signal pixcounter : std_logic_vector(13 downto 0) := (others => '0');
	signal ctrldffchain : std_logic_vector(18 downto 0) := (others => '0');
	
	signal write2file : std_logic := '0';

   -- Clock period definitions
   constant clk_period : time := 10 ns;
	
 	shared variable pixel : std_logic_vector(7 downto 0) := "00000000";

BEGIN
 
 
 		-- instantiate write control state machine
	wrctrlsm : writecontrolstatemachine port map(clk => clk, en => enWrCtrlStMachine, write2file => write2file);
	
	-- Instantiate the Unit Under Test (UUT)
	-- UUT = CACHE MEMORY + Processing Unit = DffChain
   uut: DffChain PORT MAP (
          -- input
			 d => d,
			 -- control signals
			 en => en,
          clk => clk,
 			 rst => rst,

			prog_full_thresh => prog_full_thresh,
			 
			 -- observables
          q => q,
			 pixcounter => pixcounter,
			 pfull_f1 => pfull_f1,
			 pfull_f2 => pfull_f2, 
			 ctrldffchain => ctrldffchain,
			rd_en_f1 => rd_en_f1,
			rd_en_f2 => rd_en_f2,
			
			wr_en_f1 => wr_en_f1, 
			wr_en_f2 => wr_en_f2, 
			enWrCtrlStMachine => enWrCtrlStMachine
        );
		  
-- CLOCK PROCESS
process 
begin
			clk <= '0';
			wait for clk_period/2;
			clk <= '1';
			wait for clk_period/2;
end process;

	
   -- Stimulus process: read data from a file and feed it into the pipeline
   stim_proc: process
		-- variables for the stimulus process
	 -- READ:
	  FILE data : text;
	  variable sample : line;
	  -- WRITE:
	  file dataout : text;
	  variable sampleout : line;
	  -- get last n=4 pixels
	  variable extensionthreshold : integer := 4;
	  variable extensioncounter : integer := 0;
	  variable lastpixelread : boolean := false;
	 
	  
   begin
		-- reset at beginning
		rst <='1';
		en <= '0';
		prog_full_thresh <= "0001111010"; --"0001111100"(124) "0001111011"(123) "0001111010"(122)
		wait for 100 ns;	
		rst <= '0';
		wait for 50 ns;
		
		-- open files for i/o
		 file_open (data,"Lena128x128g_8bits.dat", read_mode);
		 file_open (dataout,"Lena128x128g_8bits_out.dat", write_mode);

		 while not ( endfile(data) and lastpixelread) loop
				if not endfile(data) then
						readline (data,sample);
						read (sample, pixel);
						d <= pixel;
				end if;
				
				if endfile(data) then 
					extensioncounter := integer(extensioncounter + 1);
					if (extensioncounter >= extensionthreshold) then
						lastpixelread := true;
					end if;
				end if;
				
				en <= '1';
				
				wait for clk_period;
				if (pfull_f2 = '1'  and enWrCtrlStMachine = '1') then
						write(sampleout, q);
						writeline(dataout, sampleout);
				end if;
				
		 end loop;
		 
		 file_close (data);
		 file_close(dataout);
		 wait;
		end process;

END;




