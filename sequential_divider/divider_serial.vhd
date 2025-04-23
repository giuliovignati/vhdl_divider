library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity divider_serial is
port (
    clk       : in  std_logic;
    resetn    : in  std_logic;
    IN_A      : in  std_logic_vector(15 downto 0); -- dividend
    IN_B      : in  std_logic_vector(15 downto 0); -- divider
    OUT_DIV   : out std_logic_vector(15 downto 0); -- quotient
    OUT_REM   : out std_logic_vector(15 downto 0); -- remainder
    start     : in  std_logic;
    elab      : out std_logic;
    done      : out std_logic
);
end divider_serial;

architecture behavioral of divider_serial is

    -- Internal signals
    signal count_d, count_q : unsigned(3 downto 0);   		--4-bit unsigned counter to track the number of cycles
    signal sub              : std_logic_vector(15 downto 0);	--Result of subtracting the divisor from the current dividend portion
    signal en_divider       : std_logic;
    signal en_load_dividend : std_logic;
    signal en_shift_dividend: std_logic;
    signal en_rem           : std_logic;
    signal en_quoz          : std_logic;
    signal en_count         : std_logic;
    signal reset_count      : std_logic;
    signal sign             : std_logic;
    signal divider_q, quoz_q, rem_q, quoz_d, rem_d, to_be_subbed : std_logic_vector(15 downto 0);
    signal dividend_d, dividend_q : std_logic_vector(30 downto 0);
    type stato is (IDLE, CALC, OUTPUT);
    signal cs, ns           : stato;

begin

    -- Count process
    process(clk)
    begin
        if clk'event and clk = '1' then
            if reset_count = '1' or resetn = '0' then
                count_q <= (others => '0');
            elsif en_count = '1' then
                count_q <= count_d;
            end if;
        end if;
    end process;

    count_d <= count_q + conv_unsigned(1, 4);

    -- Dividend register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if resetn = '0' then
                dividend_q <= (others => '0');
            else
                if en_load_dividend = '1' then
                    dividend_q <= "000000000000000" & IN_A; -- N+N-1 bits
                elsif en_shift_dividend = '1' then
                    dividend_q <= dividend_d(29 downto 0) & '0';
                end if;
            end if;
        end if;
    end process;

    -- Divider register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if resetn = '0' then
                divider_q <= (others => '0');
            elsif en_divider = '1' then
                divider_q <= IN_B;
            end if;
        end if;
    end process;

    -- Quotient register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if resetn = '0' then
                quoz_q <= (others => '0');
            elsif en_quoz = '1' then
                quoz_q <= quoz_d;
            end if;
        end if;
    end process;

    -- Remainder register
    process(clk)
    begin
        if clk'event and clk = '1' then
            if resetn = '0' then
                rem_q <= (others => '0');
            elsif en_rem = '1' then
                rem_q <= rem_d;
            end if;
        end if;
    end process;

    -- Datapath process
    process(dividend_q, divider_q, sub, to_be_subbed, quoz_q, sign)
    begin
        to_be_subbed <= dividend_q(30 downto 15);
        sub <= unsigned(to_be_subbed) - unsigned(divider_q);
		  
        if unsigned(to_be_subbed) >= unsigned(divider_q) then
            dividend_d(30 downto 15) <= sub;
            dividend_d(14 downto 0) <= dividend_q(14 downto 0);
            rem_d <= sub;
            sign <= '1';
        else
            rem_d <= to_be_subbed;
            dividend_d <= dividend_q;
            sign <= '0';
        end if;
		  
        quoz_d <= quoz_q(14 downto 0) & sign;
    end process;

    -- FSM Sequential
    process(clk, resetn)
    begin
        if resetn = '0' then
            cs <= IDLE;
        elsif clk'event and clk = '1' then
            cs <= ns;
        end if;
    end process;

    -- FSM Combinatorial
    process(cs, start, count_q)
    begin
        en_rem <= '0';
        en_quoz <= '0';
        en_divider <= '0';
        en_load_dividend <= '0';
        en_shift_dividend <= '0';
        en_count <= '0';
        reset_count <= '0';
        done <= '0';
        elab <= '0';
        ns <= cs;

        case cs is
            when IDLE =>
                if start = '1' then
                    en_divider <= '1';
                    en_load_dividend <= '1';
                    ns <= CALC;
                end if;

            when CALC =>
                en_count <= '1';
                en_quoz <= '1';
                en_shift_dividend <= '1';
                elab <= '1';
                if count_q = conv_unsigned(15, 4) then
                    en_rem <= '1';
                    reset_count <= '1';
                    ns <= OUTPUT;
                else
                    ns <= cs;
                end if;

            when OUTPUT =>
                done <= '1';
                if start = '1' then
                    en_divider <= '1';
                    en_load_dividend <= '1';
                    ns <= CALC;
                else
                    ns <= IDLE;
                end if;

            when others =>
                ns <= IDLE;
        end case;
    end process;

    -- Outputs
    OUT_DIV <= quoz_q;
    OUT_REM <= rem_q;

end behavioral;

