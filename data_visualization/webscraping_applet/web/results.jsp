<%@ page import="java.util.ArrayList" %>
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

        <%--Load in all retrieved data--%>
        <%
            int numPosts = Integer.parseInt(request.getParameter("numPosts"));
            ArrayList<String> imageURLs = (ArrayList<String>) request.getAttribute("imageURLs");
            ArrayList<String> postTitles = (ArrayList<String>) request.getAttribute("postTitles");
            ArrayList<String> voteList = (ArrayList<String>) request.getAttribute("voteList");
        %>
        <h1>Results!</h1>
        <h2>Top <%=numPosts%> r/<%=request.getParameter("subredditName")%> post(s)!</h2>
        <p style="padding:10px; border: black 2px solid">
            <span style="font-size:20px; font-weight:bold;">Statistics for ALL posts</span><br>
            <b>Mean votes:</b> <%=request.getAttribute("avgVotes")%><br>
            <b>Min votes:</b> <%=request.getAttribute("minVotes")%><br>
            <b>Max votes:</b> <%=request.getAttribute("maxVotes")%><br>
            <b>Total votes:</b> <%=request.getAttribute("totalVotes")%><br>
        </p>

        <%--Iteratively display the data--%>
        <%for (int n=0; n<numPosts; n++) {%>
            <h2>Post #<%=n + 1%> (<%=voteList.get(n)%> upvotes)</h2>
            <p><b>Title: </b><%=postTitles.get(n)%></p>
            <img src=<%=imageURLs.get(n)%> style="width:30%;display:block">
            <br>
        <% } %>
    </body>
</html>

