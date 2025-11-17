#yosys -TQd -v 1 -L map.log -c map.tcl

yosys -import

set verilogs {}
foreach arg $argv {
  set arg [string trim $arg "\"\{\'\t \n"]
  if { [string index $arg 0] == "@" } {
    set cmd [string range $arg 1 1000]
    eval $cmd
  } else {
    lappend verilogs $arg
  }
}

if { ! [info exists RETIMING] } {
  set RETIMING "100"
}
if { $RETIMING == "true" } {
  set RETIMING "100"
} elseif { $RETIMING == "false" } {
  set RETIMING "None"
}
if { ! [info exists IOPAD] } {
  set IOPAD true
}
if { [info exists DESIGN] && ! [info exists TOP_MODULE] } {
  set TOP_MODULE "$DESIGN"
}
if { ! [info exists DESIGN] } {
  set DESIGN "ccgg"
}
if { ! [info exists TOP_MODULE] } {
  set TOP_MODULE "ccgg"
}

clock format [clock seconds] -format "%a %b %d %T %Y"
if { [file exists [file join . ${DESIGN}.pre_map.asf]] } {
  puts "Using pre_map-ASF file ${DESIGN}.pre_map.asf."
  source [file join . ${DESIGN}.pre_map.asf]
}

if { [ llength $verilogs ] == 0 } {
  set verilogs { "ccgg.v" "user_ip.v" }
}
if { [ llength $verilogs ] == 0 } {
  set verilogs [list ./${DESIGN}.v]
}
foreach verilog $verilogs {
  read_verilog -sv -overwrite -DALTA_SYN "$verilog"
}


#family:
    read_verilog -DALTA_LIB -sv -lib +/agm/rodina/cells_sim.v
    read_verilog -DALTA_SYN -sv +/agm/common/m9k_bb.v
    read_verilog -DALTA_SYN -sv +/agm/common/altpll_bb.v
    read_verilog -DALTA_LIB -sv -lib +/agm/rodina/alta_sim.v
    read_verilog -DALTA_SYN -sv +/agm/rodina/alta_sim.v
    read_verilog -DALTA_SYN -sv +/agm/common/alta_bb.v
    hierarchy -check -top $TOP_MODULE -DALTA_SYN -libdir "user_ip" -libdir .

#flatten:
   #yosys proc
    flatten
    tribuf -logic
    deminout

    set alta_ips {alta_bram alta_bram9k alta_sram alta_wram alta_pll alta_pllx alta_pllv alta_pllve alta_boot alta_osc alta_mult alta_multm alta_ufm alta_ufms alta_ufml alta_i2c alta_spi alta_irda alta_mcu alta_mcu_m3 alta_saradc alta_adc alta_dac alta_cmp}
    select -none
    foreach alta_ip $alta_ips {
      select -add */t:$alta_ip
    }
    select -set keep_cells %
    select -clear
    setattr -set keep 1 @keep_cells

#coarse:
    synth -run coarse -top $TOP_MODULE
    for {set nn 0} {$nn < 10} {incr nn} {
      proc_dff
    }

#map_bram:
    memory_libmap -lib +/agm/common/brams_m9k.txt
    techmap -autoproc -map +/agm/common/brams_map_m9k.v
    yosys proc
    read_verilog -DALTA_SYN -sv +/agm/rodina/alta_sim.v
    hierarchy -check -top $TOP_MODULE
    flatten

#map_ffram:
    opt -fast -mux_undef -fine
    memory_map
    opt -fine
    techmap -autoproc -map +/agm/rodina/arith_map.v
    techmap -autoproc -map +/techmap.v
    yosys proc
    opt -undriven -fine
    yosys rename -wire -suffix _reg t:$*DFF*
    clean -purge
    setundef -undriven -zero
    if { $RETIMING != "None" } {
      abc -markgroups -dff -D $RETIMING
    }

#map_ffs:
    dfflegalize -cell \$_DFFE_????_ 0 -cell \$_SDFFCE_????_ 0 -cell \$_DLATCH_?_ x -cell \$_ALDFFE_???_ 0
    techmap -autoproc -map +/agm/common/ff_map.v
    yosys proc
    opt -fine
    clean -purge
    setundef -undriven -zero
    abc -markgroups -dff -D 1
    agm_dffeas

##opts:
    opt_expr -mux_undef -undriven -full
    opt_merge
    opt_clean
    autoname
 
#map_luts:
    abc -lut 4
    clean

#map_cells:
    if { $IOPAD } {
      iopadmap -bits -outpad \$__outpad I:O -inpad \$__inpad O:I -toutpad \$__toutpad E:I:O -tinoutpad \$__tinoutpad E:O:I:IO
    }
    techmap -autoproc -map +/agm/rodina/cells_map.v
    clean -purge
    autoname

#check:
    hierarchy -check
    stat
    check -noinit
    blackbox =A:whitebox

#vqm:
    write_verilog -simple-lhs -bitblasted -attr2comment -defparam -decimal -renameprefix syn_ ${DESIGN}.vqm

if { [file exists [file join . ${DESIGN}.post_map.asf]] } {
   puts "Using post_map-ASF file ${DESIGN}.post_map.asf."
   source [file join . ${DESIGN}.post_map.asf]
}
clock format [clock seconds] -format "%a %b %d %T %Y"

