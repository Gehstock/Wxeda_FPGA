--
-- keymatrix.vhd
--
-- Convert from PS/2 key-matrix to MZ-700 key-matrix module
-- for MZ-700 on FPGA
--
-- Nibbles Lab. 2005
--

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity keymatrix is
    Port ( RST : in std_logic;
    		 PA : in std_logic_vector(3 downto 0);
           PB : out std_logic_vector(7 downto 0);
           KCLK : in std_logic;
		 LDDAT : out std_logic_vector(7 downto 0);
		 PS2CK : in std_logic;
		 PS2DT : in std_logic);
end keymatrix;

architecture Behavioral of keymatrix is

--
-- PS/2 Interface
--
signal KBDT : std_logic_vector(7 downto 0);
signal KBEN : std_logic;
signal EN : std_logic;
--
-- prefix flag
--
signal FLGF0 : std_logic;
signal FLGE0 : std_logic;
--
-- MZ-700 matrix registers
--
signal SCAN01 : std_logic_vector(7 downto 0);
signal SCAN02 : std_logic_vector(7 downto 0);
signal SCAN03 : std_logic_vector(7 downto 0);
signal SCAN04 : std_logic_vector(7 downto 0);
signal SCAN05 : std_logic_vector(7 downto 0);
signal SCAN06 : std_logic_vector(7 downto 0);
signal SCAN07 : std_logic_vector(7 downto 0);
signal SCAN08 : std_logic_vector(7 downto 0);
signal SCAN09 : std_logic_vector(7 downto 0);
signal SCAN10 : std_logic_vector(7 downto 0);

--
-- Components
--
component ps2kb
    Port ( RST : in std_logic;
    		 KCLK : in std_logic;
    		 PS2CK : in std_logic;
           PS2DT : in std_logic;
           DTEN : out std_logic;
           DATA : out std_logic_vector(7 downto 0));
end component;

begin

	--
	-- Instantiation
	--
	PS2RCV : ps2kb port map (
			RST => RST,
			KCLK => KCLK,
			PS2CK => PS2CK,
			PS2DT => PS2DT,
			DTEN => KBEN,
			DATA => KBDT);

	--
	-- Convert
	--
	process( KCLK ) begin
		if( KCLK'event and KCLK='1' ) then
			if( KBEN='1' ) then
				LDDAT<=KBDT;
				case KBDT is								 
					when X"09"|X"07" => SCAN01(7)<=not FLGF0; FLGF0<='0'; -- KANA
					when X"0E" => SCAN01(6)<=not FLGF0; FLGF0<='0'; -- GRAPH
					when X"01"|X"78" => SCAN01(5)<=not FLGF0; FLGF0<='0'; -- =
					when X"0D" => SCAN01(4)<=not FLGF0; FLGF0<='0'; -- EISUU
					when X"4C" => SCAN01(2)<=not FLGF0; FLGF0<='0'; -- ;
					when X"52" => SCAN01(1)<=not FLGF0; FLGF0<='0'; -- :
					when X"5A" => SCAN01(0)<=not FLGF0; FLGF0<='0'; -- CR
					when X"35" => SCAN02(7)<=not FLGF0; FLGF0<='0'; -- Y
					when X"1A" => SCAN02(6)<=not FLGF0; FLGF0<='0'; -- Z
					when X"54" => SCAN02(5)<=not FLGF0; FLGF0<='0'; -- @
					when X"5B" => SCAN02(4)<=not FLGF0; FLGF0<='0'; -- (
					when X"5D" => SCAN02(3)<=not FLGF0; FLGF0<='0'; -- )
					when X"15" => SCAN03(7)<=not FLGF0; FLGF0<='0'; -- Q
					when X"2D" => SCAN03(6)<=not FLGF0; FLGF0<='0'; -- R
					when X"1B" => SCAN03(5)<=not FLGF0; FLGF0<='0'; -- S
					when X"2C" => SCAN03(4)<=not FLGF0; FLGF0<='0'; -- T
					when X"3C" => SCAN03(3)<=not FLGF0; FLGF0<='0'; -- U
					when X"2A" => SCAN03(2)<=not FLGF0; FLGF0<='0'; -- V
					when X"1D" => SCAN03(1)<=not FLGF0; FLGF0<='0'; -- W
					when X"22" => SCAN03(0)<=not FLGF0; FLGF0<='0'; -- X
					when X"43" => SCAN04(7)<=not FLGF0; FLGF0<='0'; -- I
					when X"3B" => SCAN04(6)<=not FLGF0; FLGF0<='0'; -- J
					when X"42" => SCAN04(5)<=not FLGF0; FLGF0<='0'; -- K
					when X"4B" => SCAN04(4)<=not FLGF0; FLGF0<='0'; -- L
					when X"3A" => SCAN04(3)<=not FLGF0; FLGF0<='0'; -- M
					when X"31" => SCAN04(2)<=not FLGF0; FLGF0<='0'; -- N
					when X"44" => SCAN04(1)<=not FLGF0; FLGF0<='0'; -- O
					when X"4D" => SCAN04(0)<=not FLGF0; FLGF0<='0'; -- P
					when X"1C" => SCAN05(7)<=not FLGF0; FLGF0<='0'; -- A
					when X"32" => SCAN05(6)<=not FLGF0; FLGF0<='0'; -- B
					when X"21" => SCAN05(5)<=not FLGF0; FLGF0<='0'; -- C
					when X"23" => SCAN05(4)<=not FLGF0; FLGF0<='0'; -- D
					when X"24" => SCAN05(3)<=not FLGF0; FLGF0<='0'; -- E
					when X"2B" => SCAN05(2)<=not FLGF0; FLGF0<='0'; -- F
					when X"34" => SCAN05(1)<=not FLGF0; FLGF0<='0'; -- G
					when X"33" => SCAN05(0)<=not FLGF0; FLGF0<='0'; -- H
					when X"16" => SCAN06(7)<=not FLGF0; FLGF0<='0'; -- 1
					when X"1E" => SCAN06(6)<=not FLGF0; FLGF0<='0'; -- 2
					when X"26" => SCAN06(5)<=not FLGF0; FLGF0<='0'; -- 3
					when X"25" => SCAN06(4)<=not FLGF0; FLGF0<='0'; -- 4
					when X"2E" => SCAN06(3)<=not FLGF0; FLGF0<='0'; -- 5
					when X"36" => SCAN06(2)<=not FLGF0; FLGF0<='0'; -- 6
					when X"3D" => SCAN06(1)<=not FLGF0; FLGF0<='0'; -- 7
					when X"3E" => SCAN06(0)<=not FLGF0; FLGF0<='0'; -- 8
					when X"6A" => SCAN07(7)<=not FLGF0; FLGF0<='0'; -- *
					when X"55" => SCAN07(6)<=not FLGF0; FLGF0<='0'; -- +
					when X"4E" => SCAN07(5)<=not FLGF0; FLGF0<='0'; -- -
					when X"29" => SCAN07(4)<=not FLGF0; FLGF0<='0'; -- ' '
					when X"45" => SCAN07(3)<=not FLGF0; FLGF0<='0'; -- 0
					when X"46" => SCAN07(2)<=not FLGF0; FLGF0<='0'; -- 9
					when X"41" => SCAN07(1)<=not FLGF0; FLGF0<='0'; -- ,
					when X"49" => SCAN07(0)<=not FLGF0; FLGF0<='0'; -- .
					when X"70" => SCAN08(7)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- INST
					when X"71" => SCAN08(6)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- DEL
					when X"75" => SCAN08(5)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- UP
					when X"72" => SCAN08(4)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- DOWN
					when X"74" => SCAN08(3)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- RIGHT
					when X"6B" => SCAN08(2)<=not FLGF0; FLGF0<='0'; FLGE0<='0'; -- LEFT
					when X"51" => SCAN08(1)<=not FLGF0; FLGF0<='0'; -- ?
					when X"4A" => SCAN08(0)<=not FLGF0; FLGF0<='0'; -- /
					when X"66" => SCAN09(7)<=not FLGF0; FLGF0<='0'; -- BREAK
					when X"58" => SCAN09(6)<=not FLGF0; FLGF0<='0'; -- CTRL
					when X"12"|X"59" => SCAN09(0)<=((not FLGF0) and (not FLGE0)) or (SCAN09(0) and FLGE0); FLGF0<='0'; FLGE0<='0'; -- SHIFT
					when X"05" => SCAN10(7)<=not FLGF0; FLGF0<='0'; -- F1
					when X"06" => SCAN10(6)<=not FLGF0; FLGF0<='0'; -- F2
					when X"04" => SCAN10(5)<=not FLGF0; FLGF0<='0'; -- F3
					when X"0C" => SCAN10(4)<=not FLGF0; FLGF0<='0'; -- F4
					when X"03" => SCAN10(3)<=not FLGF0; FLGF0<='0'; -- F5
					when X"F0" => FLGF0<='1';
					when X"E0" => FLGE0<='1';
					when others => FLGF0<='0'; FLGE0<='0';
				end case;
			end if;
		end if;
	end process;

	--
	-- response from key access
	--
	PB<=(not SCAN01) when PA="0000" else
	    (not SCAN02) when PA="0001" else
	    (not SCAN03) when PA="0010" else
	    (not SCAN04) when PA="0011" else
	    (not SCAN05) when PA="0100" else
	    (not SCAN06) when PA="0101" else
	    (not SCAN07) when PA="0110" else
	    (not SCAN08) when PA="0111" else
	    (not SCAN09) when PA="1000" else
	    (not SCAN10) when PA="1001" else (others=>'1');

end Behavioral;
