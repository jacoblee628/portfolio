package stubs;

import java.io.IOException;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Mapper;
import org.apache.hadoop.mapreduce.Mapper.Context;

public class TopNMapper extends Mapper<LongWritable, Text, NullWritable, Text> {

	private int N;
	private SortedMap<Integer, String> top = new TreeMap<Integer, String>();

	/**
	 * setup
	 * Setup to retrieve the N (number of items in top list)
	 * from configuration
	 */
	protected void setup(Context context) {
		// Default N is 10
		this.N=context.getConfiguration().getInt("N", 10);
	}

	/**
	 * map
	 * This method takes the part-r-00000 file from the first job as input.
	 * Thus each line is a string, with byte offset key and value.
	 * Sorts by TreeMap for the cleanup method to write.
	 */
	@Override
	public void map(LongWritable key, Text value, Context context)
			throws IOException, InterruptedException {

		String[] split = value.toString().split("\\s+");
		int movieID = Integer.parseInt(split[0]);
		int sumrating = Integer.parseInt(split[1]);
				
		String combined = movieID + "," + sumrating;

		// Adds everything to a TreeMap, which sorts by sumrating
		// and removes the lowest entry if the size of the tree
		// exceeds N.
		top.put(sumrating, combined);
		if (top.size() > N) {
			top.remove(top.firstKey());
		}
	}

	/**
	 * cleanup
	 * For each entry of the tree, writes the key (null)
	 * and value (which contains both the movieID and sumratings) as Text.
	 */
	public void cleanup(Context context) throws IOException,
	InterruptedException {
		for (String str : top.values()) {
			context.write(NullWritable.get(), new Text(str));
		}
	}
}