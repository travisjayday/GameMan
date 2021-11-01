
def bit_template(op, num, cmt): 
    return [("ALU_OP8_BIT(%s, {}, {});".format(op, num),
    "ALU_OP8_MEM8(REG_HL, {}, {});".format(op, num), '{} {}, %s'.format(cmt, num)),
    ("ALU_OP8_BIT(%s, {}, {});".format(op, num+1),
    "ALU_OP8_MEM8(REG_HL, {}, {});".format(op, num+1), '{} {}, %s'.format(cmt, num+1))]

funcs = [
    # ROW 0
    [("ALU_OP8(%s, %s, ALU_OP_ROT_LC);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_LC, 0);", 'RLC %s'),
    ("ALU_OP8(%s, %s, ALU_OP_ROT_RC);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_RC, 0);", 'RRC %s')],
    # ROW 1
    [("ALU_OP8(%s, %s, ALU_OP_ROT_L);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_L, 0);", 'RL %s'),
    ("ALU_OP8(%s, %s, ALU_OP_ROT_R);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_ROT_R, 0);", 'RR %s')],
    # ROW 2
    [("ALU_OP8(%s, %s, ALU_OP_SLA);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_SLA, 0);", 'SLA %s'),
    ("ALU_OP8(%s, %s, ALU_OP_SRA);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_SRA, 0);", 'SRA %s')],
    # ROW 3
    [("ALU_OP8(%s, %s, ALU_OP_SWAP);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_SWAP, 0);", 'SWAP %s'),
    ("ALU_OP8(%s, %s, ALU_OP_SRL);",
    "ALU_OP8_MEM8(REG_HL, ALU_OP_SRL, 0);", 'SRL %s')],
    # ROW 4
    bit_template('ALU_OP_BIT_TEST', 0, 'BIT'),
    # ROW 5
    bit_template('ALU_OP_BIT_TEST', 2, 'BIT'),
    # ROW 6
    bit_template('ALU_OP_BIT_TEST', 4, 'BIT'),
    # ROW 7
    bit_template('ALU_OP_BIT_TEST', 6, 'BIT'),
    # ROW 8
    bit_template('ALU_OP_BIT_RES', 0, 'RES'),
    # ROW 9
    bit_template('ALU_OP_BIT_RES', 2, 'RES'),
    # ROW A
    bit_template('ALU_OP_BIT_RES', 4, 'RES'),
    # ROW B
    bit_template('ALU_OP_BIT_RES', 6, 'RES'),
    # ROW C
    bit_template('ALU_OP_BIT_SET', 0, 'SET'),
    # ROW D
    bit_template('ALU_OP_BIT_SET', 2, 'SET'),
    # ROW E
    bit_template('ALU_OP_BIT_SET', 4, 'SET'),
    # ROW F
    bit_template('ALU_OP_BIT_SET', 6, 'SET')
]

comment = "RLC %s"
TAB = '    '

def do_print(row, func, func_hl, cmt, lower=True):
    regs = ['REG_B', 'REG_C', 'REG_D', 'REG_E', 'REG_H', 'REG_L', 'REG_HL', 'REG_A']
    i = 0 if lower else 8
    for reg in regs:
        case = "4'h%x: " % i
        postfix = '\t\t' + TAB + '// ' + (cmt % '(HL)' if reg == 'REG_HL' else cmt % reg[-1])
        arg = [reg] * func.count('%s')
        if reg == 'REG_HL' and len(case + func_hl)  < 40:
            postfix = '\t' + postfix
        s = TAB + TAB + case + (func_hl if reg == 'REG_HL' else func % tuple(arg)) + postfix
        i += 1
        print(s)
for row in range(len(funcs)):
    _funcs = funcs[row]
    print(TAB + 'task CB_ROW%X; input logic [3:0] col; case (col)' % row)
    do_print(row, _funcs[0][0], _funcs[0][1], _funcs[0][2])
    do_print(row, _funcs[1][0], _funcs[1][1], _funcs[1][2], False)
    print(TAB + TAB + 'default: unkown_opcode();')
    print(TAB + 'endcase endtask')
    print('')