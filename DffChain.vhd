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
		-- port for observing how many pixels have been read
		pixcounter : out std_logic_vector(13 downto 0);
		-- common reset 
		rst : in std_logic;
		-- write enables 
		wr_en_f1 : in std_logic;
		wr_en_f2 : in std_logic;
		-- common read enable
		rd_en_f1 : in std_logic;
		rd_en_f2 : in std_logic;
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
signal temp : tempCommArray;

	-- for initializing processing:
signal pcounter : std_logic_vector(13 downto 0) := "00000000000000" ;

begin

incrementCounter : process(clk)
begin
	if (rising_edge(clk)) then
		pcounter <= std_logic_vector(unsigned(pcounter) + 1);
		pixcounter <= pcounter;
	end if;
	
	-- if 128 pixels have been read, read-enable ff1
--	if (pcounter >= 

end process;

---------------
--DELAY LINE (CACHE MEMORY:)
---------------
-- image row (n - 2)
f11 : dGenFlipFlop generic map (busWidth => 8) port map(d => d, en => en, clk => clk, q => temp(0));
f12 :  dGenFlipFlop generic map (busWidth => 8) port map(d => temp(0), en => en, clk => clk, q => temp(1));
f13 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(1), en => en, clk => clk, q => temp(2) );
fifo1 : fifo_jd port map(clk => clk, din => temp(2), wr_en => wr_en_f1, rd_en => rd_en_f1, rst => rst, 
			prog_full_thresh => prog_full_thresh, dout => temp(3), prog_full => pfull_f1);

-- image row (n - 1)
f21 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(3), en => en, clk => clk, q => temp(4));
f22 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(4), en => en, clk => clk, q => temp(5));
f23 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(5), en => en, clk => clk, q => temp(6));
fifo2 : fifo_jd port map(clk => clk, din => temp(6), wr_en => wr_en_f2, rd_en => rd_en_f2, rst => rst, 
			prog_full_thresh => prog_full_thresh, dout => temp(7), prog_full => pfull_f2);

-- image row (n)
f31 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(7), en => en, clk => clk, q => temp(8));
f32 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(8), en => en, clk => clk, q => temp(9));
f33 : dGenFlipFlop generic map (busWidth => 8) port map(d => temp(9), en => en, clk => clk, q => temp(10));

-- get output from temp buffer
-- if no processing unit connected, else, get output from processing unit
--getOut : q <= temp(10);

---------------
--PROCESSING UNIT
---------------
smoothing: processingUnit generic map (busWidth => 8) port map(clk=>clk, en=>en, 
				p0=>temp(10), p1=>temp(9), p2=>temp(8), 
				p3=>temp(6), p4=>temp(5), p5=>temp(4), 
				p6=>temp(2), p7=>temp(1), p8=>temp(0), 
				pout=>q);
				
end dffchain_arch;

