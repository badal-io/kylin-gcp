package com.muvaki.beam;

import org.apache.beam.sdk.extensions.gcp.options.GcpOptions;
import org.apache.beam.sdk.options.Default;
import org.apache.beam.sdk.options.Description;
import org.apache.beam.sdk.options.ValueProvider;


public interface PipeOptions extends GcpOptions{

    @Description("Query for BigQuery source data")
    ValueProvider<String> getInputQuery();
    void setInputQuery(ValueProvider<String> queryString);

    @Description("GCS path-pattern for data sync")
    ValueProvider<String> getOutputPattern();
    void setOutputPattern(ValueProvider<String> path);

    @Description("Number of files for GCS write")
    @Default.Integer(1)
    Integer getShardNum();
    void setShardNum(Integer path);
}
