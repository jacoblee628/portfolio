package edu.cmu.sglee;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.ArrayList;

/**
 * @author Jacob Lee
 *
 * The goal of this website is to scrape information from a subreddit, gather statistics about votes,
 * and then display the stats and top few posts.
 *
 * This is the servlet for the website. It has an init that starts the model
 * and a doGet method, that receives the request and returns the result.
 * It also handles errors, including bad inputs and poor connection.
 */
@WebServlet(name = "WebScrapingServlet", urlPatterns = {"/scrapingTime"})
public class WebScrapingServlet extends HttpServlet {

    WebScrapingModel wsm = null; // Contains webscraping methods and variables
    private static ArrayList<String> validSubreddits;
    private static final String RESULTS_PAGE = "results.jsp";
    private static final String ERROR_PAGE = "error.jsp";

    // Initialize the webscraper
    @Override
    public void init() {
        wsm = new WebScrapingModel();
        validSubreddits = new ArrayList<String>();
        validSubreddits.add("pics");
        validSubreddits.add("itookapicture");
        validSubreddits.add("adviceAnimals");
    }

    /**
     * Responds to HTTP GET requests, calling necessary methods
     */
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        // Process inputs
        String nextView; // Variable to determine which page to go to next
        try {
            String subredditName = request.getParameter("subredditName");
            String rawNumPosts = request.getParameter("numPosts");

            if (rawNumPosts == null || subredditName == null) {
                throw new IOException();
            }

            int numPosts = Integer.parseInt(rawNumPosts);
            // Check if parameters are valid
            if (!subredditName.isEmpty() && numPosts > 0 && numPosts <= 3 && validSubreddits.contains(subredditName)) {
                // Get the info from the model in a holder object
                SubredditStats stats = wsm.doGetStats(subredditName);

                // If a null for stats was returned, there's some error
                if (stats == null) {
                    nextView = ERROR_PAGE;
                    RequestDispatcher view = request.getRequestDispatcher(nextView);
                    view.forward(request, response);
                    return;
                }

                // Extract info from the holder
                ArrayList<String> imageURLs = stats.getTopNURLs(numPosts);
                ArrayList<String> postTitles = stats.getTopNTitles(numPosts);
                ArrayList<String> voteList = stats.getTopNVotes(numPosts);

                // Send info to attributes
                request.setAttribute("avgVotes", Integer.toString(stats.getAvgVotes()));
                request.setAttribute("minVotes", Integer.toString(stats.getMinVotes()));
                request.setAttribute("maxVotes", Integer.toString(stats.getMaxVotes()));
                request.setAttribute("totalVotes", Integer.toString(stats.getTotalVotes()));
                request.setAttribute("imageURLs", imageURLs);
                request.setAttribute("postTitles", postTitles);
                request.setAttribute("voteList", voteList);

                // Proceed to results page
                nextView = RESULTS_PAGE;
            } else {
                // catches bad inputs
                nextView = ERROR_PAGE;
            }
        } catch (IOException e) {
            e.printStackTrace();
            nextView = ERROR_PAGE;
        }

        // Transfer control over the the correct "view"
        RequestDispatcher view = request.getRequestDispatcher(nextView);
        view.forward(request, response);
    }
}
