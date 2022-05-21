
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
-- Memory and serial driver for HEIST
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
entity mem_and_ser_driver is
    generic (
        LAST_POS_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";  -- When signal is positive
        LAST_NEG_ADDR                   : std_logic_vector(11 downto 0) := "000000001000";   -- When signal is negative
        PULSE_BREAK                     : std_logic_vector(7 downto 0)  := "10101010"       -- End of burst pulse
        );
    Port (  high_speed_clk_in            : in STD_LOGIC;
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
end mem_and_ser_driver;

architecture Behavioral of mem_and_ser_driver is

-----------------------------------------------------------------------------------------------------
-- Memory interfaces
-----------------------------------------------------------------------------------------------------
component pos_sig_bram_mem_interface is
    Port ( 
            clk_in           : in STD_LOGIC;
            addr_in          : in STD_LOGIC_VECTOR (11 downto 0);
            data_out         : out STD_LOGIC_VECTOR (7 downto 0)
    );
end component;

component neg_sig_bram_mem_interface is
    Port ( 
            clk_in           : in STD_LOGIC;
            addr_in          : in STD_LOGIC_VECTOR (11 downto 0);
            data_out         : out STD_LOGIC_VECTOR (7 downto 0)
    );
end component;

-----------------------------------------------------------------------------------------------------
-- Output serializer
-----------------------------------------------------------------------------------------------------
component output_serializer is
    Port ( 
        reset_in            : in STD_LOGIC;
        clk_x4_in           : in STD_LOGIC;
        clk_in              : in STD_LOGIC;
        parallel_data_in    : in STD_LOGIC_VECTOR(7 downto 0);
        q_data_out          : out STD_LOGIC
    );
end component;

-----------------------------------------------------------------------------------------------------
-- Signal for modules connection
-----------------------------------------------------------------------------------------------------
    signal serializer_spi_clk_reg       : std_logic_vector(7 downto 0) := (others => '0');
    signal serializer_spi_mosi_reg      : std_logic_vector(7 downto 0) := (others => '0');
    signal serializer_spi_cs_reg        : std_logic_vector(7 downto 0) := (others => '0');

    signal pos_addr_reg                 : std_logic_vector(11 downto 0) := (others => '0');
    signal neg_addr_reg                 : std_logic_vector(11 downto 0) := (others => '0');
    
    signal pos_data_reg                 : std_logic_vector(7 downto 0) := (others => '0');
    signal neg_data_reg                 : std_logic_vector(7 downto 0) := (others => '0');

-----------------------------------------------------------------------------------------------------
-- For fsm
-----------------------------------------------------------------------------------------------------
    type injection_fsm is (IDLE_STATE, FAULT_INJ_STATE);
    signal pr_state, nx_state: injection_fsm;

    signal nx_data_spi_clk_reg          : std_logic_vector(7 downto 0) := (others => '0');
    signal nx_data_spi_mosi_reg         : std_logic_vector(7 downto 0) := (others => '0');
    signal nx_data_spi_cs_reg           : std_logic_vector(7 downto 0) := (others => '0');
    signal eof_burst_pulse_pos          : std_logic := '0';
    signal eof_burst_pulse_neg          : std_logic := '0';
    
    signal mosi_high_signal             : std_logic := '0';
    signal cs_high_signal               : std_logic := '0';
    signal clk_high_signal              : std_logic := '0';
begin

-----------------------------------------------------------------------------------------------------
-- BRAM instatiations
-----------------------------------------------------------------------------------------------------
BRAM_POS: pos_sig_bram_mem_interface
     port map (
            clk_in          => clk_in,
            addr_in         => pos_addr_reg,
            data_out        => pos_data_reg
    );
    
BRAM_NEG: neg_sig_bram_mem_interface
     port map (
            clk_in          => clk_in,
            addr_in         => neg_addr_reg,
            data_out        => neg_data_reg
    );
    
-----------------------------------------------------------------------------------------------------
-- Output serializer inst
-----------------------------------------------------------------------------------------------------
SER_INST1: output_serializer
    Port map( 
        reset_in                => reset_in,
        clk_x4_in               => high_speed_clk_in,
        clk_in                  => clk_in,
        q_data_out              => spi_mosi_out,
        parallel_data_in        => serializer_spi_mosi_reg
    );

-----------------------------------------------------------------------------------------------------
-- Output serializer inst
-----------------------------------------------------------------------------------------------------
SER_INST2: output_serializer
    Port map( 
        reset_in                => reset_in,
        clk_x4_in               => high_speed_clk_in,
        clk_in                  => clk_in,
        q_data_out              => spi_cs_out,
        parallel_data_in        => serializer_spi_cs_reg
    );

-----------------------------------------------------------------------------------------------------
-- Output serializer inst
-----------------------------------------------------------------------------------------------------
SER_INST3: output_serializer
    Port map( 
        reset_in                => reset_in,
        clk_x4_in               => high_speed_clk_in,
        clk_in                  => clk_in,
        q_data_out              => spi_clk_out,
        parallel_data_in        => serializer_spi_clk_reg
    );

-------------------------------------------------------------------------------------------------------
---- Output serializer inst
-------------------------------------------------------------------------------------------------------
--SER_INST4: output_serializer
--    Port map( 
--        reset_in                => reset_in,
--        clk_x4_in               => high_speed_clk_in,
--        clk_in                  => clk_in,
--        q_data_out              => spi_miso_out,
--        parallel_data_in        => serializer_reg
--    );
    spi_miso_out <= spi_miso_in;
-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection
-----------------------------------------------------------------------------------------------------
process(clk_in)
begin 
    if (clk_in'event and clk_in = '1') then
        nx_data_spi_clk_reg <= (others => spi_clk_in);
        nx_data_spi_mosi_reg <= (others => spi_mosi_in);
        nx_data_spi_cs_reg <= (others => spi_cs_in);
            
        
        if(nx_state /= pr_state) then
            pr_state <= nx_state;

            -- Check signal level at beginning of injection
            if(nx_state = FAULT_INJ_STATE) then
                mosi_high_signal <= spi_mosi_in;
                cs_high_signal <= spi_cs_in;
                clk_high_signal <= spi_clk_in;
            end if;
        end if;

---------------------------------------------------------------------------------------
        -- set to correct register 
        if(nx_state = FAULT_INJ_STATE) then
        
            if(mosi_high_signal = '1') then
                if((pos_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_pos = '0')) then
                    nx_data_spi_mosi_reg <= pos_data_reg;
                end if;
            else
                if((neg_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_neg = '0')) then
                    nx_data_spi_mosi_reg <= neg_data_reg;
                end if;        
            end if;
    
    
            if(cs_high_signal = '1') then
                if((pos_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_pos = '0')) then
                    nx_data_spi_cs_reg <= pos_data_reg;
                end if;
            else
                if((neg_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_neg = '0')) then
                    nx_data_spi_cs_reg <= neg_data_reg;
                end if;        
            end if;
            
    
            if(clk_high_signal = '1') then
                if((pos_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_pos = '0')) then
                    nx_data_spi_clk_reg <= pos_data_reg;
                end if;
            else
                if((neg_data_reg /= PULSE_BREAK) AND (eof_burst_pulse_neg = '0')) then
                    nx_data_spi_clk_reg <= neg_data_reg;
                end if;        
            end if;
        end if;
---------------------------------------------------------------------------------------        
        -- Set address counter 
        if((nx_state = FAULT_INJ_STATE) AND (eof_burst_pulse_pos = '0')) then
            -- Control for positive fault injection
            if(pos_addr_reg = LAST_POS_ADDR) then
                pos_addr_reg <= (others => '0');
            elsif(pos_data_reg /= PULSE_BREAK) then
                pos_addr_reg <= std_logic_vector((unsigned(pos_addr_reg) + 1));
            end if;
        end if;
                
        if((nx_state = FAULT_INJ_STATE) AND (eof_burst_pulse_neg = '0')) then
            -- Control for positive fault injection
            if(neg_addr_reg = LAST_NEG_ADDR) then
                neg_addr_reg <= (others => '0');
            elsif(neg_data_reg /= PULSE_BREAK) then
                neg_addr_reg <= std_logic_vector((unsigned(neg_addr_reg) + 1));
            end if;
        end if;
                
---------------------------------------------------------------------------------------        
        -- Pulse break control
        if(pr_state = FAULT_INJ_STATE) then
            -- Positive pulse break control
            if(pos_data_reg = PULSE_BREAK) then
                eof_burst_pulse_pos <= '1';
            end if;
            -- Negative pulse break control
            if(neg_data_reg = PULSE_BREAK) then
                eof_burst_pulse_neg <= '1';
            end if;
        else
---------------------------------------------------------------------------------------        
        -- reset
            eof_burst_pulse_pos <= '0';
            eof_burst_pulse_neg <= '0';
        
        end if;
---------------------------------------------------------------------------------------        
    end if;
end process;

-----------------------------------------------------------------------------------------------------
-- FSM to start and stop fault injection
-----------------------------------------------------------------------------------------------------
process(pr_state, fault_pulse_en_in, eof_burst_pulse_pos, eof_burst_pulse_neg, nx_data_spi_clk_reg, nx_data_spi_mosi_reg, nx_data_spi_cs_reg)
begin 
    serializer_spi_clk_reg <= nx_data_spi_clk_reg;
    serializer_spi_mosi_reg <= nx_data_spi_mosi_reg;
    serializer_spi_cs_reg <= nx_data_spi_cs_reg;

    case pr_state is
        when IDLE_STATE =>
            nx_state <= IDLE_STATE;

            if(fault_pulse_en_in = '1') then
                nx_state <= FAULT_INJ_STATE;
            end if;
            
        when FAULT_INJ_STATE =>
            nx_state <= FAULT_INJ_STATE;
            
            if((eof_burst_pulse_pos = '1') AND (eof_burst_pulse_neg = '1')) then
                nx_state <= IDLE_STATE;
            end if;
            
    end case;

end process;

end Behavioral;
