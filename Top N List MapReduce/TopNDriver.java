package stubs;

import org.apache.hadoop.conf.Configured;
import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.fs.Path;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.LongWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.lib.input.FileInputFormat;
import org.apache.hadoop.mapreduce.lib.output.FileOutputFormat;
import org.apache.hadoop.mapreduce.Job;
import org.apache.hadoop.util.Tool;
import org.apache.hadoop.util.ToolRunner;

public class TopNDriver extends Configured implements Tool {

	public static void main(String[] args) throws Exception {

		int exitcode = ToolRunner.run(new Configuration(),
				new TopNDriver(), args);
		System.exit(exitcode);
	}

	/**
	 * The run method is called in the main method, and runs an instance
	 * of MapReduce, taking in Configurations provided in the main method
	 * 
	 * @param args 
	 * @return returns 0 if MapReduce is finished, else 1.
	 */
	public int run(String[] args) throws Exception {
		
		if (args.length != 2) {
			System.out.printf("Usage: " + this.getClass().getName() +  "<input dir> <output dir>\n");
			System.exit(-1);
		}

		Job job = new Job(getConf());
		job.setJarByClass(TopNDriver.class);

		job.setJobName("TopNDriver (job 2)");

		FileInputFormat.setInputPaths(job, new Path(args[0]));
		FileOutputFormat.setOutputPath(job, new Path(args[1]));

		job.setMapperClass(TopNMapper.class);
		job.setReducerClass(TopNReducer.class);
		
		// There will only be one reduce task
		job.setNumReduceTasks(1);

		// The map output has nullwritable as key; only the value is of interest
		job.setMapOutputKeyClass(NullWritable.class);
		job.setMapOutputValueClass(Text.class);		
		
		// The job will output (Sum of Ratings, Movie Title)
		job.setOutputKeyClass(IntWritable.class);
		job.setOutputValueClass(Text.class);

		boolean success = job.waitForCompletion(true);
		return (success ? 0 : 1);
	}
}
