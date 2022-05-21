
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
-- Mem interface for negative signal for HEIST
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
entity neg_sig_bram_mem_interface is
    Port ( clk_in           : in STD_LOGIC;
           addr_in          : in STD_LOGIC_VECTOR (11 downto 0);
           data_out         : out STD_LOGIC_VECTOR (7 downto 0));
end neg_sig_bram_mem_interface;

architecture Behavioral of neg_sig_bram_mem_interface is

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

-- 0x7A + 1 = 123 + ; 123 * 32 + 8 -1 = 3943 -> 111101100111 LAST ADDR

        -- The following INIT_xx declarations specify the initial contents of the RAM
        INIT_00 => X"01fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc00007ff03fffff",
        INIT_01 => X"3fffe000ffe00003fffc00003ff83fffffaa07000000ff000007e000001e0000",
        INIT_02 => X"ffffaa030000007f000003f000001f000000fc00000ffc00003ff00007ffc000",
        INIT_03 => X"000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007ff03f",
        INIT_04 => X"c0003fffe000ffe00003fffe00003ff81fffffaa07000000ff000007e000001e",
        INIT_05 => X"f03fffffaa038000007f800003f000001f000000fc00000ffc00003ff00003ff",
        INIT_06 => X"001e000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007f",
        INIT_07 => X"07ffc0003fffe000ffe00003fffc00007ff03fffffaa07000000ff000007e000", 
        INIT_08 => X"003ff83fffffaa07000000ff000007e000001e000001fc00000ffc00007ff000",
        INIT_09 => X"f000001f000000fc00000ffc00003ff00003ffc0003fffe000ffe00003fffc00",
        INIT_0A => X"f00007ffc0003fffe000ffe00003fffc00003ff03fffffaa038000007f800003",
        INIT_0B => X"fe00003ff83fffffaa030000007f000003f000001f000000fc00000ffc00007f",
        INIT_0C => X"0003f000001f000000fc00000ffc00003ff00003ffc0001fffe000ffe00003ff",
        INIT_0D => X"007ff00007ffc0003fffe000ffe00003fffc00007ff03fffffaa038000007f80",
        INIT_0E => X"03fffc00007ff03fffffaa07000000ff000007e000001e000001fc00000ffc00",
        INIT_0F => X"7f000003e000001e000000fc00000ffc00007ff00007ffc0003fffe000ffe000",
        INIT_10 => X"f800007fe00007ff80003fffe001ffc00007fffc00007ff03fffffaa07000000",
        INIT_11 => X"e00003fffc00007ff03fffffaa07000000ff000007e000003e000001fc00001f",
        INIT_12 => X"0000ff000007e000001e000001fc00001ffc00007fe00007ff80003fffe001ff",
        INIT_13 => X"000ffc00007ff00007ffc0003fffe000ffe00003fffc00007ff03fffffaa0700",
        INIT_14 => X"00ffe00003fffe00003ff83fffffaa070000007f000003e000001e000000fc00",
        INIT_15 => X"038000007f800003f000001f000000fc00000ffc00003ff00003ffc0001fffe0",
        INIT_16 => X"fc00000ffc00003ff00003ffc0001ffff000ffe00003fffe00003ff81fffffaa",
        INIT_17 => X"ffe000ffe00003fffc00007ff03fffffaa038000007f800003f000001f000000",
        INIT_18 => X"ffaa07000000ff000007e000001e000001fc00000ffc00007ff00007ffc0003f",
        INIT_19 => X"0001fc00001ffc00007fe00007ff80003fffe001ffe00007fffc00007ff03fff",
        INIT_1A => X"003fffe001ffe00003fffc00007ff03fffffaa07000000ff000007e000001e00",
        INIT_1B => X"3fffffaa07000000ff000007e000001e000001fc00000ffc00007fe00007ffc0",
        INIT_1C => X"1f000000fc00000ffc00003ff00003ffc0003fffe000ffe00003fffe00003ff8",
        INIT_1D => X"ffc0003fffe000ffe00003fffc00007ff03fffffaa030000007f800003f00000",
        INIT_1E => X"7ff03fffffaa070000007f000007e000001e000001fc00000ffc00007ff00007",
        INIT_1F => X"00001e000001fc00000ffc00007fe00007ffc0003fffe000ffe00003fffc0000",
        INIT_20 => X"0003ffc0001fffe000ffe00003fffe00003ff81fffffaa07000000ff000007e0",
        INIT_21 => X"00007ff03fffffaa038000007f800003f000001f000000fc00000ffc00003ff0",
        INIT_22 => X"07e000001e000001fc00001ffc00007fe00007ff80003fffe001ffe00003fffc",
        INIT_23 => X"3ff00003ffc0003fffe000ffe00003fffc00003ff83fffffaa07000000ff0000",
        INIT_24 => X"fffc00003ff03fffffaa038000007f800003f000001f000000fc00000ffc0000",
        INIT_25 => X"000003f000001f000000fc00000ffc00007ff00007ffc0003fffe000ffe00003",
        INIT_26 => X"00007ff00007ffc0003fffe000ffe00003fffc00003ff03fffffaa070000007f",
        INIT_27 => X"0003fffc00003ff83fffffaa070000007f000003f000001f000000fc00000ffc",
        INIT_28 => X"007f000003f000001f000000fc00000ffc00007ff00007ffc0003fffe000ffe0",
        INIT_29 => X"0ffc00007ff00007ffc0003fffe000ffe00003fffc00003ff03fffffaa030000",
        INIT_2A => X"ffe00007fffc00007ff03fffffaa070000007f000003f000001f000000fc0000",
        INIT_2B => X"000000ff000007e000001e000001fc00001ff800007fe00007ff80003fffe001",
        INIT_2C => X"00001ff800007fe00007ff80003fffe001ffe00007fffc00007ff03fffffaa07",
        INIT_2D => X"e001ffe00003fffc00007ff03fffffaa07000000ff000007e000001e000001fc",
        INIT_2E => X"aa07000000ff000007e000001e000001fc00000ffc00007fe00007ffc0003fff",
        INIT_2F => X"00fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc00003ff83fffff",
        INIT_30 => X"3fffe000ffe00003fffc00003ff03fffffaa030000007f000003f000001f0000",
        INIT_31 => X"ffffaa030000007f000003f000001f000000fc00000ffc00007ff00007ffc000",
        INIT_32 => X"000000fe00000ffc00003ff00003ffc0001ffff000ffe00003fffe00003ff81f",
        INIT_33 => X"c0003fffe000ffe00003fffc00003ff83fffffaa038000007f800003f000001f",
        INIT_34 => X"f03fffffaa030000007f000003f000001f000000fc00000ffc00007ff00007ff",
        INIT_35 => X"001e000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007f",
        INIT_36 => X"07ffc0003fffe000ffe00003fffc00003ff03fffffaa07000000ff000007e000",
        INIT_37 => X"007ff03fffffaa070000007f000003f000001f000000fc00000ffc00007ff000",
        INIT_38 => X"e000001e000001fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc00",
        INIT_39 => X"e00007ffc0003fffe001ffe00003fffc00007ff03fffffaa070000007f000007",
        INIT_3A => X"fe00003ff83fffffaa07000000ff000007e000001e000001fc00000ffc00007f",
        INIT_3B => X"0003f000001f000000fc00000ffc00003ff00003ffc0003fffe000ffe00003ff",
        INIT_3C => X"007fe00007ffc0003fffe000ffe00003fffc00007ff03fffffaa030000007f80",
        INIT_3D => X"07fffc00007ff03fffffaa07000000ff000007e000001e000001fc00000ffc00",
        INIT_3E => X"ff000007e000001e000001fc00001ff800007fe00007ff80003fffe001ffc000",
        INIT_3F => X"fc00003ff00003ffc0001fffe000ffe00003fffe00003ff81fffffaa07000000",
        -- The next set of INIT_xx are valid when configured as 36Kb
        INIT_40 => X"e00003fffe00003ff83fffffaa038000007f800003f000001f000000fc00000f",
        INIT_41 => X"00007f800003f000001f000000fc00000ffc00003ff00003ffc0003fffe000ff",
        INIT_42 => X"000ffc00003ff00003ffc0003fffe000ffe00003fffe00003ff83fffffaa0300",
        INIT_43 => X"01ffe00003fffc00007ff03fffffaa038000007f800003f000001f000000fc00",
        INIT_44 => X"07000000ff000007e000001e000001fc00000ffc00007fe00007ffc0003fffe0",
        INIT_45 => X"fc00000ffc00003ff00003ffc0001fffe000ffe00003fffe00003ff81fffffaa",
        INIT_46 => X"ffe001ffe00003fffc00007ff03fffffaa038000007f800003f000001f000000",
        INIT_47 => X"ffaa07000000ff000007e000001e000001fc00001ffc00007fe00007ffc0003f",
        INIT_48 => X"0001fc00001ff800007fe00007ff80003fffe001ffc00007fffc00007ff03fff",
        INIT_49 => X"003fffe000ffe00003fffc00003ff03fffffaa07000000ff000007e000001e00",
        INIT_4A => X"3fffffaa030000007f000003f000001f000000fc00000ffc00007ff00007ffc0",
        INIT_4B => X"1e000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007ff0",
        INIT_4C => X"ffc0003fffe000ffe00003fffc00007ff03fffffaa07000000ff000007e00000",
        INIT_4D => X"7ff03fffffaa07000000ff000007e000001e000001fc00000ffc00007ff00007",
        INIT_4E => X"00001f000000fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc0000",
        INIT_4F => X"0003ffc0001fffe000ffe00003fffe00003ff81fffffaa070000007f000007f0",
        INIT_50 => X"00003ff03fffffaa038000007f800003f000001f000000fc00000ffc00003ff0",
        INIT_51 => X"07e000001f000000fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc",
        INIT_52 => X"7ff00007ffc0003fffe000ffe00003fffc00003ff03fffffaa070000007f0000",
        INIT_53 => X"fffc00003ff83fffffaa070000007f000003f000001f000000fc00000ffc0000",
        INIT_54 => X"000003f000001f000000fc00000ffc00003ff00007ffc0003fffe000ffe00003",
        INIT_55 => X"00007fe00007ff80003fffe001ffc00007fffc00007ff03fffffaa030000007f",
        INIT_56 => X"0003fffc00007ff03fffffaa07000000ff000007e000001e000001fc00001ff8",
        INIT_57 => X"00ff000007e000001e000001fc00001ff800007fe00007ff80003fffe001ffe0",
        INIT_58 => X"0ffc00007fe00007ffc0003fffe001ffe00003fffc00007ff03fffffaa070000",
        INIT_59 => X"ffe00003fffc00007ff03fffffaa07000000ff000007e000001e000001fc0000",
        INIT_5A => X"000000ff000007e000001e000001fc00000ffc00007fe00007ffc0003fffe001",
        INIT_5B => X"00000ffc00007fe00007ffc0003fffe000ffe00003fffc00007ff03fffffaa07",
        INIT_5C => X"e000ffe00003fffc00007ff03fffffaa07000000ff000007e000001e000001fc",
        INIT_5D => X"aa070000007f000007e000001f000001fc00000ffc00007ff00007ffc0003fff",
        INIT_5E => X"01fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007ff03fffff",
        INIT_5F => X"3fffe000ffe00003fffc00003ff83fffffaa07000000ff000007e000001e0000",
        INIT_60 => X"ffffaa030000007f800003f000001f000000fc00000ffc00003ff00003ffc000",
        INIT_61 => X"000001fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc00007ff03f",
        INIT_62 => X"80003fffe001ffe00007fffc00007ff03fffffaa07000000ff000007e000001e",
        INIT_63 => X"f03fffffaa07000000ff000007e000001e000001fc00001ffc00007fe00007ff",
        INIT_64 => X"001e000001fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc00007f",
        INIT_65 => X"03ffc0003fffe000ffe00003fffe00003ff81fffffaa07000000ff000007e000",
        INIT_66 => X"007ff03fffffaa030000007f800003f000001f000000fc00000ffc00003ff000",
        INIT_67 => X"e000001e000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00",
        INIT_68 => X"e00007ffc0003fffe001ffe00003fffc00007ff03fffffaa07000000ff000007",
        INIT_69 => X"fc00003ff03fffffaa07000000ff000007e000001e000001fc00000ffc00007f",
        INIT_6A => X"0003f000001f000000fc00000ffc00007ff00007ffc0003fffe000ffe00003ff",
        INIT_6B => X"007ff00007ffc0003fffe000ffe00003fffc00007ff03fffffaa070000007f00",
        INIT_6C => X"03fffe00003ff81fffffaa07000000ff000007e000001e000001fc00000ffc00",
        INIT_6D => X"fc000007e000001f000000fc00000ffc00003ff00003ffc0001ffff000ffe000",
        INIT_6E => X"fc00000ffc00003ff00003ffc0001fffe000ffe00003fffe00003ff83fffffaa",
        INIT_6F => X"fff000ffe00003fffe00003ff81fffffaa030000007f000003f000001f000000",
        INIT_70 => X"ffaa038000007f800003f000001f000000fe00000ffc00003ff00003ffc0001f",
        INIT_71 => X"0000fc00000ffc00003ff00007ffc0003fffe000ffe00003fffc00003ff83fff",
        INIT_72 => X"003fffe000ffe00003fffc00003ff03fffffaa030000007f000003f000001f00",
        INIT_73 => X"3fffffaa030000007f000003f000001f000000fc00000ffc00007ff00007ffc0",
        INIT_74 => X"1e000001fc00000ffc00007fe00007ffc0003fffe001ffe00003fffc00007ff0",
        INIT_75 => X"ffc0003fffe000ffe00003fffc00003ff03fffffaa07000000ff000007e00000",
        INIT_76 => X"3ff03fffffaa070000007f000003f000001f000000fc00000ffc00007ff00007",
        INIT_77 => X"00001f000000fc00000ffc00007ff00007ffc0003fffe000ffe00003fffc0000",
        INIT_78 => X"0007ffc0003fffe000ffe00003fffc00003ff03fffffaa070000007f000003f0",
        INIT_79 => X"00007ff03fffffaa030000007f000003f000001f000000fc00000ffc00007ff0",
        INIT_7A => X"07e000001e000001fc00001ff800007fe00007ff80003fffe001ffc00007fffc",
        INIT_7B => X"000000000000000000000000000000000000000000000000aa07000000ff0000",
        INIT_7C => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7D => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7E => X"0000000000000000000000000000000000000000000000000000000000000000",
        INIT_7F => X"0000000000000000000000000000000000000000000000000000000000000000",
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
