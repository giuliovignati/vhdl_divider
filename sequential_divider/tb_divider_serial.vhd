library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity Testbench is
end Testbench;

architecture A of Testbench is
  
  component divider_serial
    port (
      clk     : in std_logic;
      resetn  : in std_logic;
      IN_A    : in  std_logic_vector(15 downto 0);  -- dividend
      IN_B    : in  std_logic_vector(15 downto 0);  -- divisor
      OUT_DIV : out std_logic_vector(15 downto 0);  -- quotient
      OUT_REM : out std_logic_vector(15 downto 0);  -- remainder
      start   : in std_logic;
      elab    : out std_logic;
      done    : out std_logic
    );
  end component;
  
  signal resetn  : std_logic;
  signal clk     : std_logic;
  signal IN_A    : std_logic_vector(15 downto 0);
  signal IN_B    : std_logic_vector(15 downto 0);
  signal OUT_DIV : std_logic_vector(15 downto 0);
  signal OUT_REM : std_logic_vector(15 downto 0);
  signal start, elab, done : std_logic;
  
constant clk_period :time:= 7 ns;

begin
  
  UUT: divider_serial 
    port map (clk, resetn, IN_A, IN_B, OUT_DIV, OUT_REM, start, elab, done);

  clk_engine: process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process;  

  reset_engine: process
  begin
    wait for clk_period/2;  
    resetn <= '0';
    wait for clk_period/2;  
    resetn <= '1';
    wait;
  end process;
  
  test: process
  begin
    start <= '0';
    IN_A  <= conv_std_logic_vector(0, 16);  -- dividend
    IN_B  <= conv_std_logic_vector(1, 16);  -- divisor
    wait for clk_period;

    -- Test case 1: 144 / 12
    start <= '1';
    IN_A <= conv_std_logic_vector(144, 16);
    IN_B <= conv_std_logic_vector(12, 16);
    wait for clk_period;
    start <= '0';
    wait for 16*clk_period;

    -- Test case 2: 255 / 15
    start <= '1';
    IN_A <= conv_std_logic_vector(255, 16);
    IN_B <= conv_std_logic_vector(15, 16);
    wait for clk_period;
    start <= '0';
    wait for 16*clk_period;

    -- Test case 3: 1000 / 3
    start <= '1';
    IN_A <= conv_std_logic_vector(1000, 16);
    IN_B <= conv_std_logic_vector(3, 16);
    wait for clk_period;
    start <= '0';
    wait for 16*clk_period;

    -- Test case 4: 65535 / 65535
    start <= '1';
    IN_A <= X"FFFF";  -- max value for 16-bit
    IN_B <= X"FFFF";  -- max value for 16-bit
    wait for clk_period;
    start <= '0';
    wait for 16*clk_period;


	for I in 0 to 10 loop

		start <= '1';
		IN_A <= conv_std_logic_vector(30000-20*I, 16);
		IN_B <= conv_std_logic_vector(136*I, 16);
		wait for clk_period;
		start <= '0';
		wait for 17*clk_period;

	end loop;

    wait;

  end process;

end A;
