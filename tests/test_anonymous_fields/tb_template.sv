{% extends "lib/tb_base.sv" %}

{% block seq %}
    {% sv_line_anchor %}
    ##1;
    cb.rst <= '0;
    ##1;

    // sw=rw, hw=r
    cpuif.assert_read('h0, 'h1234);
    assert(cb.hwif_out.EPID.value == 'h1234);
    cpuif.write('h0, 'hCAFE_F00D);
    cpuif.assert_read('h0, 'hCAFE_F00D);
    @cb;
    assert(cb.hwif_out.EPID.value == 'hCAFE_F00D);

    // sw=r, hw=w
    cb.hwif_in.STATUS.next <= 'hABCD;
    @cb;
    cpuif.assert_read('h4, 'hABCD);

    // Arrayed register with a property output
    cpuif.write('hC, 'h5A);
    cpuif.assert_read('hC, 'h5A);
    cpuif.assert_read('h8, 'h00);
    @cb;
    assert(cb.hwif_out.CFG[1].value == 'h5A);
    assert(cb.hwif_out.CFG[0].value == 'h00);

    // Interrupt register
    assert(cb.hwif_out.IRQ.intr == 1'b0);
    cb.hwif_in.IRQ.next <= 'h3;
    @cb;
    cb.hwif_in.IRQ.next <= 'h0;
    cpuif.assert_read('h10, 'h3);
    assert(cb.hwif_out.IRQ.intr == 1'b1);
    cpuif.write('h10, 'h3);
    cpuif.assert_read('h10, 'h0);
    assert(cb.hwif_out.IRQ.intr == 1'b0);

    // Counter with implied incr input
    cpuif.assert_read('h14, 'h0);
    cb.hwif_in.CNT.incr <= '1;
    repeat(5) @cb;
    cb.hwif_in.CNT.incr <= '0;
    cpuif.assert_read('h14, 'h5);

    // Registers without anonymous fields are unchanged
    cpuif.assert_read('h18, 'h2211);
    assert(cb.hwif_out.NORMAL.a.value == 'h11);
    assert(cb.hwif_out.NORMAL.b.value == 'h22);
{% endblock %}
