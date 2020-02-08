package edu.cmu.sglee;

import java.util.ArrayList;
import java.util.List;

/**
 * @author jacob lee
 *
 * This class serves as a holder class for the variables scraped for one request.
 * It also contains several methods for manipulating this information.
 */
public class SubredditStats {
    private int totalVotes;
    private int avgVotes;
    private int minVotes;
    private int maxVotes;
    private int numAnnouncements; // Tracks the number of announcement posts on the page (to skip)
    private ArrayList<String> postList;
    private ArrayList<String> voteList;
    private ArrayList<String> urlList;
    private final String SUBREDDIT_NAME;

    /**
     * Initializes holder class for scraped statistics/information
     * @param subredditName the name of the subreddit scraped
     */
    SubredditStats(String subredditName) {
        this.SUBREDDIT_NAME = subredditName;
        this.numAnnouncements = 0;
        this.minVotes= 0;
        this.maxVotes = 0;
        this.avgVotes = 0;
        this.totalVotes = 0;
        this.postList = new ArrayList<String>();
        this.voteList = new ArrayList<String>();
        this.urlList = new ArrayList<String>();
    }

    /**
     * Returns the top N (specified by user) post titles on the page, in presented order
     * @param numPosts N
     * @return ArrayList<String> containing the top N post titles
     */
    public ArrayList<String> getTopNTitles(int numPosts) {
        getNumAnnouncements();
        List<String> subList = this.postList.subList(this.numAnnouncements, this.numAnnouncements + numPosts);
        return new ArrayList<String>(subList);
    }

    /**
     * Returns the votes for the top N posts on the page, in presented order
     * @param numPosts N
     * @return ArrayList<String> containing the top N vote numbers
     */
    public ArrayList<String> getTopNVotes(int numPosts) {
        getNumAnnouncements();
        List<String> subList = this.voteList.subList(this.numAnnouncements, this.numAnnouncements + numPosts);
        return new ArrayList<String>(subList);
    }

    /**
     * Returns the votes for the top N image urls on the page, in presented order
     * @param numPosts N
     * @return ArrayList<String> containing the top N vote numbers
     */
    public ArrayList<String> getTopNURLs(int numPosts) {
        getNumAnnouncements();
        List<String> subList = this.urlList.subList(this.numAnnouncements, this.numAnnouncements + numPosts);
        return new ArrayList<String>(subList);
    }

    /**
     * Returns total votes, calculates if not already calculated.
     * @return
     */
    public int getTotalVotes() {
        if (this.totalVotes == 0) {
            for (String v : this.voteList) {
                this.totalVotes += Integer.parseInt(v);
            }
        }
        return this.totalVotes;
    }

    /**
     * Gets average votes among posts
     * @return int of average votes
     */
    public int getAvgVotes() {
        if (this.avgVotes == 0 && this.postList.size() > 0) {
            this.getTotalVotes();
            this.avgVotes = this.getTotalVotes() / this.postList.size();
        }
        return this.avgVotes;
    }

    /**
     * Gets min votes for a post
     * @return int of min votes for a post
     */
    public int getMinVotes() {
        // If not already calculated, calculate the min votes amongst posts
        if (this.minVotes == 0) {
            // Compare to all post votes
            // and set the min to the lowest
            this.minVotes = Integer.MAX_VALUE;
            int vote = 0;
            for (String s : this.voteList) {
                vote = Integer.parseInt(s);
                if (vote < this.minVotes) {
                    this.minVotes = vote;
                }
            }
        }
        return minVotes;
    }

    /**
     * Gets max votes for a post
     * @return int of max votes for a post
     */
    public int getMaxVotes() {
        if (this.maxVotes == 0) {
            int vote = 0;
            for (String s : this.voteList) {
                vote = Integer.parseInt(s);
                if (vote > this.maxVotes) {
                    this.maxVotes = vote;
                }
            }
        }
        return maxVotes;
    }

    /**
     * Gets (if needed, calculates) the number of announcement posts on the page
     * @return integer of the announcement post count
     */
    public int getNumAnnouncements() {
        if (this.SUBREDDIT_NAME.equalsIgnoreCase("adviceanimals")) {
            this.numAnnouncements = 2;
        }
        // Check for announcements and count
        if (this.numAnnouncements == 0) {
            for (String u : this.urlList) {
                if (u.toLowerCase().contains("announcement")) {
                    this.numAnnouncements++;
                }
            }
        }
        return this.numAnnouncements;
    }

    public ArrayList<String> getPostList() {
        return this.postList;
    }

    public void setPostList(ArrayList<String> postList) {
        this.postList = postList;
    }

    public void setVoteList(ArrayList<String> voteList) {
        this.voteList = voteList;
    }

    public void setUrlList(ArrayList<String> urlList) {
        this.urlList = urlList;
    }


    public ArrayList<String> getVoteList() {
        return voteList;
    }

    public ArrayList<String> getUrlList() {
        return urlList;
    }


}
