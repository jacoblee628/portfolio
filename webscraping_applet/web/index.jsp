<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%--
  Name: jacob lee
--%>
<html>
    <head>
        <title>ScrapingAround</title>
    </head>
    <body>
        <h1 align="left">It's Web Scrapin' Time!</h1>
        <h3>Made by Jacob Lee (sglee)</h3>
        <h3>Instructions</h3>
        <p>This tool reports statistics about "subreddits" from the website <a
                href="https://en.wikipedia.org/wiki/Reddit">Reddit.com</a></p>
        <p>Choose a subreddit from the list, and this tool will scrape the current front page and gather some stats</p>

        <form action="scrapingTime" method="GET" align="left">
            <fieldset>
                <legend>Choose a Subreddit!</legend>
                <p>Options temporarily limited (Reddit's a big website with lots of edge cases)</p>
                <label>Input:
                    <select name="subredditName">
                        <option value="pics" selected>r/pics</option>
                        <option value="adviceAnimals">r/adviceanimals</option>
                        <option value="itookapicture">r/itookapicture</option>
                    </select>
                </label>
                <label>Pick how many top posts to return
                    <select name="numPosts">
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3" selected>3</option>
                    </select>
                </label>
                <br>
                <input type="submit" value="Submit"/><br>
            </fieldset>
        </form>
        <p><a href="https://github.com/reddit-archive/reddit/wiki/API">Note: Scraping is approved for Reddit under their TOS, both with and without API.</a></p>
    </body>
</html>

