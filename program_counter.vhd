library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity program_counter is
  port(clk: in std_logic;
       rst: in std_logic;
       input: in std_logic_vector(31 downto 0);
       output: out std_logic_vector(31 downto 0));
end program_counter;

architecture comportamiento of program_counter is
  
  signal cont: std_logic_vector(31 downto 0);

  begin
    Pcont: process(clk,rst)
    begin
    if(rst='1') then
      cont <= (others => '0');
    elsif(clk' event and clk='1') then
      cont <= input;
    end if;
  end process;

output <= cont;

end comportamiento;