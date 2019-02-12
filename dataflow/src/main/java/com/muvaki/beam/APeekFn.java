package com.muvaki.beam;

import org.apache.beam.sdk.transforms.DoFn;

public class APeekFn<E> extends DoFn<E, E> {

    @ProcessElement
    public void process(ProcessContext c) {
        E element = c.element();
        System.out.println(element);
        c.output(element);
    }
}


