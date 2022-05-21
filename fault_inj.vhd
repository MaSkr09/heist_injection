
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
-- Noise injection for HEIST
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
entity fault_inj is
    generic ( 
        BURST_PERIODE_TICKS         : integer := 45000000;      -- 0.3s * 150MHz
        BURST_REPETITION_TICKS      : integer := 30000;         -- 200us * 150MHz (5kHz)
        BURST_DURATION_TICKS        : integer := 2250000;       -- 0.015s * 150MHz (75 repetitions)

        LAST_POS_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";  -- When signal is positive
        LAST_NEG_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";   -- When signal is negative
        PULSE_BREAK                     : std_logic_vector(7 downto 0)  := "10101010"       -- End of burst pulse
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
end fault_inj;

architecture Behavioral of fault_inj is

-----------------------------------------------------------------------------------------------------
-- Signal for modules connection
-----------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- For fsm
-----------------------------------------------------------------------------------------------------
    type inj_timing_fsm is (IDLE_STATE, ADD_PULSE_STATE, WAIT_STATE);
    signal pr_state, nx_state: inj_timing_fsm;
    
    signal periode_timer_reg            : integer range 0 to BURST_PERIODE_TICKS+1 := 0;
    signal repetition_timer_reg         : integer range 0 to BURST_REPETITION_TICKS+1 := 0;
    signal duration_timer_reg           : integer range 0 to BURST_DURATION_TICKS+1 := 0;

    signal add_pulse                    : std_logic := '0';


-----------------------------------------------------------------------------------------------------
-- Memory and serializer
-----------------------------------------------------------------------------------------------------
component mem_and_ser_driver is
    generic (
        LAST_POS_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";  -- When signal is positive
        LAST_NEG_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";   -- When signal is negative
        PULSE_BREAK                     : std_logic_vector(7 downto 0)  := "10101010"       -- End of burst pulse
        );
    Port ( 
        high_speed_clk_in            : in STD_LOGIC;
        clk_in                       : in STD_LOGIC;
        reset_in                     : in STD_LOGIC;
        fault_pulse_en_in            : in STD_LOGIC;
        
        spi_mosi_in                 : in STD_LOGIC;
        spi_miso_in                 : in STD_LOGIC;
        spi_clk_in                  : in STD_LOGIC;
        spi_cs_in                   : in STD_LOGIC;
        
        spi_mosi_out                 : out STD_LOGIC;
        spi_miso_out                 : out STD_LOGIC;
        spi_clk_out                  : out STD_LOGIC;
        spi_cs_out                   : out STD_LOGIC
);
end component;
    
begin

-----------------------------------------------------------------------------------------------------
-- Memory and serializer
-----------------------------------------------------------------------------------------------------
MEM_AND_SER_INST: mem_and_ser_driver
    generic map(
        LAST_POS_ADDR                   => LAST_POS_ADDR,  -- When signal is positive
        LAST_NEG_ADDR                   => LAST_NEG_ADDR,   -- When signal is negative
        PULSE_BREAK                     => PULSE_BREAK
    ) 
    Port map( 
        high_speed_clk_in               => high_speed_clk_in,
        clk_in                          => clk_in,
        reset_in                        => reset_in,
        fault_pulse_en_in               => add_pulse,


        spi_mosi_in                     => spi_mosi_in,
        spi_miso_in                     => spi_miso_in,
        spi_clk_in                      => spi_clk_in,
        spi_cs_in                       => spi_cs_in,
        
        spi_mosi_out                    => spi_mosi_out,
        spi_miso_out                    => spi_miso_out,
        spi_clk_out                     => spi_clk_out,
        spi_cs_out                      => spi_cs_out
   );

-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection pulses and control periodes
-----------------------------------------------------------------------------------------------------
process(clk_in)
begin 
    if (clk_in'event and clk_in = '1') then        

        if(nx_state = IDLE_STATE) then
            periode_timer_reg <= 0;
            repetition_timer_reg <= 0;
            duration_timer_reg <= 0;

        else
            periode_timer_reg <= periode_timer_reg + 1;
            repetition_timer_reg <= repetition_timer_reg +1;
            
            if(duration_timer_reg /= BURST_DURATION_TICKS) then
                duration_timer_reg <= duration_timer_reg +1;
            end if;

            if(nx_state = ADD_PULSE_STATE) then 
                repetition_timer_reg <= 0;
            end if;

        end if;

        if(nx_state /= pr_state) then
            pr_state <= nx_state;
        end if;
    end if;
end process;

-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection pulses and control periodes
-----------------------------------------------------------------------------------------------------
process(pr_state, injection_en_in, periode_timer_reg, repetition_timer_reg, duration_timer_reg)
begin 
    add_pulse <= '0';
    
    case pr_state is
        when IDLE_STATE =>
            nx_state <= IDLE_STATE;
            
            if(injection_en_in = '1') then
                nx_state <= ADD_PULSE_STATE;
            end if;

        when ADD_PULSE_STATE =>
            nx_state <= WAIT_STATE;
            add_pulse <= '1';
            
        when WAIT_STATE =>
            nx_state <= WAIT_STATE;
        
            if((periode_timer_reg = BURST_PERIODE_TICKS) or (injection_en_in = '0')) then
                nx_state <= IDLE_STATE;
            elsif((duration_timer_reg < BURST_DURATION_TICKS) and (repetition_timer_reg = BURST_REPETITION_TICKS)) then
                nx_state <= ADD_PULSE_STATE;
            end if;
    end case;

end process;

end Behavioral;
