package com.muvaki.beam;

import com.google.api.services.bigquery.model.TableRow;
import org.apache.beam.sdk.Pipeline;
import org.apache.beam.sdk.io.TextIO;
import org.apache.beam.sdk.io.gcp.bigquery.BigQueryIO;
import org.apache.beam.sdk.options.PipelineOptionsFactory;
import org.apache.beam.sdk.transforms.MapElements;
import org.apache.beam.sdk.values.TypeDescriptor;


public class Pipe {

    static BigQueryIO.TypedRead<TableRow> bqRead(PipeOptions options) {
        return BigQueryIO
                .readTableRows()
                .fromQuery(options.getInputQuery()).withoutValidation();
    }

    static TextIO.Write gcsWrite(PipeOptions options) {
        return TextIO.write()
                .to(options.getOutputPattern())
                .withNumShards(options.getShardNum());
    }

    static void pipe(String[] args) {
        PipeOptions options = options(args);
        Pipeline pipeline = Pipeline.create(options);
        pipeline
                .apply("BigQuery Read", bqRead(options))
                .apply("Convert to csv", MapElements
                        .into(TypeDescriptor.of(String.class))
                        .via((TableRow r) ->
                                r.values().stream()
                                        .map(cell -> cell.toString())
                                        .reduce("", (c1, c2) -> c1 + "," + c2)
                                        .substring(1)
                        )
                )
                .apply("write to GCS backed HDFS", gcsWrite(options));
        pipeline.run();

    }

    static PipeOptions options(String[] args) {
        return PipelineOptionsFactory
                .fromArgs(args)
                .withValidation()
                .as(PipeOptions.class);
    }

    public static void main(String[] args) {
        pipe(args);
    }
}

