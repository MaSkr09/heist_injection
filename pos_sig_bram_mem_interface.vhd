
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
-- Momery interface for positiv signal for HEIST
--
----------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------
-- Libraries 
-----------------------------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
library UNISIM;
use UNISIM.VComponents.all;
library UNIMACRO;
use unimacro.Vcomponents.all;

-----------------------------------------------------------------------------------------------------
-- Ports and generics
-----------------------------------------------------------------------------------------------------
entity pos_sig_bram_mem_interface is
    Port ( clk_in           : in STD_LOGIC;
           addr_in          : in STD_LOGIC_VECTOR (11 downto 0);
           data_out         : out STD_LOGIC_VECTOR (7 downto 0));
end pos_sig_bram_mem_interface;

architecture Behavioral of pos_sig_bram_mem_interface is

begin
BRAM_TDP_MACRO_inst : BRAM_TDP_MACRO 
    generic map (
        BRAM_SIZE           => "36Kb",        -- Target BRAM, "18Kb" or "36Kb"
        DEVICE              => "7SERIES",       -- Target Device: "VIRTEX5", "VIRTEX6", "7SERIES", "SPARTAN6"
        DOA_REG             => 0,               -- Optional port A output register (0 or 1)
        DOB_REG             => 0,               -- Optional port B output register (0 or 1)
        INIT_A              => X"000000000",    -- Initial values on A output port
        INIT_B              => X"000000000",    -- Initial values on B output port
        INIT_FILE           => "NONE",
        READ_WIDTH_A        => 8,    -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
        READ_WIDTH_B        => 8,    -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
        SIM_COLLISION_CHECK => "ALL", -- Collision check enable "ALL", "WARNING_ONLY",
        -- "GENERATE_X_ONLY" or "NONE"
        SRVAL_A             => X"000000000",    -- Set/Reset value for A port output
        SRVAL_B             => X"000000000",    -- Set/Reset value for B port output
        WRITE_MODE_A        => "WRITE_FIRST",   -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
        WRITE_MODE_B        => "WRITE_FIRST",   -- "WRITE_FIRST", "READ_FIRST" or "NO_CHANGE"
        WRITE_WIDTH_A       => 8,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
        WRITE_WIDTH_B       => 8,   -- Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")


-- 0x77 + 1 = 119; 119 * 32 + 29 - 1 = 3836 -> 111011111100 LAST ADDR

        -- The following INIT_xx declarations specify the initial contents of the RAM
        INIT_00 => X"ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0",
        INIT_01 => X"03ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc0007ff80003",
        INIT_02 => X"fffe0007fff0003fff8000fff80003fe00003ff00000ffe00007ff80007ffc00",
        INIT_03 => X"001ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1",
        INIT_04 => X"ff8007ff00000ffff00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00",
        INIT_05 => X"0007fff8001fffc0007ffc0003ff00001ff80000fff00003ffc0007ffe0001ff",
        INIT_06 => X"f80000fff00003ffc0003ffe0001ffff8007ff00000ffff00000ffc0aa81ffff",
        INIT_07 => X"0fff00001fffe00001ff80aa80ffff0003fff8001fffc0007ffc0001ff00001f", 
        INIT_08 => X"fff0003fffc000fff80003fe00001ff00000fff00003ffc0007ffe0001ffff00",
        INIT_09 => X"00fff00003ffc0007ffe0001ffff8007ff00000ffff00001ffc0aaf1ffff0007",
        INIT_0A => X"00001ffff00001ff80aa81ffff0007fff8003fffc0007ff80003ff00001ff800",
        INIT_0B => X"003fffc000fff80003fe00001ff80000fff00003ffc0007ffe0001ffff000fff",
        INIT_0C => X"e00007ff80007ffc0003ffff000fff00001fffe00001ff80aaf1ffff0007fff0",
        INIT_0D => X"0ffff00001ffc0aaf1fffe0007fff0003fff8000fff80003fe00001ff00000ff",
        INIT_0E => X"ffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff0000",
        INIT_0F => X"03ffc0007ffe0001ffff8007ff00001ffff00001ffc0aa81ffff0007fff8003f",
        INIT_10 => X"f00001ff80aaf1ffff0007fff8003fffc0007ff80003ff00001ff80000fff000",
        INIT_11 => X"00fff80003fe00001ff00000fff00003ffc0007ffe0001ffff000fff00001fff",
        INIT_12 => X"80007ffc0003ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc0",
        INIT_13 => X"01ffc0aaf1fffe0007fff0003fffc000fff80003fe00001ff00000fff00007ff",
        INIT_14 => X"f80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00000ffff000",
        INIT_15 => X"7ffc0003ffff000fff00001fffe00001ff80aa81ffff0007fff8001fffc0007f",
        INIT_16 => X"c0aaf1fffe0007fff0003fff8000fff80003fe00001ff00000fff00007ff8000",
        INIT_17 => X"03ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00000ffff00001ff",
        INIT_18 => X"0001ffff8007ff00001ffff00001ffc0aa81ffff0007fff8003fffc0007ff800",
        INIT_19 => X"81ffff0007fff8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe",
        INIT_1A => X"00001ff80000fff00003ffc0007ffe0001ffff000fff00001ffff00001ff80aa",
        INIT_1B => X"ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc0007ff80003fe",
        INIT_1C => X"fe0007fff0003fff8000fff80003fe00001ff00000ffe00007ff80007ffc0003",
        INIT_1D => X"1ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1ff",
        INIT_1E => X"8007ff00000ffff00001ffc0aaf1ffff0007fff0003fffc0007ff80003ff0000",
        INIT_1F => X"07fff8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff",
        INIT_20 => X"0000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aa81ffff00",
        INIT_21 => X"ff00001fffe00001ff80aaf1ffff0007fff8003fffc0007ff80003ff00001ff8",
        INIT_22 => X"f0003fff8000fff80003fe00001ff00000fff00007ff80007ffc0003ffff000f",
        INIT_23 => X"fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1fffe0007ff",
        INIT_24 => X"000ffff00001ffc0aaf1ffff0007fff0003fffc0007ff80003ff00001ff80000",
        INIT_25 => X"1fffc0007ffc0003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00",
        INIT_26 => X"0003ffc0007ffe0001ffff000fff00001ffff00001ff80aa81ffff0007fff800",
        INIT_27 => X"fff00000ffc0aaf1ffff0007fff0003fffc000fff80003fe00001ff00000fff0",
        INIT_28 => X"c0007ffc0003ff00001ff80000fff00003ffc0003ffe0001ffff8007ff00000f",
        INIT_29 => X"ffc0007ffe0001ffff8007ff00001ffff00001ffc0aa80ffff0007fff8001fff",
        INIT_2A => X"0001ff80aaf1ffff0007fff8003fffc0007ff80003ff00001ff80000fff00003",
        INIT_2B => X"fff80003fe00003ff00000ffe00007ff80007ffc0003ffff000fff00001fffe0",
        INIT_2C => X"007ffc0003ffff000fff00001fffe00001ff80aaf1fffe0007fff0003fff8000",
        INIT_2D => X"ffc0aaf1fffe0007fff0003fff8000fff80003fe00003ff00001ffe00007ff80",
        INIT_2E => X"0003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001",
        INIT_2F => X"fe0001ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc0007ff8",
        INIT_30 => X"aaf1ffff0007fff0003fffc000fff80003fe00001ff00000fff00003ffc0007f",
        INIT_31 => X"ff00001ff80000fff00003ffc0003ffe0001ffff8007ff00000ffff00000ffc0",
        INIT_32 => X"01ffff8007ff00001ffff00001ffc0aa80ffff0003fff8001fffc0007ffc0001",
        INIT_33 => X"ffff0007fff8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe00",
        INIT_34 => X"001ff00000fff00007ff80007ffc0003ffff000fff00001fffe00001ff80aa81",
        INIT_35 => X"ff8007ff00001ffff00001ffc0aaf1fffe0007fff0003fff8000fff80003fe00",
        INIT_36 => X"0007fff8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ff",
        INIT_37 => X"f80000fff00003ffc0007ffe0001ffff8007ff00000ffff00001ffc0aa81ffff",
        INIT_38 => X"0fff00001fffe00001ff80aa81ffff0007fff8001fffc0007ffc0003ff00001f",
        INIT_39 => X"fff0003fff8000fff80003fe00001ff00000fff00007ff80007ffc0003ffff00",
        INIT_3A => X"00fff00003ffc0007ffe0001ffff8007ff00000ffff00001ffc0aaf1fffe0007",
        INIT_3B => X"00001fffe00001ff80aa81ffff0007fff8003fffc0007ff80003ff00001ff800",
        INIT_3C => X"003fff8000fff80003fe00001ff00000fff00007ff80007ffc0003ffff000fff",
        INIT_3D => X"f00003ffc0007ffe0001ffff0007ff00001ffff00001ffc0aaf1fffe0007fff0",
        INIT_3E => X"1fffe00001ff80aaf1ffff0007fff0003fffc000fff80003fe00001ff80000ff",
        INIT_3F => X"ff8000fff80003fe00003ff00001ffe00007ff80007ffc0003ffff000fff0000",
        -- The next set of INIT_xx are valid when configured as 36Kb
        INIT_40 => X"03ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1fffe0007fff0003f",
        INIT_41 => X"f00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00001ff80000fff000",
        INIT_42 => X"007ffc0003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00000fff",
        INIT_43 => X"c0007ffe0001ffff8007ff00000ffff00001ffc0aa81ffff0007fff8001fffc0",
        INIT_44 => X"01ff80aa80ffff0007fff8001fffc0007ffc0003ff00001ff80000fff00003ff",
        INIT_45 => X"f80003fe00001ff80000fff00003ffc0007ffe0001ffff000fff00001ffff000",
        INIT_46 => X"7ffc0003ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc0007f",
        INIT_47 => X"80aaf1fffe0007fff0003fff8000fff80003fe00003ff00001ffe00007ff8000",
        INIT_48 => X"03fe00001ff00000fff00007ff80007ffc0003ffff000fff00001fffe00001ff",
        INIT_49 => X"0001ffff8007ff00001ffff00001ff80aaf1fffe0007fff0003fffc000fff800",
        INIT_4A => X"f1ffff0007fff0003fffc0007ff80003fe00001ff80000fff00003ffc0007ffe",
        INIT_4B => X"00001ff80000fff00003ffc0003ffe0001ffff8007ff00000ffff00001ffc0aa",
        INIT_4C => X"ffff000fff00001fffe00001ff80aa80ffff0007fff8001fffc0007ffc0003ff",
        INIT_4D => X"fe0007fff0003fff8000fff80003fe00001ff00000fff00007ff80007ffc0003",
        INIT_4E => X"1ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1ff",
        INIT_4F => X"000fff00001fffe00001ff80aaf1ffff0007fff8003fffc0007ff80003ff0000",
        INIT_50 => X"07fff0003fff8000fff80003fe00003ff00001ffe00007ff80007ffc0003ffff",
        INIT_51 => X"0000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1fffe00",
        INIT_52 => X"ff00001ffff00001ffc0aaf1ffff0007fff8003fffc0007ff80003ff00001ff8",
        INIT_53 => X"f8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007",
        INIT_54 => X"fff00007ff80007ffc0003ffff000fff00001fffe00001ff80aa81ffff0007ff",
        INIT_55 => X"001fffe00001ff80aaf1fffe0007fff0003fff8000fff80003fe00001ff00000",
        INIT_56 => X"3fff8000fff80003fe00003ff00001ffe00007ff80007ffc0003ffff000ffe00",
        INIT_57 => X"0003ffc0007ffe0001ffff8007ff00000ffff00001ffc0aaf1fffe0007fff000",
        INIT_58 => X"fff00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00001ff80000fff0",
        INIT_59 => X"c0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00000f",
        INIT_5A => X"ffc0007ffe0001ffff000fff00001ffff00001ff80aa81ffff0007fff8003fff",
        INIT_5B => X"0001ffc0aaf1ffff0007fff0003fffc0007ff80003fe00001ff80000fff00003",
        INIT_5C => X"7ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00001ffff0",
        INIT_5D => X"007ffe0001ffff8007ff00000ffff00001ffc0aa81ffff0007fff8003fffc000",
        INIT_5E => X"ff80aa81ffff0007fff8001fffc0007ffc0003ff00001ff80000fff00003ffc0",
        INIT_5F => X"0003fe00001ff00000fff00003ffc0007ffe0001ffff000fff00001ffff00001",
        INIT_60 => X"fc0003ffff000fff00001fffe00001ff80aaf1ffff0007fff0003fffc000fff8",
        INIT_61 => X"aaf1fffe0007fff0003fff8000fff80003fe00001ff00000fff00007ff80007f",
        INIT_62 => X"fe00001ff80000fff00003ffc0007ffe0001ffff000fff00001ffff00001ff80",
        INIT_63 => X"01ffff8007ff00000ffff00001ffc0aaf1ffff0007fff0003fffc0007ff80003",
        INIT_64 => X"ffff0007fff8003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe00",
        INIT_65 => X"001ff80000fff00003ffc0003ffe0001ffff8007ff00000ffff00000ffc0aa81",
        INIT_66 => X"ff8007ff00001ffff00001ffc0aa80ffff0007fff8001fffc0007ffc0001ff00",
        INIT_67 => X"0007fff0003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ff",
        INIT_68 => X"f80000fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1ffff",
        INIT_69 => X"07ff00001ffff00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00001f",
        INIT_6A => X"fff0003fffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff80",
        INIT_6B => X"00fff00003ffc0007ffe0001ffff8007ff00001ffff00001ffc0aaf1ffff0007",
        INIT_6C => X"00000ffff00001ffc0aaf1ffff0007fff0003fffc0007ff80003fe00001ff800",
        INIT_6D => X"001fffc0007ffc0003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff",
        INIT_6E => X"f00003ffc0007ffe0001ffff8007ff00000ffff00001ffc0aa80ffff0007fff8",
        INIT_6F => X"1ffff00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00001ff80000ff",
        INIT_70 => X"ffc0007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff0000",
        INIT_71 => X"03ffc0007ffe0001ffff8007ff80000ffff00000ffc0aa81ffff0007fff8003f",
        INIT_72 => X"1fffe00001ff80aafe001ffff0007fff8000fff80003ff00001ff00000fff000",
        INIT_73 => X"ff8000fff80003fe00001ff00000fff00007ff80007ffc0003ffff000fff0000",
        INIT_74 => X"03ffc0007ffe0001ffff8007ff00000ffff00001ffc0aaf1fffe0007fff0003f",
        INIT_75 => X"f00001ffc0aa81ffff0007fff8003fffc0007ff80003ff00001ff80000fff000",
        INIT_76 => X"007ff80003ff00001ff80000fff00003ffc0007ffe0001ffff8007ff00001fff",
        INIT_77 => X"c0007ffe0001ffff8007ff00001ffff00001ffc0aa81ffff0007fff8003fffc0",
        INIT_78 => X"ffffffaaf1ffff0007fff0003fffc0007ff80003ff00001ff80000fff00003ff",
        INIT_79 => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7A => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7B => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7C => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7D => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7E => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        INIT_7F => X"ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff",
        -- The next set of INITP_xx are for the parity bits
        INITP_00 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_01 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_02 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_03 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_04 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_05 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_06 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_07 => X"0000000000000000000000000000000000000000000000000000000000000000",
        -- The next set of INIT_xx are valid when configured as 36Kb
        INITP_08 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_09 => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0A => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0B => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INITP_0F => X"0000000000000000000000000000000000000000000000000000000000000000"
    )

    port map (
        DOA => data_out,             -- Output port-A data, width defined by READ_WIDTH_A parameter
        DOB => open,             -- Output port-B data, width defined by READ_WIDTH_B parameter
        ADDRA => addr_in,         -- Input port-A address, width defined by Port A depth
        ADDRB => "000000000000",         -- Input port-B address, width defined by Port B depth
        CLKA => clk_in,           -- 1-bit input port-A clock
        CLKB => clk_in,           -- 1-bit input port-B clock
        DIA => (others => '0'),             -- Input port-A data, width defined by WRITE_WIDTH_A parameter
        DIB => (others => '0'),             -- Input port-B data, width defined by WRITE_WIDTH_B parameter
        ENA => '1',             -- 1-bit input port-A enable
        ENB => '0',             -- 1-bit input port-B enable
--        REGCEA => REGCEA_in,       -- 1-bit input port-A output register enable
--        REGCEB => REGCEB_in,       -- 1-bit input port-B output register enable
        REGCEA => '0',       -- 1-bit input port-A output register enable
        REGCEB => '0',       -- 1-bit input port-B output register enable
        RSTA => '0',           -- 1-bit input port-A reset
        RSTB => '0',           -- 1-bit input port-B reset
        WEA => "0",             -- Input port-A write enable, width defined by Port A depth
        WEB => "0"              -- Input port-B write enable, width defined by Port B depth
    );


end Behavioral;
