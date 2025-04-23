library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity divider_tb is
end divider_tb;

architecture combinatorio of divider_tb is

	component divider
		port (
			clk     : in std_logic;
			resetn  : in std_logic;
			IN_A    : in std_logic_vector(15 downto 0);
			IN_B    : in std_logic_vector(15 downto 0);
			OUT_DIV : out std_logic_vector(15 downto 0);
			OUT_REM : out std_logic_vector(15 downto 0)
		);
	end component;

	signal clk, resetn: std_logic;
	signal IN_A, IN_B: std_logic_vector(15 downto 0);
	signal OUT_DIV, OUT_REM: std_logic_vector(15 downto 0);
	--Clock Period for Simulation
	constant clk_period :time:= 73 ns;
	
begin

	UUT: divider port map (clk, resetn, IN_A, IN_B, OUT_DIV, OUT_REM);
	
	xsclock_engine : process
    	begin
      		clk <= '0';
      		wait for clk_period/2;
      		clk <= '1';
      		wait for clk_period/2;
    	end process;

	reset_engine : process
    	begin
        	wait for clk_period/2;
        	resetn <= '0';
        	wait for clk_period/2;
        	resetn <= '1';
        	wait;
    	end process;

	input_data : process
	begin
		IN_A <= conv_std_logic_vector(0, 16);
		IN_B <= conv_std_logic_vector(1, 16);  -- Avoid division by zero
		wait for clk_period;
		IN_A <= conv_std_logic_vector(1500, 16);
		IN_B <= conv_std_logic_vector(75, 16);
		wait for clk_period;
		IN_A <= conv_std_logic_vector(1024, 16);
		IN_B <= conv_std_logic_vector(64, 16);
		wait for clk_period;
		IN_A <= conv_std_logic_vector(255, 16);
		IN_B <= conv_std_logic_vector(16, 16);
		wait for clk_period;
		IN_A <= conv_std_logic_vector(789, 16);
		IN_B <= conv_std_logic_vector(123, 16);

		wait for clk_period;	

		for I in 0 to 10 loop
		
			IN_A <= conv_std_logic_vector(8192-20*I, 16);
			IN_B <= conv_std_logic_vector(100*I, 16);
		
			wait for clk_period;

		end loop;

		wait;

	end process;

end combinatorio;
