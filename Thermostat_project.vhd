library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
entity TERMOSTAT_STATE_MASHINE is
port (
CLK            : in std_logic;
RESET          : in std_logic;
current_temp   : in std_logic_vector(6 downto 0);
desired_temp   : in std_logic_vector(6 downto 0);
display_select : in std_logic;
cool           : in std_logic;
heat           : in std_logic;
FURNACE_HOT    : in std_logic;
A_C_READY      : in std_logic;
temp_display   : out std_logic_vector(6 downto 0);
A_C_ON         : out std_logic;
FURNACE_ON     : out std_logic;
FAN_ON         : out std_logic);
end TERMOSTAT_STATE_MASHINE;
architecture BEHAV of TERMOSTAT_STATE_MASHINE is
type AC_FURNACE_STATE is (IDLE,COOLON,ACNOWREADY,ACDONE,HEATON,FURNACENOWHOT,FURNACECOOL);
signal current_state : AC_FURNACE_STATE;
signal next_state : AC_FURNACE_STATE;
signal REG_current_temp, REG_desired_temp : std_logic_vector(6 downto 0);
signal REG_display_select, REG_cool,REG_heat,REG_FURNACE_HOT,REG_A_C_READY : std_logic;
begin
process (CLK, RESET)
begin
if reset = '1' then
current_state <= IDLE;
elsif CLK'event and clk = '1' then
current_state <= next_state;
REG_current_temp <= current_temp;
REG_desired_temp <= desired_temp;
REG_display_select <= display_select;
REG_cool <= cool;
REG_heat <= heat;
REG_FURNACE_HOT <= FURNACE_HOT;
REG_A_C_READY <= A_C_READY;
end if;
end process;

process (REG_current_temp,REG_desired_temp,REG_cool,REG_heat,REG_FURNACE_HOT,REG_A_C_READY,current_state)
begin
case current_state is
when IDLE =>
if ((REG_cool = '1') and (REG_current_temp>REG_desired_temp)) then
next_state <= COOLON;
elsif ((REG_heat = '1') and (REG_current_temp<REG_desired_temp)) then
next_state <= HEATON;
else
next_state <= IDLE;
end if;
when COOLON =>
if (REG_A_C_READY = '1') then
next_state <= ACNOWREADY;
else
next_state <= COOLON;
end if;
when ACNOWREADY =>
if not((REG_cool = '1') and (REG_current_temp>REG_desired_temp)) then
next_state <= ACDONE;
else
next_state <= ACNOWREADY;
end if;
when ACDONE =>
if (REG_A_C_READY = '0') then
next_state <= IDLE;
else
next_state <= ACDONE;
end if;
when HEATON =>
if (REG_FURNACE_HOT = '1') then
next_state <= FURNACENOWHOT;
else
next_state <= HEATON;
end if;
when FURNACENOWHOT =>
if not((REG_heat = '1') and (REG_current_temp<REG_desired_temp)) then
next_state <= FURNACECOOL;
else
next_state <= FURNACENOWHOT;
end if;
when FURNACECOOL =>
if (REG_FURNACE_HOT = '0') then
next_state <= IDLE;
else
next_state <= FURNACECOOL;
end if;
when others =>
next_state <= IDLE;
end case;
end process;
A_C_ON <= '1' when next_state = COOLON or next_state = ACNOWREADY
else '0';
FURNACE_ON <= '1' when next_state = HEATON or next_state = FURNACENOWHOT
else '0';
FAN_ON <= '1' when next_state = ACNOWREADY or next_state = ACDONE
or next_state = FURNACENOWHOT or next_state = FURNACECOOL
else '0';
process (REG_current_temp,REG_desired_temp,REG_display_select)
begin
if REG_display_select = '1' then
temp_display <= REG_current_temp;
else
temp_display <= REG_desired_temp;
end if;
end process;
end BEHAV;