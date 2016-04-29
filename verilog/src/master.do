vsim -gui work.tb_master
add wave -r sim:/tb_master/*
run 300ns
