library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity adder is
  port(input_1: in std_logic_vector(31 downto 0);
       input_2: in std_logic_vector(31 downto 0);
       output: out std_logic_vector(31 downto 0));
end adder;

architecture comportamiento of adder is
  begin
  output <= input_1 + input_2;
end comportamiento;
