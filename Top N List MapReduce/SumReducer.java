package stubs;

import java.io.IOException;

import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class SumReducer extends Reducer<LongWritable, LongWritable, LongWritable, LongWritable> {
	
	/**
	 * reduce
	 * Taken pretty much verbatim from wordcount; simply sums the values
	 * of each occurrence of a key, then outputs just that key and its sum of values
	 */
	@Override
	public void reduce(LongWritable key, Iterable<LongWritable> values, Context context)
			throws IOException, InterruptedException {
		long wordCount = 0;
		for (LongWritable value : values) {
			wordCount += value.get();
		}
		context.write(key, new LongWritable(wordCount));
	}
}