quit -sim
vsim -gui -novopt work.tb_noc_linreg
add wave -position end  sim:/tb_noc_linreg/Clk
add wave -position end  sim:/tb_noc_linreg/Rst_n
add wave -position end  sim:/tb_noc_linreg/send_flit
add wave -position end  sim:/tb_noc_linreg/flit_in
add wave -position end  sim:/tb_noc_linreg/send_credit
add wave -position end  sim:/tb_noc_linreg/credit_in
add wave -position end  sim:/tb_noc_linreg/credit_out
add wave -position end  sim:/tb_noc_linreg/flit_out
add wave -position end  sim:/tb_noc_linreg/accept_credit
add wave -position end  sim:/tb_noc_linreg/dest
add wave -position end  sim:/tb_noc_linreg/vc
add wave -position end  sim:/tb_noc_linreg/data
add wave -position end  sim:/tb_noc_linreg/flit
add wave -position end  sim:/tb_noc_linreg/slave0/CLK
add wave -position end  sim:/tb_noc_linreg/slave0/RST_N
add wave -position end  sim:/tb_noc_linreg/slave0/STATE
add wave -position end  sim:/tb_noc_linreg/slave0/start_index
add wave -position end  sim:/tb_noc_linreg/slave0/end_index
add wave -position end  sim:/tb_noc_linreg/slave0/vc
add wave -position end  sim:/tb_noc_linreg/slave0/slave_id
run 300ns