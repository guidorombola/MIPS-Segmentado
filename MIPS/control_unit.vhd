library ieee;
use ieee.std_logic_1164.all;

entity control_unit is
	
	Port( input: in	std_logic_vector (31 downto 0);
	      alu_src: out 	std_logic;
	      alu_op: out std_logic_vector(2 downto 0);
	      reg_dst: out 	std_logic; 
	      branch: out std_logic;
	      mem_write: out std_logic;
	      mem_read: out std_logic;
	      mem_to_reg: out std_logic;
	      reg_write: out std_logic
	      );
	      
end control_unit;

architecture comportamiento of control_unit is

begin

  generar_signals: process(input)
  begin
    if(input(31 downto 26)="000000") then --tipo R
      alu_src <= '0';
      reg_dst <= '1';
      branch <= '0';
      mem_write <= '0';
      mem_read <= '0';
      mem_to_reg <= '0';
      reg_write <= '1';                   
      if(input(5 downto 0)="100100") then --and
        alu_op <= "000";
      elsif(input(5 downto 0)="100101") then --or
        alu_op <= "001";
      elsif(input(5 downto 0)="101010") then --slt
        alu_op <= "111";
      elsif(input(5 downto 0)="100000") then --add
        alu_op <= "010";
      elsif(input(5 downto 0)="100010") then --sub
        alu_op <= "110";
      end if;
    elsif(input(31 downto 26)="100011") then  --lw
      alu_src <= '1';
      alu_op <= "010";
      reg_dst <= '0';
      branch <= '0';
      mem_write <= '0';
      mem_read <= '1';
      mem_to_reg <= '1';
      reg_write <= '1';
    elsif(input(31 downto 26)="101011") then --sw
      alu_src <= '1';
      alu_op <= "010";
      reg_dst <= '0';
      branch <= '0';
      mem_write <= '1';
      mem_read <= '0';
      mem_to_reg <= '0';
      reg_write <= '0';
    elsif(input(31 downto 26)="001111") then --lui
      alu_src <= '1';
      alu_op <= "100";
      reg_dst <= '0';
      branch <= '0';
      mem_write <= '0';
      mem_read <= '0';
      mem_to_reg <= '0';
      reg_write <= '1';
    else                                       --beq
      alu_src <= '1';
      alu_op <= "110";
      reg_dst <= '0';
      branch <= '1';
      mem_write <= '0';
      mem_read <= '0';
      mem_to_reg <= '0';
      reg_write <= '0';
    end if;
  end process;

end comportamiento;