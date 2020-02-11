package edu.cmu.sglee;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.ArrayList;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * @author Jacob Lee
 *
 * This class serves as the model for the servlet.
 * It receives the webscraping request, gets a response string
 * and returns a SubredditStats object containing the results.
 *
 * The getTitles, getVotes, and getImageURLs methods scrape the necessary information
 * from the response value.
 *
 * They all work similarly, but are adjusted based on their needs.
 * I tried to make them one object, but each task ended up being fairly specific.
 * Object oriented design should save time and work, not increase it.
 *
 */
public class WebScrapingModel {

    static final String REDDIT_BASE_URL = "https://old.reddit.com/r/";

    /**
     * Main method
     * Populates a stats object for a subreddit front page and returns it
     * @param subredditName The name of the subreddit to scrape
     * @return SubredditStats Custom object that holds desired data
     */
    public SubredditStats doGetStats(String subredditName) {
        // Get response from subreddit page
        String response = "";
        String url = REDDIT_BASE_URL + subredditName;
        response = fetch(url);

        if (response.isBlank()) {
            System.out.println("response is blank");
            return null;
        } else {
            // Initialize container for statistics
            SubredditStats stats = new SubredditStats(subredditName);

            // Get info from response
            stats.setPostList(getTitles(response));
            stats.setVoteList(getVotes(response));
            stats.setUrlList(getImageURLs(response));

            // If any retrievals failed, return null (this goes to error in servlet)
            if (stats.getPostList().size() == 0 ||
                    stats.getVoteList().size() == 0 ||
                    stats.getUrlList().size() == 0) {
                System.out.println("Retrieval failed");
                return null;
            } else {
                return stats;
            }
        }
    }

    /**
     * Makes HTTP request to subreddit. Specifies user-agent.
     *
     * @param urlString The URL of the request
     * @return The response string from the HTTP Get.
     */
    private String fetch(String urlString) {
        StringBuilder response = new StringBuilder();
        try {
            URL url = new URL(urlString);
            HttpURLConnection con = (HttpURLConnection) url.openConnection();
            con.setInstanceFollowRedirects(true);
            con.setRequestProperty("user-agent", "Custom user for a CMU class!");
            con.connect();
            try (BufferedReader in = new BufferedReader(
                    new InputStreamReader(con.getInputStream(), "UTF-8"))) {
                String str;
                while ((str = in.readLine()) != null) {
                    response.append(str);
                }
                in.close();
            } finally {
                con.disconnect();
            }
        } catch (IOException e) {
            e.printStackTrace();
            return "";
        }
        return response.toString();
    }

    /**
     * Gets list of post titles from response
     * @param response String of the response from fetch method
     * @return ArrayList<String> containing the post titles
     */
    private ArrayList<String> getTitles(String response) {
        /*
         * It turns out that after each occurrence of "tabindex="1">",
         * the post title can be found relatively easily, given that you terminate before
         * the next "</a>" tag. I do that here with regex.
         */

        // Initialize variables for the loop below
        ArrayList<String> titles = new ArrayList<>();
        Pattern p = Pattern.compile("tabindex=\"1\" >|rel=\"nofollow ugc\" >");
        Matcher m = p.matcher(response);
        int charIndex = 0;
        char c;
        int charCount = 0;
        StringBuilder title;
        int skipCounter = 0;

        while (m.find()) {
            title = new StringBuilder("");
            charCount = 0; // To avoid an infinite loop, we limit title length
            charIndex = m.end(); // We start looking right after the pattern match
            // If the first char is another tag, then we skip
            if (response.charAt(charIndex) == '<') {
                continue;
            }
            while (charCount < 150) {
                c = response.charAt(charIndex);
                // Break on the first </a> (check when you hit a "<")
                if (c == '<') {
                    if (response.charAt(charIndex + 1) == '/' && response.charAt(charIndex + 2) == 'a') {
                        break;
                    }
                }
                // Append char to
                title.append(response.charAt(charIndex));
                charIndex++;
                charCount++;
            }
            if (title.length() > 0) {
                titles.add(title.toString());
            }
        }
        return titles;
    }

    /**
     * Gets list of post upvotes from response
     * @param response String of the response from fetch method
     * @return ArrayList<Integer> containing the post upvotes
     */
    private ArrayList<String> getVotes(String response) {
        /*
         * The post karma can be found after the "data-score" strings
         * So we loop over (similarly to post titles and extract them
         */
        // Initialize variables for the loop below
        ArrayList<String> votes = new ArrayList<>();
        Pattern p = Pattern.compile("data-score=\\\"");
        Matcher m = p.matcher(response);
        int charIndex = 0;
        char c;
        int charCount;
        StringBuilder score;

        while (m.find()) {
            score = new StringBuilder("");
            charCount = 0; // To avoid an infinite loop
            charIndex = m.end(); // We start right after the pattern string
            while (charCount < 15) {
                c = response.charAt(charIndex);
                // The score ends just before the quotation mark
                if (c == '"') {
                    break;
                }
                score.append(response.charAt(charIndex));
                charIndex++;
                charCount++;
            }
            if (score.length() > 0) {
                votes.add(score.toString());
            }
        }
        return votes;
    }

    /**
     * Gets list of image URLs from response
     * @param response String of the response from fetch method
     * @return ArrayList<String> containing the image URLs
     */
    private ArrayList<String> getImageURLs(String response) {
        /*
         * The post karma can be found after the "data-score" strings
         * So we loop over (similarly to post titles and extract them
         */
        ArrayList<String> urls = new ArrayList<>();
        Pattern p = Pattern.compile("data-url=\\\"");
        Matcher m = p.matcher(response);
        int charIndex = 0;
        char c;
        int charCount;
        StringBuilder urlString;

        while (m.find()) {
            urlString = new StringBuilder("");
            charCount = 0;
            charIndex = m.end();
            while (charCount < 150) {
                c = response.charAt(charIndex);
                // Break on end quote after the URL
                if (c == '"') {
                    break;
                }
                urlString.append(response.charAt(charIndex));
                charIndex++;
                charCount++;
            }
            // Imgur links can just have ".jpg" added to access direct image.
            if (urlString.toString().contains("imgur")) {
                urlString.append(".jpg");
            }
            if (urlString.length() > 0) {
                urls.add(urlString.toString());
            }
        }
        return urls;
    }
}
