package stubs;
import java.io.IOException;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;

public class AggregateRatingsMapper extends Mapper<LongWritable, Text, LongWritable, LongWritable> {
	
	/**
	 * Map method
	 * Takes in the key (byte offset) and value (string) of each line
	 * It writes the MovieID as Text
	 */
	@Override
	public void map(LongWritable key, Text value, Context context)
			throws IOException, InterruptedException {
		
		String line = value.toString();
		
		// Split input into an array, with each entry separated by commas
		String[] split_string=line.split(",");

		if (split_string.length!=3) {
			return;
		}
		
		// In order to convert the double (with decimal place)
		// to long, we take the digit before the decimal.
		// We can do this as the rating was specified in the readme to be integer
		split_string[2]=Character.toString(split_string[2].charAt(0));
		
		context.write(new LongWritable(Long.parseLong(split_string[0])), new LongWritable(Long.parseLong(split_string[2])));
	}
}
