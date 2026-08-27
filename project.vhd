library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start : in std_logic;
        i_add   : in std_logic_vector(15 downto 0);
        i_k     : in std_logic_vector(9 downto 0);
        
        o_done  : out std_logic;
        
        o_mem_addr  : out std_logic_vector(15 downto 0);
        i_mem_data  : in std_logic_vector(7 downto 0);
        o_mem_data  : out std_logic_vector(7 downto 0);
        o_mem_we    : out std_logic;
        o_mem_en    : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is
component counter_16 is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_load  : in std_logic;
        i_en    : in std_logic;
        i_data  : in std_logic_vector(15 downto 0);
        
        output   : out std_logic_vector(15 downto 0)
    );
end component counter_16;

component counter_10 is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_load  : in std_logic;
        i_en    : in std_logic;
        i_data  : in std_logic_vector(9 downto 0);
        
        output   : out std_logic_vector(9 downto 0)
    );
end component counter_10;

component counter_5 is
    port (
        i_clk    : in std_logic;
        i_rst    : in std_logic;
        i_preset : in std_logic;
        i_en     : in std_logic;
        i_clr    : in std_logic;
        
        output   : out std_logic_vector(7 downto 0)
    );
end component counter_5;

component register_8 is
    port (
        i_clk    : in std_logic;
        i_rst    : in std_logic;
        i_data   : in std_logic_vector(7 downto 0);
        i_en     : in std_logic;
        i_clr    : in std_logic;
        
        output   : out std_logic_vector(7 downto 0)
    );
end component register_8;

component multiplexer is
    port(
        input_0 : in std_logic_vector(7 downto 0);
        input_1 : in std_logic_vector(7 downto 0);
        sel     : in std_logic;
        output  : out std_logic_vector(7 downto 0)
    );
end component multiplexer;

component fsm is
    port(
        i_clk       : in std_logic;
        i_rst       : in std_logic;
        i_start     : in std_logic;
        i_mem_data  : in std_logic_vector(7 downto 0);
        i_k         : in std_logic_vector(9 downto 0);
        
        o_mem_en    : out std_logic;
        o_mem_we    : out std_logic;
        o_init      : out std_logic;
        o_c_preset  : out std_logic;
        o_add_en    : out std_logic;
        o_k_en      : out std_logic;
        o_c_en      : out std_logic;
        o_reg_en    : out std_logic;
        o_sel       : out std_logic;
        
        o_done      : out std_logic
    );
end component fsm;

signal init       : std_logic;
signal preset_c   : std_logic;
signal en_add     : std_logic;
signal en_k       : std_logic;
signal en_c       : std_logic;
signal en_reg     : std_logic;
signal mux_sel    : std_logic;
signal k          : std_logic_vector(9 downto 0);
signal stored_val : std_logic_vector(7 downto 0);
signal c          : std_logic_vector(7 downto 0);

begin

    counter_add : counter_16 port map (
        i_clk    => i_clk,
        i_rst    => i_rst,
        i_load   => init,
        i_en     => en_add,
        i_data   => i_add,
        output   => o_mem_addr
    );
    
    counter_k : counter_10 port map (
        i_clk    => i_clk,
        i_rst    => i_rst,
        i_load   => init,
        i_en     => en_k,
        i_data   => i_k,
        output   => k
    );
    
    counter_c : counter_5 port map (
        i_clk    => i_clk,
        i_rst    => i_rst,
        i_preset => preset_c,
        i_en     => en_c,
        i_clr    => init,
        output   => c
    );
    
    reg : register_8 port map (
        i_clk    => i_clk,
        i_rst    => i_rst,
        i_data   => i_mem_data,
        i_en     => en_reg,
        i_clr    => init,
        output   => stored_val
    );
    
    mux : multiplexer port map (
        input_0  => stored_val,
        input_1  => c,
        sel      => mux_sel,
        output   => o_mem_data
    );
    
    fsm_1 : fsm port map (
        i_clk       => i_clk,
        i_rst       => i_rst,
        i_start     => i_start,
        i_mem_data  => i_mem_data,
        i_k         => k,
        
        o_mem_en    => o_mem_en,
        o_mem_we    => o_mem_we,
        o_init      => init,
        o_c_preset  => preset_c,
        o_add_en    => en_add,
        o_k_en      => en_k,
        o_c_en      => en_c,
        o_reg_en    => en_reg,
        o_sel       => mux_sel,
        
        o_done      => o_done
    );

end project_reti_logiche_arch;

-- counter_add

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_16 is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_load  : in std_logic;
        i_en    : in std_logic;
        i_data  : in std_logic_vector(15 downto 0);
        
        output   : out std_logic_vector(15 downto 0)
    );
end counter_16;

architecture counter_16_arch of counter_16 is
    signal value : std_logic_vector(15 downto 0);
begin
    output <= value;
    
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            value <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if i_load = '1' then
                value <= i_data;
            elsif i_en = '1' then
                value <= value + 1;
            end if;
        end if;
    end process;

end counter_16_arch;

-- counter_k

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_10 is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_load  : in std_logic;
        i_en    : in std_logic;
        i_data  : in std_logic_vector(9 downto 0);
        
        output   : out std_logic_vector(9 downto 0)
    );
end counter_10;

architecture counter_10_arch of counter_10 is
    signal value : std_logic_vector(9 downto 0);
begin
    output <= value;
    
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            value <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if i_load = '1' then
                value <= i_data;
            elsif i_en = '1' then
                value <= value - 1;
            end if;
        end if;
    end process;

end counter_10_arch;

-- counter_c

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity counter_5 is
    port (
        i_clk    : in std_logic;
        i_rst    : in std_logic;
        i_preset : in std_logic;
        i_en     : in std_logic;
        i_clr    : in std_logic;
        
        output   : out std_logic_vector(7 downto 0)
    );
end counter_5;

architecture counter_5_arch of counter_5 is
    signal value : std_logic_vector(4 downto 0);
begin
    output <= "000" & value;
    
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            value <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if i_clr = '1' then
                value <= (others => '0');
            elsif i_preset = '1' then
                value <= (others => '1');
            elsif value /= "00000" and i_en = '1' then
                value <= value - 1;
            end if;
        end if;
    end process;

end counter_5_arch;

-- register

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity register_8 is
    port (
        i_clk    : in std_logic;
        i_rst    : in std_logic;
        i_data   : in std_logic_vector(7 downto 0);
        i_en     : in std_logic;
        i_clr    : in std_logic;
        
        output   : out std_logic_vector(7 downto 0)
    );
end register_8;

architecture register_8_arch of register_8 is
    signal stored_value : std_logic_vector (7 downto 0);
begin
    output <= stored_value;

    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            stored_value <= (others => '0');
        elsif i_clk'event and i_clk = '1' then
            if i_clr = '1' then
                stored_value <= (others => '0');
            elsif i_en = '1' then
                stored_value <= i_data;
            end if;
        end if;
    end process;
end register_8_arch;

-- mux

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity multiplexer is
    port(
        input_0 : in std_logic_vector(7 downto 0);
        input_1 : in std_logic_vector(7 downto 0);
        sel     : in std_logic;
        output  : out std_logic_vector(7 downto 0)
    );
end multiplexer;

architecture multiplexer_arch of multiplexer is

begin

    process(input_0, input_1, sel)
    begin
        if sel = '0' then
            output <= input_0;
        else
            output <= input_1;
        end if;
    end process;

end multiplexer_arch;

-- fsm

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.all;

entity fsm is
    port(
        i_clk   : in std_logic;
        i_rst   : in std_logic;
        i_start     : in std_logic;
        i_mem_data  : in std_logic_vector(7 downto 0);
        i_k         : in std_logic_vector(9 downto 0);
        
        o_mem_en    : out std_logic;
        o_mem_we    : out std_logic;
        o_init      : out std_logic;
        o_c_preset  : out std_logic;
        o_add_en    : out std_logic;
        o_k_en      : out std_logic;
        o_c_en      : out std_logic;
        o_reg_en    : out std_logic;
        o_sel       : out std_logic;
        
        o_done      : out std_logic
    );
end fsm;

architecture fsm_arch of fsm is
    type S is (INIT, CHECK, READ, DATA, WRITE, NO_DATA, DONE);
    signal curr_state : S;
begin
    
    process(i_clk, i_rst)
    begin
        if i_rst = '1' then
            curr_state <= INIT;
        elsif i_clk'event and i_clk = '1' then
            case curr_state is
                when INIT =>
                    if i_start = '1' then
                        curr_state <= CHECK;
                    end if;
                when CHECK =>
                    if to_integer(unsigned(i_k)) > 0 then
                        curr_state <= READ;
                    else
                        curr_state <= DONE;
                    end if;
                when READ =>
                    if to_integer(unsigned(i_mem_data)) > 0 then
                        curr_state <= DATA;
                    else
                        curr_state <= NO_DATA;
                    end if;
                when DATA =>
                    curr_state <= WRITE;
                when NO_DATA =>
                    curr_state <= WRITE;
                when WRITE =>
                    curr_state <= CHECK;
                when DONE =>
                    if i_start = '0' then
                        curr_state <= INIT;
                    end if;
            end case;
        end if;
    end process;

    process(curr_state)
    begin
        o_mem_en   <= '0';
        o_mem_we   <= '0';
        o_init     <= '0';
        o_c_preset <= '0';
        o_add_en   <= '0';
        o_k_en     <= '0';
        o_c_en     <= '0';
        o_reg_en   <= '0';
        o_sel      <= '0';
        o_done     <= '0';

        if curr_state = INIT then
            o_init     <= '1';
        elsif curr_state = CHECK then
            o_mem_en   <= '1';
        elsif curr_state = READ then
            o_mem_en   <= '1';
        elsif curr_state = DATA then
            o_mem_en   <= '1';
            o_c_preset <= '1';
            o_add_en   <= '1';
            o_reg_en   <= '1';
        elsif curr_state = WRITE then
            o_mem_en   <= '1';
            o_mem_we   <= '1';
            o_add_en   <= '1';
            o_sel      <= '1';
            o_k_en     <= '1';
        elsif curr_state = NO_DATA then
            o_mem_en   <= '1';
            o_mem_we   <= '1';
            o_add_en   <= '1';
            o_c_en     <= '1';
        elsif curr_state = DONE then
            o_done     <= '1';
        end if;
    end process;
end fsm_arch;

