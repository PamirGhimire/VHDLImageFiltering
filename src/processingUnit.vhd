library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- xilinx primitives
--library UNISIM;
--use UNISIM.VComponents.all;

entity processingUnit is
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
end processingUnit;

--------------------------------------------

architecture processingUnit_arch of processingUnit is

-- component instantiation of pixelAverager
component pixelAverager
	generic(busWidth : integer := 8);
	port(
		pa : in std_logic_vector(busWidth-1 downto 0);
		pb : in std_logic_vector(busWidth-1 downto 0);
		pc : out std_logic_vector(busWidth-1 downto 0);
		
		clk : in std_logic
	);
end component;

-- component instantiation of generic d-flipflop
component dGenFlipFLop
generic (busWidth : integer := 8);
	port(d : in std_logic_vector(busWidth-1 downto 0);
		  q : out std_logic_vector(busWidth-1 downto 0);
		  clk : in std_logic;
		  en : in std_logic );
end component;

-- input layer
signal tempdff1 : std_logic_vector(7 downto 0) := "00000000";
signal temp12 : std_logic_vector(7 downto 0) := "00000000";
signal temp34 : std_logic_vector(7 downto 0) := "00000000";
signal temp56 : std_logic_vector(7 downto 0) := "00000000";
signal temp78 : std_logic_vector(7 downto 0) := "00000000";

-- layer 1 deep
signal tempdff2 : std_logic_vector(7 downto 0) := "00000000";
signal temp1234 : std_logic_vector(7 downto 0) := "00000000";
signal temp5678 : std_logic_vector(7 downto 0) := "00000000";

-- layer 2 deep
signal tempdff3 : std_logic_vector(7 downto 0) := "00000000";
signal temp128 : std_logic_vector(7 downto 0) := "00000000";

-- layer 3 deep = final layer
--signal temp129 : std_logic_vector(7 downto 0) := "00000000";

begin

-- input layer
dff1 : dGenFlipFlop generic map (busWidth => 8) port map(d => p0, q => tempdff1, en => en, clk => clk);
pixav12 : pixelAverager generic map(busWidth => 8) port map(pa => p1, pb => p2, pc => temp12, clk => clk);
pixav34 : pixelAverager generic map(busWidth => 8) port map(pa => p3, pb => p4, pc => temp34, clk => clk);
pixav56 : pixelAverager generic map(busWidth => 8) port map(pa => p5, pb => p6, pc => temp56, clk => clk);
pixav78 : pixelAverager generic map(busWidth => 8) port map(pa => p7, pb => p8, pc => temp78, clk => clk);

-- layer 1 deep
dff2 : dGenFlipFlop generic map (busWidth => 8) port map(d => tempdff1, q => tempdff2, en => en, clk => clk);
pixav1234 : pixelAverager generic map(busWidth => 8) port map(pa=>temp12, pb=>temp34, pc=>temp1234, clk => clk);
pixav5678 : pixelAverager generic map(busWidth => 8) port map(pa=>temp56, pb=>temp78, pc=>temp5678, clk => clk);

-- layer 2 deep
dff3 : dGenFlipFlop generic map (busWidth => 8) port map(d => tempdff2, q => tempdff3, en => en, clk => clk);
pixav128 : pixelAverager generic map(busWidth => 8) port map(pa=>temp1234, pb=>temp5678, pc=>temp128, clk => clk);

-- layer 3 deep = final layer
pixav028 : pixelAverager generic map(busWidth => 8) port map(pa=>temp128, pb=>tempdff3, pc=>pout, clk => clk);


end processingUnit_arch;

