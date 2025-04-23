library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity divider is
    port (
        clk     : in std_logic;
        resetn  : in std_logic;
        IN_A    : in std_logic_vector(15 downto 0);
        IN_B    : in std_logic_vector(15 downto 0);
        OUT_DIV : out std_logic_vector(15 downto 0);
        OUT_REM : out std_logic_vector(15 downto 0)
    );
end divider;

architecture behavioral of divider is
    signal IN_A_REG     : std_logic_vector(15 downto 0);
    signal IN_B_REG     : std_logic_vector(15 downto 0);
    signal OUT_DIV_INT  : std_logic_vector(15 downto 0);
    signal OUT_REM_INT  : std_logic_vector(15 downto 0); 
begin


--registri ingressi
    sample_input:
    process(clk, resetn)
    begin
        if (resetn = '0') then
            IN_A_REG <= (others => '0');
            IN_B_REG <= (others => '0');
        elsif (clk'event and clk = '1') then
            IN_A_REG <= IN_A;
            IN_B_REG <= IN_B;
        end if;
    end process;

--registri uscite
    sample_output:
    process(clk, resetn)
    begin
        if (resetn = '0') then
            OUT_DIV <= (others => '0');
            OUT_REM <= (others => '0');
        elsif (clk'event and clk = '1') then
            OUT_DIV <= OUT_DIV_INT;
            OUT_REM <= OUT_REM_INT;
        end if;
    end process;
	 

    OUT_DIV_INT <= std_logic_vector(unsigned(IN_A_REG) / unsigned(IN_B_REG)); 
    OUT_REM_INT <= std_logic_vector(unsigned(IN_A_REG) rem unsigned(IN_B_REG));
	 

end behavioral;

