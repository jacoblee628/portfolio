package stubs;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Scanner;
import java.util.SortedMap;
import java.util.TreeMap;

import org.apache.hadoop.conf.Configuration;
import org.apache.hadoop.io.IntWritable;
import org.apache.hadoop.io.NullWritable;
import org.apache.hadoop.io.Text;
import org.apache.hadoop.mapreduce.Reducer;

public class TopNReducer extends
Reducer<NullWritable, Text, IntWritable, Text> {

	private Configuration conf;
	private int N;
	private SortedMap<Integer, String> top = new TreeMap<Integer, String>();
	private Map<Integer, String> movie_titles = new HashMap<Integer, String>();


	/**
	 * setup
	 * Retrieves both the N and movie_titles.txt needed to lookup
	 * and assign movie titles based on movieID.
	 */
	public void setup(Context context) throws IOException {
		this.conf = context.getConfiguration();

		// Default is 10, as before.
		this.N=conf.getInt("N", 10);

		// Pulls this from parameter specified via FileRunner.
		File movie_title_text = new File("movie_titles.txt");
		
		// Creates a buffered reader to import the movies into a HashMap
		// for lookup using movie ID as key.
		try {
			BufferedReader br = new BufferedReader(new FileReader(movie_title_text));
			String line;
			String[] split_string;
			while ((line = br.readLine())!=null) {
				split_string=line.split(",");
				movie_titles.put(Integer.parseInt(split_string[0]), split_string[2]);
			}
			br.close();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		}
	}

	/**
	 * reduce
	 * Similar to previous map method; adds entries to a TreeMap, removing
	 * the entry with smallest sumratings if the Tree exceeds size N.
	 * Then outputs (sum rating, full movie title)
	 */
	public void reduce(NullWritable key, Iterable<Text> values,
			Context context) throws IOException, InterruptedException {

		String[] value_split;

		for (Text value : values) {
			value_split=value.toString().split(",");
			
			// While entering into the tree, also looks up the movie title
			// From the hashmap created in setup.
			top.put(Integer.parseInt(value_split[1]), movie_titles.get(Integer.parseInt(value_split[0])));
			if (top.size()>N) {
				top.remove(top.firstKey());
			}
		}
		
		// Output the entries in order of highest count to lowest.
		List<Integer> keys = new ArrayList<Integer>(top.keySet());
		for (int i=top.size()-1; i>=0; i--) {
			context.write(new IntWritable(keys.get(i)), new Text(top.get(keys.get(i))));
		}
	}
}