
----------------------------------------------------------------------------------
-- MIT License
-- 
-- Copyright (c) 2022 Martin Skriver
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
----------------------------------------------------------------------------------
-- Company: University of Southern Denmark
-- Engineer: Martin Skriver
-- Contact: maskr@mmmi.sdu.dk maskr09@gmail.com
--
-- Description: 
-- Top module for HEIST noise injection
--
----------------------------------------------------------------------------------



-----------------------------------------------------------------------------------------------------
-- Libraries 
-----------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
library UNISIM;
use UNISIM.VComponents.all;

-----------------------------------------------------------------------------------------------------
-- Generics and ports
-----------------------------------------------------------------------------------------------------
entity top_level is
    generic ( 
        BTN_TICK_LIM                : integer := 15000000;     --  0.1 s
        INJ_DELAY                   : integer := 15000000;     --  0.1 s

        BURST_PERIODE_TICKS         : integer := 45000000;      -- 0.3s * 150MHz
        BURST_REPETITION_TICKS      : integer := 30000;         -- 200us * 150MHz (5kHz)
        BURST_DURATION_TICKS        : integer := 2250000;       -- 0.015s * 150MHz (75 repetitions)

        LAST_POS_ADDR                   : std_logic_vector(11 downto 0) := "011000011111";  -- When signal is positive
        LAST_NEG_ADDR                   : std_logic_vector(11 downto 0) := "010101000011";   -- When signal is negative

        PULSE_BREAK                 : std_logic_vector(7 downto 0)  := "10101010"        -- End of burst pulse
    ); 
    Port ( 
        clk_in                      : in STD_LOGIC;
        
        spi_mosi_in                 : in STD_LOGIC;
        spi_miso_in                 : in STD_LOGIC;
        spi_clk_in                  : in STD_LOGIC;
        spi_cs_in                   : in STD_LOGIC;

        spi_mosi_out                 : out STD_LOGIC;
        spi_miso_out                 : out STD_LOGIC;
        spi_clk_out                  : out STD_LOGIC;
        spi_cs_out                   : out STD_LOGIC;
        
        btn1_in                     : in STD_LOGIC;
        leds_out                    : out STD_LOGIC_VECTOR (2 downto 0));
end top_level;

architecture Behavioral of top_level is

-----------------------------------------------------------------------------------------------------
-- Signal for modules connection
-----------------------------------------------------------------------------------------------------
    signal clk_x4_reg                   : std_logic;
--    signal clk_x4_inv_reg               : std_logic;
    signal clk_reg                      : std_logic;
    signal clk_x4_gen                   : std_logic;
    signal clk_locked                   : std_logic;
    signal reset_out_ser                : std_logic;

-----------------------------------------------------------------------------------------------------
-- For fsm
-----------------------------------------------------------------------------------------------------
    type injection_fsm is (IDLE_STATE, BTN_WAIT_STATE, INJ_DELAY_STATE, FAULT_INJ_STATE, BTN_WAIT2_STATE);
    signal pr_state, nx_state: injection_fsm;
    signal timer_reg                    : integer range 0 to INJ_DELAY+1;

    signal fault_inj_en                 : std_logic := '0';
    
-----------------------------------------------------------------------------------------------------
-- Clk gen
-----------------------------------------------------------------------------------------------------
component my_clk is
    Port ( 
        clk_in                      : in STD_LOGIC;
        clk_high_speed_out          : out STD_LOGIC;
        clk_locked_out              : out STD_LOGIC
    );
end component;
-----------------------------------------------------------------------------------------------------
-- Fault injection
-----------------------------------------------------------------------------------------------------
component fault_inj is
    generic ( 
        BURST_PERIODE_TICKS         : integer := 45000000;      -- 0.3s * 150MHz
        BURST_REPETITION_TICKS      : integer := 30000;         -- 200us * 150MHz (5kHz)
        BURST_DURATION_TICKS        : integer := 2250000;       -- 0.015s * 150MHz (75 repetitions)

        LAST_POS_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";  -- When signal is positive
        LAST_NEG_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";   -- When signal is negative
        PULSE_BREAK                     : std_logic_vector(7 downto 0)  := "10101010"   -- End of burst pulse
        );
    Port ( 
            high_speed_clk_in        : in STD_LOGIC;
            clk_in                   : in STD_LOGIC;
           
            spi_mosi_in                 : in STD_LOGIC;
            spi_miso_in                 : in STD_LOGIC;
            spi_clk_in                  : in STD_LOGIC;
            spi_cs_in                   : in STD_LOGIC;
            
            spi_mosi_out                 : out STD_LOGIC;
            spi_miso_out                 : out STD_LOGIC;
            spi_clk_out                  : out STD_LOGIC;
            spi_cs_out                   : out STD_LOGIC;

            injection_en_in          : in STD_LOGIC;
            reset_in                 : in STD_LOGIC
    );
end component;

begin
spi_miso_out <= spi_miso_in;

-----------------------------------------------------------------------------------------------------
-- Fault injection
-----------------------------------------------------------------------------------------------------
FAULT_INJ_INST: fault_inj
    generic map(
        BURST_PERIODE_TICKS         => BURST_PERIODE_TICKS,      -- 0.3s * 150MHz
        BURST_REPETITION_TICKS      => BURST_REPETITION_TICKS,         -- 200us * 150MHz (5kHz)
        BURST_DURATION_TICKS        => BURST_DURATION_TICKS,        -- 0.015s * 150MHz (75 repetitions)

        LAST_POS_ADDR               => LAST_POS_ADDR,
        LAST_NEG_ADDR               => LAST_NEG_ADDR,
        PULSE_BREAK                 => PULSE_BREAK
    ) 
    Port map( 
        high_speed_clk_in           => clk_x4_reg,
        clk_in                      => clk_reg,

        spi_mosi_in                 => spi_mosi_in,
        spi_miso_in                 => spi_miso_in,
        spi_clk_in                  => spi_clk_in,
        spi_cs_in                   => spi_cs_in,
        
        spi_mosi_out                => spi_mosi_out,
        spi_miso_out                => spi_miso_out,
        spi_clk_out                 => spi_clk_out,
        spi_cs_out                  => spi_cs_out,

        injection_en_in             => fault_inj_en,
        reset_in                    => reset_out_ser
   );
   
-----------------------------------------------------------------------------------------------------
-- CLK gen, buffers and dividers
-----------------------------------------------------------------------------------------------------
CLK_INST: my_clk
    Port map( 
        clk_in                      => clk_in,
        clk_high_speed_out          => clk_x4_gen,
        clk_locked_out              => clk_locked
    );
    
-----------------------------------------------------------------------------------------------------
BUFIO_inst : BUFIO
    port map (
        O               => clk_x4_reg,          -- 1-bit output: Clock output (connect to I/O clock loads).
        I               => clk_x4_gen           -- 1-bit input: Clock input (connect to an IBUFG or BUFMR).
    );
--    clk_x4_inv_reg <= not clk_x4_reg;
-----------------------------------------------------------------------------------------------------
BUFR2_inst : BUFR
    generic map (
        BUFR_DIVIDE     => "4",             -- Values: "BYPASS, 1, 2, 3, 4, 5, 6, 7, 8"
        SIM_DEVICE      => "7SERIES"        -- Must be set to "7SERIES"
    )
    port map (
        O               => clk_reg,         -- 1-bit output: Clock output port
        CE              => '1',             -- 1-bit input: Active high, clock enable (Divided modes only)
        CLR             => reset_out_ser,   -- 1-bit input: Active high, asynchronous clear (Divided modes only)
        I               => clk_x4_gen       -- 1-bit input: Clock buffer input driven by an IBUFG, MMCM or local interconnect
    );

-----------------------------------------------------------------------------------------------------
reset_out_ser <= not clk_locked;



-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection
-----------------------------------------------------------------------------------------------------
process(clk_reg)
begin 
    if (clk_reg'event and clk_reg = '1') then        
        if(nx_state /= pr_state) then
            timer_reg <= 0;
            pr_state <= nx_state;
           
        else
            if(timer_reg <= BTN_TICK_LIM) then
                timer_reg <= timer_reg + 1;
            end if;
        end if;        
    end if;
end process;

-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection
-----------------------------------------------------------------------------------------------------
process(pr_state, btn1_in, timer_reg)
begin 
    fault_inj_en <= '0';
    leds_out <= "000";

    case pr_state is
        when IDLE_STATE =>
            nx_state <= IDLE_STATE;
            leds_out <= "001";
            if(btn1_in = '0') then
                nx_state <= BTN_WAIT_STATE;
            end if;
            
        when BTN_WAIT_STATE =>
            nx_state <= BTN_WAIT_STATE;            
            leds_out <= "010";
            
            if((timer_reg >= BTN_TICK_LIM) and (btn1_in /= '0')) then
                nx_state <= INJ_DELAY_STATE;
            elsif(btn1_in = '1') then
                nx_state <= IDLE_STATE;
            end if;

        when INJ_DELAY_STATE =>
            nx_state <= INJ_DELAY_STATE;            
            leds_out <= "011";
            
            if(timer_reg = INJ_DELAY) then
                nx_state <= FAULT_INJ_STATE;
            end if;
            
        when FAULT_INJ_STATE =>
            nx_state <= FAULT_INJ_STATE;
            leds_out <= "111";
            
            fault_inj_en <= '1';
            if(btn1_in = '0') then
                nx_state <= BTN_WAIT2_STATE;
            end if;
            
        when BTN_WAIT2_STATE =>
            nx_state <= BTN_WAIT2_STATE;            
            leds_out <= "100";

            if((timer_reg >= BTN_TICK_LIM) and (btn1_in = '1')) then
                nx_state <= IDLE_STATE;
            end if;
            
    end case;

end process;

end Behavioral;
