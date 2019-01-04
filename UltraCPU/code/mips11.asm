jal foo
jalr $ra, $t0
jalr $ra, $t0
j end

foo:
jalr $t0, $ra
jalr $t0, $ra
jalr $t0, $ra

end:
nop
