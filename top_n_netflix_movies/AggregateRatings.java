package stubs;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class AggregateRatings  extends Configured implements Tool {

	public static void main(String[] args) throws Exception {
		int exitCode = ToolRunner.run(new Configuration(), new AggregateRatings(), args);
		System.exit(exitCode);
	}

	/**
	 * The run method is called in the main method, and runs an instance
	 * of MapReduce, taking in Configurations provided in the main method
	 * 
	 * @param args 
	 * @return     returns 0 if MapReduce is finished, else 1.
	 */
	public int run(String[] args) throws Exception {

		if (args.length != 2) {
			System.out.printf("Usage: AggregateRatings <input dir> <output dir>\n");
			System.exit(-1);
		}

		Job job = new Job(getConf());

		job.setJarByClass(AggregateRatings.class);

		// This is the first job out of two,
		// the second being the actual Top N list generator
		job.setJobName("AggregateRatings with Combiner (Job 1)");

		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		job.setMapperClass(AggregateRatingsMapper.class);
		job.setReducerClass(SumReducer.class);
		 job.setCombinerClass(SumReducer.class);

		// As the data of interest in each line is the movie ID (numeric)
		// and the rating (numeric, integer), we use long for in/out for both
		// map and reduce.
		job.setMapOutputKeyClass(LongWritable.class);
		job.setMapOutputValueClass(LongWritable.class);

		job.setOutputKeyClass(LongWritable.class);
		job.setOutputValueClass(LongWritable.class);

		boolean success = job.waitForCompletion(true);
		return success ? 0 : 1;
	}
}

