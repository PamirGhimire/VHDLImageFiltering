library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


-- PIPELINE ENTITY
entity DffChain is
generic (busWidth : integer := 8);
	port(d : in std_logic_vector(busWidth-1 downto 0);
		en : in std_logic;
		clk : in std_logic;
		q : out std_logic_vector(busWidth-1 downto 0);
		
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
end DffChain;

-- ARCHITECTURE OF PIPELINE ENTITY
architecture dffchain_arch of DffChain is

	-- component instantiation of generic flip flop
component dGenFlipFLop
	generic (busWidth : integer := 8);
	port(d : in std_logic_vector(busWidth-1 downto 0);
		  q : out std_logic_vector(busWidth-1 downto 0);
		  clk : in std_logic;
		  en : in std_logic );
end component;

	-- component instantiation of one bit d-flipflop
component dffOneBit
	port(d : in std_logic;
		  q : out std_logic;
		  clk : in std_logic;
		  en : in std_logic );
end component;

	-- component instantiation of fifo
COMPONENT fifo_jd
  PORT (
    clk : IN STD_LOGIC;
    rst : IN STD_LOGIC;
    din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
    wr_en : IN STD_LOGIC;
    rd_en : IN STD_LOGIC;
    prog_full_thresh : IN STD_LOGIC_VECTOR(9 DOWNTO 0);
    dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
    full : OUT STD_LOGIC;
    empty : OUT STD_LOGIC;
    prog_full : OUT STD_LOGIC
  );
END COMPONENT;

	-- component instantiation of processing unit
component processingUnit
	generic(busWidth : integer := 8);
	port( 
		-- control signals
		clk : in std_logic;
		en : in std_logic;
	
		-- 3x3 neighbourhood input
		p0 : in std_logic_vector(busWidth-1 downto 0);
		p1 : in std_logic_vector(busWidth-1 downto 0);
		p2 : in std_logic_vector(busWidth-1 downto 0);
		p3 : in std_logic_vector(busWidth-1 downto 0);
		p4 : in std_logic_vector(busWidth-1 downto 0);
		p5 : in std_logic_vector(busWidth-1 downto 0);
		p6 : in std_logic_vector(busWidth-1 downto 0);
		p7 : in std_logic_vector(busWidth-1 downto 0);
		p8 : in std_logic_vector(busWidth-1 downto 0);
		
		-- 1 pixel output
		pout : out std_logic_vector(busWidth-1 downto 0)
	);
end component;

	-- variables for communicating results of dff's and fifo's in the pipeline
type tempCommArray is array(10 downto 0) of std_logic_vector(7 downto 0);
	-- ctrlarray = ctrl en-signal propagation + processing unit's delay, depth = 4
type tempCtrlArray is array(18 downto 0) of std_logic; 
signal temp : tempCommArray := (others=>(others=>'0'));
signal ctrltemp : tempCtrlArray := (others =>'0');

	-- counter for initializing processing:
signal pcounter : std_logic_vector(13 downto 0) := "00000000000001" ;

begin

incrementCounter : process(clk)
begin
	if (rising_edge(clk)) then
		pcounter <= std_logic_vector(unsigned(pcounter) + 1);
		pixcounter <= pcounter;
	end if;
	
end process;

---------------
--DELAY LINE (CACHE MEMORY:)
---------------
-- image row (n - 2)
fc11 : dffOneBit port map(d => '1', en => en, clk => clk, q => ctrltemp(0));
f11 : dGenFlipFlop generic map (busWidth => 8) port map(d => d, en => en, clk => clk, q => temp(0));

fc12 : dffOneBit port map(d => ctrltemp(0), en => en, clk => clk, q => ctrltemp(1));
f12 :  dGenFlipFlop generic map (busWidth => 8) port map(d => temp(0), en => ctrltemp(0), clk => clk, q => temp(1));

fc13 : dffOneBit port map(d => ctrltemp(1), en => en, clk => clk, q => ctrltemp(2));
f13 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(1), en => ctrltemp(1), clk => clk, q => temp(2) );

fifo1 : fifo_jd port map(clk => clk, din => temp(2), wr_en => ctrltemp(2), rd_en => ctrltemp(4), rst => rst, 
			prog_full_thresh => prog_full_thresh, dout => temp(3), prog_full => ctrltemp(3));
fc14 : dffOneBit port map(d => ctrltemp(3), en => en, clk => clk, q => ctrltemp(4));
fc15 : dffOneBit port map(d => ctrltemp(4), en => en, clk => clk, q => ctrltemp(5));


	--making fifo1 observable
fifo1full : pfull_f1 <= ctrltemp(3);
fifo1rden : rd_en_f1 <= ctrltemp(4);
fifo1wren : wr_en_f1 <= ctrltemp(2);

-- image row (n - 1)
fc21 : dffOneBit port map(d => ctrltemp(5), en => en, clk => clk, q => ctrltemp(6));
f21 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(3), en => ctrltemp(5), clk => clk, q => temp(4));

fc22 : dffOneBit port map(d => ctrltemp(6), en => en, clk => clk, q => ctrltemp(7));
f22 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(4), en => ctrltemp(6), clk => clk, q => temp(5));

fc23 : dffOneBit port map(d => ctrltemp(7), en => en, clk => clk, q => ctrltemp(8));
f23 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(5), en => ctrltemp(7), clk => clk, q => temp(6));

fifo2 : fifo_jd port map(clk => clk, din => temp(6), wr_en => ctrltemp(8), rd_en => ctrltemp(10), rst => rst, 
			prog_full_thresh => prog_full_thresh, dout => temp(7), prog_full => ctrltemp(9));
fc24 : dffOneBit port map(d => ctrltemp(9), en => en, clk => clk, q => ctrltemp(10));
fc25 : dffOneBit port map(d => ctrltemp(10), en => en, clk => clk, q => ctrltemp(11));

	--making fifo2 observable
fifo2full : pfull_f2 <= ctrltemp(9);
fifo2rden : rd_en_f2 <= ctrltemp(10);
fifo2wren : wr_en_f2 <= ctrltemp(8);

-- image row (n)
fc31 : dffOneBit port map(d => ctrltemp(11), en => en, clk => clk, q => ctrltemp(12));
f31 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(7), en => ctrltemp(11), clk => clk, q => temp(8));

fc32 : dffOneBit port map(d => ctrltemp(12), en => en, clk => clk, q => ctrltemp(13));
f32 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(8), en => ctrltemp(12), clk => clk, q => temp(9));

fc33 : dffOneBit port map(d => ctrltemp(13), en => en, clk => clk, q => ctrltemp(14));
f33 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(9), en => ctrltemp(13), clk => clk, q => temp(10));

-- get output from temp buffer
-- if no processing unit connected, else, get output from processing unit
--getOut : q <= temp(10);

ctrlchain : ctrldffchain <= std_logic_vector(ctrltemp);

---------------
--PROCESSING UNIT
---------------
smoothing: processingUnit generic map (busWidth => 8) port map(clk=>clk, en=>ctrltemp(14), 
				p0=>temp(10), p1=>temp(9), p2=>temp(8), 
				p3=>temp(6), p4=>temp(5), p5=>temp(4), 
				p6=>temp(2), p7=>temp(1), p8=>temp(0), 
				pout=>q);
				
	-- delay enable of write ctrl state machine to account for processing unit's (3 deep) delay
fdlay1 : dffOneBit port map(d => ctrltemp(14), en => en, clk => clk, q => ctrltemp(15));
fdlay2 : dffOneBit port map(d => ctrltemp(15), en => en, clk => clk, q => ctrltemp(16));
fdlay3 : dffOneBit port map(d => ctrltemp(16), en => en, clk => clk, q => ctrltemp(17));
fdlay4 : dffOneBit port map(d => ctrltemp(17), en => en, clk => clk, q => ctrltemp(18));


	--making filtering process observable
startflag : enWrCtrlStMachine <= ctrltemp(18);
				
end dffchain_arch;

