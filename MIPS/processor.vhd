library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity processor is
port(
	Clk         : in  std_logic;
	Reset       : in  std_logic;
	-- Instruction memory
	I_Addr      : out std_logic_vector(31 downto 0);
	I_RdStb     : out std_logic;
	I_WrStb     : out std_logic;
	I_DataOut   : out std_logic_vector(31 downto 0);
	I_DataIn    : in  std_logic_vector(31 downto 0);
	-- Data memory
	D_Addr      : out std_logic_vector(31 downto 0);
	D_RdStb     : out std_logic;
	D_WrStb     : out std_logic;
	D_DataOut   : out std_logic_vector(31 downto 0);
	D_DataIn    : in  std_logic_vector(31 downto 0)
);
end processor;

architecture processor_arq of processor is 

--declaracion de componentes--

component registers
  Port (clk : in std_logic;
        reset : in std_logic;
        wr : in std_logic;
        reg1_dr : in std_logic_vector (4 downto 0);
        reg2_dr : in std_logic_vector (4 downto 0);
        reg_wr : in std_logic_vector(4 downto 0);
        data_wr : in std_logic_vector (31 downto 0);
        data1_rd : out std_logic_vector (31 downto 0);
        data2_rd : out std_logic_vector (31 downto 0));
end component;

component control_unit
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
end component;

component alu
  Port ( a : in STD_LOGIC_VECTOR (31 downto 0);
           b : in STD_LOGIC_VECTOR (31 downto 0);
           control : in STD_LOGIC_VECTOR (2 downto 0);
           zero : out STD_LOGIC;
           result : out STD_LOGIC_VECTOR (31 downto 0));
end component;

component sign_extender
   port(input: in std_logic_vector(15 downto 0);
       output: out std_logic_vector(31 downto 0));
end component;

component adder
  port(input_1: in std_logic_vector(31 downto 0);
       input_2: in std_logic_vector(31 downto 0);
       output: out std_logic_vector(31 downto 0));
end component;

component program_counter
  port(clk: in std_logic;
       rst: in std_logic;
       input: in std_logic_vector(31 downto 0);
       output: out std_logic_vector(31 downto 0));
end component;

--declaracion de seniales--

--signal write_register: std_logic_vector(4 downto 0);

signal salida_mux_if: std_logic_vector(31 downto 0);
signal salida_p_cont_if: std_logic_vector(31 downto 0);
signal salida_adder_if: std_logic_vector(31 downto 0);
signal counter_if: std_logic_vector(31 downto 0);

signal counter_id: std_logic_vector(31 downto 0);
signal reg_if_id_im_out: std_logic_vector(31 downto 0);
signal ins_15_0_id: std_logic_vector(15 downto 0);
signal ins_15_0_extended_id: std_logic_vector(31 downto 0);
signal ins_20_16_id: std_logic_vector(4 downto 0);
signal ins_15_11_id: std_logic_vector(4 downto 0);
signal read_data_1_id: std_logic_vector(31 downto 0);
signal read_data_2_id: std_logic_vector(31 downto 0);

signal counter_ex: std_logic_vector(31 downto 0);
signal ins_15_0_shifted_extended_ex: std_logic_vector(31 downto 0);
signal ins_15_0_extended_ex: std_logic_vector(31 downto 0);
signal ins_20_16_ex: std_logic_vector(4 downto 0);
signal ins_15_11_ex: std_logic_vector(4 downto 0);
signal salida_mux_reg_dst_ex: std_logic_vector(4 downto 0);
signal salida_mux_alu_src_ex: std_logic_vector(31 downto 0);
signal read_data_1_ex: std_logic_vector(31 downto 0);
signal read_data_2_ex: std_logic_vector(31 downto 0);
signal result_alu_ex: std_logic_vector(31 downto 0);
signal zero_alu_ex: std_logic;
signal add_result_ex: std_logic_vector(31 downto 0);

signal result_alu_mem: std_logic_vector(31 downto 0);
signal zero_alu_mem: std_logic;
signal read_data_2_mem: std_logic_vector(31 downto 0);
signal reg_rd_or_rt_mem: std_logic_vector(4 downto 0);
signal add_result_mem: std_logic_vector(31 downto 0);

signal result_alu_wb: std_logic_vector(31 downto 0);
signal reg_rd_or_rt_wb: std_logic_vector(4 downto 0);
 

--seniales de control
signal alu_src_id: std_logic;
signal alu_op_id: std_logic_vector(2 downto 0);
signal reg_dst_id: std_logic; 
signal branch_id: std_logic;
signal mem_write_id: std_logic;
signal mem_read_id: std_logic;
signal mem_to_reg_id: std_logic;
signal reg_write_id: std_logic;

signal alu_src_ex: std_logic;
signal alu_op_ex: std_logic_vector(2 downto 0);
signal reg_dst_ex: std_logic; 
signal branch_ex: std_logic;
signal mem_write_ex: std_logic;
signal mem_read_ex: std_logic;
signal mem_to_reg_ex: std_logic;
signal reg_write_ex: std_logic;

signal branch_mem: std_logic;
signal mem_write_mem: std_logic;
signal mem_read_mem: std_logic;
signal reg_write_mem: std_logic;
signal mem_to_reg_mem: std_logic;
signal pc_src_mem: std_logic;
signal read_data_mem: std_logic_vector(31 downto 0);

signal mem_to_reg_wb: std_logic;
signal reg_write_wb: std_logic;
signal read_data_wb: std_logic_vector(31 downto 0);
signal salida_mux_mem_to_reg_wb: std_logic_vector(31 downto 0);


  
begin 	

I_RdStb <= '1';
I_WrStb <= '0';

adder_if: adder port map(input_1 => salida_p_cont_if,
                         input_2 => x"00000004",
                         output => salida_adder_if

);

--mux regido por pc_src--
with pc_src_mem select
  salida_mux_if <= salida_adder_if when '0',
                    result_alu_mem when others;
  
pcont_if: program_counter port map(input => salida_mux_if,
                                   output => salida_p_cont_if,
                                   clk => Clk,
                                   rst => Reset
);

I_Addr <= salida_p_cont_if;

reg_if_id: process(Clk, Reset)
  begin
    if Reset = '1' then
      reg_if_id_im_out <= (others => '0');
    elsif(Clk' event and Clk = '1') then
      reg_if_id_im_out <= I_DataIn;
      counter_if <= salida_adder_if;
    end if;
  end process;

ins_15_0_id <= reg_if_id_im_out(15 downto 0);
ins_20_16_id <= reg_if_id_im_out(20 downto 16);
ins_15_11_id <= reg_if_id_im_out(15 downto 11);

eControlUnit: control_unit port map(input => reg_if_id_im_out,
	                                  alu_src => alu_src_id,
	                                  alu_op => alu_op_id,
	                                  reg_dst => reg_dst_id,
	                                  branch => branch_id,
	                                  mem_write => mem_write_id,
	                                  mem_read => mem_read_id,
	                                  mem_to_reg => mem_to_reg_id,
	                                  reg_write => reg_write_id
);
  
eRegisters: registers port map( clk => Clk, 
                                reset => Reset,
                                reg1_dr => reg_if_id_im_out(25 downto 21),
                                reg2_dr => reg_if_id_im_out(20 downto 16),
                                data_wr => salida_mux_mem_to_reg_wb,
                                reg_wr => reg_rd_or_rt_wb,
                                data1_rd => read_data_1_id,
                                data2_rd => read_data_2_id,
                                wr => reg_write_wb
);

extender: sign_extender port map( input => ins_15_0_id,
                                  output => ins_15_0_extended_id                                  
);

reg_id_ex: process(Clk, Reset)
begin
	if Reset = '1' then
		alu_src_ex <= '0';
		alu_op_ex <= (others => '0');
		reg_dst_ex <= '0';
		branch_ex <= '0';
		mem_write_ex <= '0';
		mem_read_ex <= '0';
		mem_to_reg_ex <= '0';
		reg_write_ex <= '0';
		
		read_data_1_ex <= (others => '0');
		read_data_2_ex <= (others => '0');
		ins_15_11_ex <= (others => '0');
		ins_20_16_ex <= (others => '0');
		ins_15_0_extended_ex <= (others => '0');
		counter_ex <= (others => '0');
	elsif(Clk' event and Clk='1') then
		alu_src_ex <= alu_src_id;
		alu_op_ex <= alu_op_id;
		reg_dst_ex <= reg_dst_id;
		branch_ex <= branch_id;
		mem_write_ex <= mem_write_id;
		mem_read_ex  <= mem_read_id;
		mem_to_reg_ex <= mem_to_reg_id;
		reg_write_ex <= reg_write_id;
		
		read_data_1_ex <= read_data_1_id;
		read_data_2_ex <= read_data_2_id;
		ins_15_11_ex <= ins_15_11_id;
    ins_20_16_ex <= ins_20_16_id;
    ins_15_0_extended_ex <= ins_15_0_extended_id;
    counter_ex <= counter_id;

	end if;
end process;


ins_15_0_shifted_extended_ex <= ins_15_0_extended_ex(29 downto 0)&"00"; --shift left 2

adder_ex: adder port map( input_1 => counter_ex,
                          input_2 => ins_15_0_shifted_extended_ex,
                          output => add_result_ex
);
--Mux de la etapa ex regido por reg_dst--
with reg_dst_ex select 
  salida_mux_reg_dst_ex <= ins_20_16_ex when '0',
                        ins_15_11_ex when others;

--Mux de la etapa ex regido por alu_src--
with alu_src_ex select
  salida_mux_alu_src_ex <= read_data_2_ex when '0',
                        ins_15_0_extended_ex when others;
    
ealu: alu port map(a => read_data_1_ex,
                  b => salida_mux_alu_src_ex,
                  control => alu_op_ex,
                  zero => zero_alu_ex,
                  result => result_alu_ex
);

reg_ex_mem: process(Clk, Reset)
begin
  if Reset = '1' then
	  branch_mem <= '0';
	  mem_write_mem <= '0';
	  mem_read_mem <= '0';
	  reg_write_mem <= '0';
    mem_to_reg_mem <= '0';
    reg_rd_or_rt_mem <= (others => '0');
    add_result_mem <= (others => '0');
    read_data_2_mem <= (others => '0');
    result_alu_mem <= (others => '0');
	elsif(Clk' event and Clk='1') then
    branch_mem <= branch_ex;
    mem_write_mem <= mem_write_ex;
    mem_read_mem <= mem_read_ex;
    reg_write_mem <= reg_write_ex;
    mem_to_reg_mem <= mem_to_reg_ex;
    
    read_data_2_mem <= read_data_2_ex;
	  reg_rd_or_rt_mem <= salida_mux_reg_dst_ex;
	  add_result_mem <= add_result_ex;
	  result_alu_mem <= result_alu_ex;
	  zero_alu_mem <= zero_alu_ex;
	  
	end if;
end process;

--conexion con memoria de datos--
    D_dataOut <= read_data_2_mem;
    D_Addr   <= result_alu_mem;
	  D_RdStb  <= mem_read_mem;
	  D_WrStb  <= mem_write_mem;

--and para el branch--
pc_src_mem <= branch_mem and zero_alu_mem;

read_data_mem <= D_dataIn; 
reg_mem_wb: process(Clk, Reset)
begin
  if Reset = '1' then
	  read_data_wb <= (others => '0');
	  result_alu_wb <= (others => '0');
	  reg_rd_or_rt_wb <= (others => '0');
	  
	  mem_to_reg_wb <= '0';
	  reg_write_wb <= '0';
	elsif(Clk' event and Clk='1') then
	   mem_to_reg_wb <= mem_to_reg_mem;
	   reg_write_wb <= reg_write_mem;
	   
    read_data_wb <= read_data_mem;
    result_alu_wb <= result_alu_mem;
    reg_rd_or_rt_wb <= reg_rd_or_rt_mem;
	end if; 
end process;

--mux regido por mem_to_reg--
with mem_to_reg_wb select
salida_mux_mem_to_reg_wb <= read_data_wb when '1',
                            result_alu_wb when others;

end processor_arq;
